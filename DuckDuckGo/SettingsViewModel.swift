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
    
    // Dependencies
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings
    private(set) var privacyStore = PrivacyUserDefaults()
    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    private var legacyViewProvider: SettingsLegacyViewProvider
#if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
#endif
    
    // Properties
    private lazy var isPad = UIDevice.current.userInterfaceIdiom == .pad
    private var cancellables = Set<AnyCancellable>()
    
    // Closures to interact with legacy view controllers throught the container
    var onRequestPushLegacyView: ((UIViewController) -> Void)?
    var onRequestPresentLegacyView: ((UIViewController, _ modal: Bool) -> Void)?
    var onRequestDismissLegacyView: (() -> Void)?
    
    // Our View State
    @Published private(set) var state: SettingsState
    
    // MARK: Cell Visibility
    enum Features {
        case sync
        case autofillAccessCredentialManagement
        case textSize
        case voiceSearch
        case addressbarPosition
        case speechRecognition
#if NETWORK_PROTECTION
        case networkProtection
#endif
    }
    
    var shouldShowSyncCell: Bool { featureFlagger.isFeatureOn(.sync) }
    var shouldShowLoginsCell: Bool { featureFlagger.isFeatureOn(.autofillAccessCredentialManagement) }
    var shouldShowTextSizeCell: Bool { !isPad }
    var shouldShowVoiceSearchCell: Bool { AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable }
    var shouldShowAddressBarPositionCell: Bool { !isPad }
    var shouldShowSpeechRecognitionCell: Bool { AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable }
    var shouldShowNoMicrophonePermissionAlert: Bool = false
    // var shouldShowDebugCell: Bool { isFeatureAvailable(.networkProtection) }
    
    var shouldShowNetworkProtectionCell: Bool {
#if NETWORK_PROTECTION
        if #available(iOS 15, *) {
            print(featureFlagger.isFeatureOn(.networkProtection))
            return featureFlagger.isFeatureOn(.networkProtection)
        } else {
            return false
        }
#else
        return false
#endif
    }
    
    // MARK: Bindings
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.appeareance.appTheme },
            set: {
                self.state.appeareance.appTheme = $0
                self.appSettings.currentThemeName = $0
                ThemeManager.shared.enableTheme(with: $0)
                ThemeManager.shared.updateUserInterfaceStyle()
            }
        )
    }
    var fireButtonAnimationBinding: Binding<FireButtonAnimationType> {
        Binding<FireButtonAnimationType>(
            get: { self.state.appeareance.fireButtonAnimation },
            set: {
                self.appSettings.currentFireButtonAnimation = $0
                self.state.appeareance.fireButtonAnimation = $0
                NotificationCenter.default.post(name: AppUserDefaults.Notifications.currentFireButtonAnimationChange, object: self)
                self.animator.animate {
                    // no op
                } onTransitionCompleted: {
                    // no op
                } completion: {
                    // no op
                }
            }
        )
    }
    var addressBarPositionBinding: Binding<AddressBarPosition> {
        Binding<AddressBarPosition>(
            get: {
                self.state.appeareance.addressBarPosition
            },
            set: {
                self.appSettings.currentAddressBarPosition = $0
                self.state.appeareance.addressBarPosition = $0
            }
        )
    }
    var applicationLockBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.privacy.applicationLock },
            set: {
                self.privacyStore.authenticationEnabled = $0
                self.state.privacy.applicationLock = $0
            }
        )
    }
    var autocompleteBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.customization.autocomplete },
            set: {
                self.appSettings.autocomplete = $0
                self.state.customization.autocomplete = $0
            }
        )
    }
    var voiceSearchEnabledBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.customization.voiceSearchEnabled },
            set: { value in
                if value {
                    self.enableVoiceSearch { [weak self] result in
                        DispatchQueue.main.async {
                            self?.state.customization.voiceSearchEnabled = result
                            self?.appSettings.voiceSearchEnabled = result
                            if !result {
                                // Permission is denied
                                self?.shouldShowNoMicrophonePermissionAlert = true
                            }
                        }
                    }
                } else {
                    self.appSettings.voiceSearchEnabled = false
                    self.state.customization.voiceSearchEnabled = false
                }
            }
        )
    }
    var longPressBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.customization.longPressPreviews },
            set: {
                self.appSettings.longPressPreviews = $0
                self.state.customization.longPressPreviews = $0
            }
        )
    }
    
    var universalLinksBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.customization.allowUniversalLinks },
            set: {
                self.appSettings.allowUniversalLinks = $0
                self.state.customization.allowUniversalLinks = $0
            }
        )
    }

    // MARK: Default Init
    init(state: SettingsState? = nil, legacyViewProvider: SettingsLegacyViewProvider) {
        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
    }
}
 
