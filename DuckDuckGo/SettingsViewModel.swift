//
//  SettingsViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Core
import BrowserServicesKit
import Persistence
import SwiftUI
import Common
import Combine

#if APP_TRACKING_PROTECTION
import NetworkExtension
#endif

#if NETWORK_PROTECTION
import NetworkProtection
#endif

final class SettingsViewModel: ObservableObject {
    
    var legacyViewProvider: SettingsLegacyViewProvider
    
    // Closure to request a legacy view controller presentation
    var onRequestPushLegacyView: ((UIViewController) -> Void)?
    var onRequestPresentLegacyView: ((UIViewController, _ modal: Bool) -> Void)?
    
    private(set) var model: SettingsModel
    @Published private(set) var state: SettingsState
    
    // Support Programatic Navigation
    var isPresentingLoginsView = false
    
    // Cell Visibility
    var shouldShowSyncCell: Bool { model.isFeatureAvailable(.sync) }
    var shouldShowLoginsCell: Bool { model.isFeatureAvailable(.autofillAccessCredentialManagement) }
    var shouldShowTextSizeCell: Bool { model.isFeatureAvailable(.textSize) }
    var shouldShowDebugCell: Bool { model.isFeatureAvailable(.networkProtection) }
    var shouldShowVoiceSearchCell: Bool { model.isFeatureAvailable(.voiceSearch) }
    var shouldShowAddressBarPositionCell: Bool { model.isFeatureAvailable(.addressbarPosition) }
    var shouldShowNetworkProtectionCell: Bool { model.isFeatureAvailable(.networkProtection) }
    var shouldShowSpeechRecognitionCell: Bool { model.isFeatureAvailable(.speechRecognition) }
    var shouldShowNoMicrophonePermissionAlert: Bool = false
    
    // Bindings
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.general.appTheme },
            set: {
                self.model.appTheme = $0
                self.state.general.appTheme = $0
            }
        )
    }
    var fireButtonAnimationBinding: Binding<FireButtonAnimationType> {
        Binding<FireButtonAnimationType>(
            get: { self.state.general.fireButtonAnimation },
            set: {
                self.model.fireButtonAnimation = $0
                self.state.general.fireButtonAnimation = $0
            }
        )
    }
    var addressBarPositionBinding: Binding<AddressBarPosition> {
        Binding<AddressBarPosition>(
            get: {
                self.state.general.addressBarPosition
            },
            set: {
                self.state.general.addressBarPosition = $0
                self.model.addressBarPosition = $0
            }
        )
    }
    var applicationLockBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.general.applicationLock },
            set: {
                self.state.general.applicationLock = $0
                self.model.applicationLock = $0
            }
        )
    }
    var autocompleteBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.general.autocomplete },
            set: {
                self.state.general.autocomplete = $0
                self.model.autocomplete = $0
            }
        )
    }
    var voiceSearchEnabledBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.general.voiceSearchEnabled },
            set: { value in
                if value {
                    self.model.enableVoiceSearch { [weak self] result in
                        DispatchQueue.main.async {
                            self?.state.general.voiceSearchEnabled = result
                            self?.model.voiceSearchEnabled = result
                            if !result {
                                // Permission is denied
                                self?.shouldShowNoMicrophonePermissionAlert = true
                            }
                        }
                    }
                } else {
                    self.state.general.voiceSearchEnabled = false
                    self.model.voiceSearchEnabled = false
                }
            }
        )
    }
        
    init(model: SettingsModel,
         state: SettingsState = SettingsState(general: SettingsStateGeneral()),
         legacyViewProvider: SettingsLegacyViewProvider) {
        self.model = model
        self.state = state
        self.legacyViewProvider = legacyViewProvider
        initializeState()
    }
    
    func initializeState() {
        // Model should eventually be Observable, but that Requires appSettings to be update
        state.general.appIcon = model.appIcon
        state.general.fireButtonAnimation = model.fireButtonAnimation
        state.general.appTheme = model.appTheme
        state.general.textSize = model.textSize
        state.general.addressBarPosition = model.addressBarPosition
        state.general.sendDoNotSell = model.sendDoNotSell
        state.general.autoconsentEnabled = model.autoconsentEnabled
        state.general.autoclearDataEnabled = model.autoclearDataEnabled
        state.general.applicationLock = model.applicationLock
        state.general.voiceSearchEnabled = model.voiceSearchEnabled
        state.general.longPressPreviews = model.longPressPreviews
        state.general.allowUniversalLinks = model.allowUniversalLinks
    }
    
}

