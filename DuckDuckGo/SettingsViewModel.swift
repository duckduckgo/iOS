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
    
    // MARK: 
    var appIconSubscription: AnyCancellable?
    var stateSubscriber: AnyCancellable?
    
    // Closure to request a legacy view controller presentation
    var onRequestPushLegacyView: ((UIViewController) -> Void)?
    var onRequestPresentLegacyView: ((UIViewController, _ modal: Bool) -> Void)?
    
    private(set) var model: SettingsModel
    @Published private(set) var state: SettingsState
    
    // Support Programatic Navigation
    var isPresentingSyncView = false
    var isPresentingLoginsView = false
    
    // Cell Visibility
    var shouldShowSyncCell: Bool { model.isFeatureAvailable(.sync) }
    var shouldShowLoginsCell: Bool { model.isFeatureAvailable(.autofillAccessCredentialManagement) }
    var shouldShowTextSizeCell: Bool { model.isFeatureAvailable(.textSize) }
    var shouldShowDebugCell: Bool { model.isFeatureAvailable(.networkProtection) }
    var shouldShowVoiceSearchCell: Bool { model.isFeatureAvailable(.voiceSearch) }
    var shouldShowAddressBarPositionCell: Bool { model.isFeatureAvailable(.addressbarPosition) }
    var shouldShowNetworkProtectionCell: Bool { model.isFeatureAvailable(.networkProtection) }
    
    // Bindings
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.general.appTheme },
            set: {
                self.model.setTheme(theme: $0)
                self.state.general.appTheme = $0
            }
        )
    }
    var fireButtonAnimationBinding: Binding<FireButtonAnimationType> {
        Binding<FireButtonAnimationType>(
            get: { self.state.general.fireButtonAnimation },
            set: {
                self.model.setFireButtonAnimetion($0)
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
                self.model.setAddressBarPosition($0)
            }
        )
    }
        
    init(model: SettingsModel, state: SettingsState = SettingsState(general: SettingsStateGeneral())) {
        self.model = model
        self.state = state
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
    }
    
    
}

extension SettingsViewModel {
    
    func setAsDefaultBrowser() {
        firePixel(.defaultBrowserButtonPressedSettings)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func shouldPresentLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.general.activeWebsiteAccount = accountDetails
        isPresentingLoginsView = true
    }
    
    func autofillViewPresentationAction() {
        firePixel(.autofillSettingsOpened)
    }
    
    func gpcViewPresentationAction() {
        firePixel(.settingsDoNotSellShown)
    }
    
    func autoConsentPresentationAction() {
        firePixel(.settingsAutoconsentShown)
    }
    
    func openCookiePopupManagement() {
        // showCookiePopupManagement(animated: true)
    }

}

// MARK: Legacy View Presentation
// These UIKit views have issues when presented via UIHostingController so
// we fall back to UIKit navigation
extension SettingsViewModel {
    
    func presentTextSettingsView(_ view: UIViewController) {
        firePixel(.textSizeSettingsShown)
        pushLegacyView(view)
    }
        
    func pushLegacyView(_ view: UIViewController) {
        onRequestPushLegacyView?(view)
    }
    
    func presentLegacyView(_ view: UIViewController, modal: Bool) {
        onRequestPresentLegacyView?(view, modal)
    }
    
    private func firePixel(_ event: Pixel.Event) {
        Pixel.fire(pixel: event)
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