// MARK: Private methods
extension SettingsViewModel {
    
    // This manual (re)initialzation will go away once appSettings and
    // other dependencies are observable (Such as AppIcon and netP)
    // and we can use subscribers (Currently called from the view onAppear)
    private func initState() {
        let appereance = SettingsStateAppeareance(appTheme: appSettings.currentThemeName,
                                                  appIcon: AppIconManager.shared.appIcon,
                                                  fireButtonAnimation: appSettings.currentFireButtonAnimation,
                                                  textSize: appSettings.textSize,
                                                  addressBarPosition: appSettings.currentAddressBarPosition)
        
        let privacy = SettingsStatePrivacy(sendDoNotSell: appSettings.sendDoNotSell,
                                           autoconsentEnabled: appSettings.autoconsentEnabled,
                                           autoclearDataEnabled: AutoClearSettingsModel(settings: appSettings) != nil,
                                           applicationLock: privacyStore.authenticationEnabled)
        
        let customization = SettingsStateCustomization(autocomplete: appSettings.autocomplete,
                                                       voiceSearchEnabled: appSettings.voiceSearchEnabled && AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable,
                                                       longPressPreviews: appSettings.longPressPreviews,
                                                       allowUniversalLinks: appSettings.allowUniversalLinks)
        
        self.state = SettingsState(appeareance: appereance,
                             privacy: privacy,
                             customization: customization,
                             logins: SettingsStateLogins.defaults,
                             netP: SettingsStateNetP.defaults)
        
        setupSubscribers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.onRequestDismissLegacyView?()
        }
        
    }
        
    private func firePixel(_ event: Pixel.Event) {
        Pixel.fire(pixel: event)
    }
    
    private func enableVoiceSearch(completion: @escaping (Bool) -> Void) {
        SpeechRecognizer.requestMicAccess { permission in
            if !permission {
                completion(false)
                return
            }
            AppDependencyProvider.shared.voiceSearchHelper.enableVoiceSearch(true)
            completion(true)
        }
    }
    
#if NETWORK_PROTECTION
    private func updateNetPCellSubtitle(connectionStatus: ConnectionStatus) {
        switch NetworkProtectionAccessController().networkProtectionAccessType() {
        case .none, .waitlistAvailable, .waitlistJoined, .waitlistInvitedPendingTermsAcceptance:
            self.state.netP.subtitle = VPNWaitlist.shared.settingsSubtitle
        case .waitlistInvited, .inviteCodeInvited:
            switch connectionStatus {
            case .connected:
                self.state.netP.subtitle = UserText.netPCellConnected
            default:
                self.state.netP.subtitle = UserText.netPCellDisconnected
            }
        }
    }
#endif
}

// MARK: Subscribers
extension SettingsViewModel {
    
    private func setupSubscribers() {

#if NETWORK_PROTECTION
        connectionObserver.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateNetPCellSubtitle(connectionStatus: status)
            }
            .store(in: &cancellables)
#endif
        
    }
}

// MARK: Public Methods
extension SettingsViewModel {
    
    func onAppear() {
        initState()
    }
    
    func setAsDefaultBrowser() {
        firePixel(.defaultBrowserButtonPressedSettings)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func shouldPresentLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.logins.activeWebsiteAccount = accountDetails
    }
    
    func openEmailProtection() {
        UIApplication.shared.open(URL.emailProtectionQuickLink,
                                  options: [:],
                                  completionHandler: nil)
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
             keyboard,
             macApp,
             windowsApp
    }
    
    @MainActor
    func presentLegacyView(_ view: LegacyView) {
        switch view {
        
        case .addToDock:
            presentLegacyView(legacyViewProvider.addToDock, modal: true)
        
        case .sync:
            pushLegacyView(legacyViewProvider.syncSettings)
        
        case .logins:
            firePixel(.autofillSettingsOpened)
            pushLegacyView(legacyViewProvider.loginSettings(delegate: self,
                                                            selectedAccount: state.logins.activeWebsiteAccount))

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
        
        case .windowsApp:
            pushLegacyView(legacyViewProvider.mac)
        
        case .macApp:
            pushLegacyView(legacyViewProvider.mac)
        }
    }
        
    private func pushLegacyView(_ view: UIViewController) {
        onRequestPushLegacyView?(view)
    }
    
    private func presentLegacyView(_ view: UIViewController, modal: Bool) {
        onRequestPresentLegacyView?(view, modal)
    }
    
}

// MARK: Old stuff from SettingsViewController
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

// MARK: AutofillLoginSettingsListViewControllerDelegate
extension SettingsViewModel: AutofillLoginSettingsListViewControllerDelegate {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController) {
        onRequestDismissLegacyView?()
    }
}