extension SettingsViewModel {
    
    private func firePixel(_ event: Pixel.Event) {
        Pixel.fire(pixel: event)
    }
    
    func setAsDefaultBrowser() {
        firePixel(.defaultBrowserButtonPressedSettings)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func shouldPresentLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.general.activeWebsiteAccount = accountDetails
        isPresentingLoginsView = true
    }
    
    func openCookiePopupManagement() {
        // showCookiePopupManagement(animated: true)
    }

}

// MARK: Legacy View Presentation
// These UIKit views have issues when presented via UIHostingController so
// we fall back to UIKit navigation
extension SettingsViewModel {
    
    enum LegacyView {
        case addToDock,
             sync,
             logins,
             textSize,
             appIcon,
             gpc,
             autoconsent,
             unprotectedSites,
             fireproofSites,
             autoclearData,
             keyboard
    }
    
    @MainActor
    func presentView(_ view: LegacyView) {
        switch view {
        
        case .addToDock:
            presentLegacyView(legacyViewProvider.addToDock, modal: true)
        
        case .sync:
            pushLegacyView(legacyViewProvider.syncSettings)
        
        case .logins:
            firePixel(.autofillSettingsOpened)
            pushLegacyView(legacyViewProvider.loginSettings(delegate: self,
                                                            selectedAccount: state.general.activeWebsiteAccount))
        
        case .textSize:
            firePixel(.textSizeSettingsShown)
            pushLegacyView(legacyViewProvider.textSettings)
        
        case .appIcon:
            pushLegacyView(legacyViewProvider.appIcon)
        
        case .gpc:
            firePixel(.settingsDoNotSellShown)
            pushLegacyView(legacyViewProvider.gpc)
        
        case .autoconsent:
            firePixel(.settingsAutoconsentShown)
            pushLegacyView(legacyViewProvider.autoConsent)
        
        case .unprotectedSites:
            pushLegacyView(legacyViewProvider.unprotectedSites)
        
        case .fireproofSites:
            pushLegacyView(legacyViewProvider.fireproofSites)
        
        case .autoclearData:
            pushLegacyView(legacyViewProvider.autoclearData)
        
        case .keyboard:
            pushLegacyView(legacyViewProvider.keyboard)
        }
    }
        
    private func pushLegacyView(_ view: UIViewController) {
        onRequestPushLegacyView?(view)
    }
    
    private func presentLegacyView(_ view: UIViewController, modal: Bool) {
        onRequestPresentLegacyView?(view, modal)
    }
    
}

extension SettingsViewModel {
    static var fontSizeForHeaderView: CGFloat {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        switch contentSize {
        case .extraSmall:
            return 12
        case .small:
            return 12
        case .medium:
            return 12
        case .large:
            return 13
        case .extraLarge:
            return 15
        case .extraExtraLarge:
            return 17
        case .extraExtraExtraLarge:
            return 19
        case .accessibilityMedium:
            return 23
        case .accessibilityLarge:
            return 27
        case .accessibilityExtraLarge:
            return 33
        case .accessibilityExtraExtraLarge:
            return 38
        case .accessibilityExtraExtraExtraLarge:
            return 44
        default:
            return 13
        }
    }
}

extension SettingsViewModel: AutofillLoginSettingsListViewControllerDelegate {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController) {
        isPresentingLoginsView = false
    }
}
