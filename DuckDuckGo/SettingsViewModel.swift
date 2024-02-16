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
// swiftlint:disable file_length
import Core
import BrowserServicesKit
import Persistence
import SwiftUI
import Common
import Combine
import SyncUI

#if SUBSCRIPTION
import Subscription
#endif

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
    private lazy var versionProvider: AppVersion = AppVersion.shared
    private let voiceSearchHelper: VoiceSearchHelperProtocol
#if SUBSCRIPTION
    private var accountManager: AccountManager
#endif
    
    
#if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
#endif
    
    // Properties
    private lazy var isPad = UIDevice.current.userInterfaceIdiom == .pad
    private var cancellables = Set<AnyCancellable>()
    
    // Defaults
    @UserDefaultsWrapper(key: .subscriptionIsActive, defaultValue: false)
    static private var cachedHasActiveSubscription: Bool
    
    // Closures to interact with legacy view controllers through the container
    var onRequestPushLegacyView: ((UIViewController) -> Void)?
    var onRequestPresentLegacyView: ((UIViewController, _ modal: Bool) -> Void)?
    var onRequestPopLegacyView: (() -> Void)?
    var onRequestDismissSettings: (() -> Void)?
    
    // SwiftUI Programatic Navigation Variables
    // Add more views as needed here...
    @Published var shouldNavigateToDBP = false
    @Published var shouldNavigateToITP = false
    
    // Subscription Entitlement names: TBD
    static let entitlementNames = ["dummy1", "dummy2", "dummy3"]
    
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
    
    var shouldShowNoMicrophonePermissionAlert: Bool = false
    
    // Used to automatically navigate on Appear to a specific section
    enum SettingsSection: String {
        case none, netP, dbp, itr
    }
    
    @Published var onAppearNavigationTarget: SettingsSection
    
    // MARK: Bindings
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.appTheme },
            set: {
                self.state.appTheme = $0
                self.appSettings.currentThemeName = $0
                ThemeManager.shared.enableTheme(with: $0)
                ThemeManager.shared.updateUserInterfaceStyle()
            }
        )
    }
    var fireButtonAnimationBinding: Binding<FireButtonAnimationType> {
        Binding<FireButtonAnimationType>(
            get: { self.state.fireButtonAnimation },
            set: {
                self.appSettings.currentFireButtonAnimation = $0
                self.state.fireButtonAnimation = $0
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
                self.state.addressbar.position
            },
            set: {
                self.appSettings.currentAddressBarPosition = $0
                self.state.addressbar.position = $0
            }
        )
    }
    var applicationLockBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.applicationLock },
            set: {
                self.privacyStore.authenticationEnabled = $0
                self.state.applicationLock = $0
            }
        )
    }
    var autocompleteBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.autocomplete },
            set: {
                self.appSettings.autocomplete = $0
                self.state.autocomplete = $0
            }
        )
    }
    var voiceSearchEnabledBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.voiceSearchEnabled },
            set: { value in
                if value {
                    self.enableVoiceSearch { [weak self] result in
                        DispatchQueue.main.async {
                            self?.state.voiceSearchEnabled = result
                            self?.voiceSearchHelper.enableVoiceSearch(true)
                            if !result {
                                // Permission is denied
                                self?.shouldShowNoMicrophonePermissionAlert = true
                            }
                        }
                    }
                } else {
                    self.voiceSearchHelper.enableVoiceSearch(false)
                    self.state.voiceSearchEnabled = false
                }
            }
        )
    }
    var longPressBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.longPressPreviews },
            set: {
                self.appSettings.longPressPreviews = $0
                self.state.longPressPreviews = $0
            }
        )
    }
    
    var universalLinksBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.allowUniversalLinks },
            set: {
                self.appSettings.allowUniversalLinks = $0
                self.state.allowUniversalLinks = $0
            }
        )
    }
#if SUBSCRIPTION
    // MARK: Default Init
    init(state: SettingsState? = nil,
         legacyViewProvider: SettingsLegacyViewProvider,
         accountManager: AccountManager,
         voiceSearchHelper: VoiceSearchHelperProtocol = AppDependencyProvider.shared.voiceSearchHelper,
         navigateOnAppearDestination: SettingsSection = .none) {
        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
        self.accountManager = accountManager
        self.voiceSearchHelper = voiceSearchHelper
        self.onAppearNavigationTarget = navigateOnAppearDestination
    }
#else
    // MARK: Default Init
    init(state: SettingsState? = nil,
         legacyViewProvider: SettingsLegacyViewProvider,
         voiceSearchHelper: VoiceSearchHelperProtocol = AppDependencyProvider.shared.voiceSearchHelper,
         navigateOnAppearDestination: SettingsSection = .none) {
        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
        self.voiceSearchHelper = voiceSearchHelper
        self.onAppearNavigationTarget = navigateOnAppearDestination
    }
#endif
    
}
// MARK: Private methods
extension SettingsViewModel {
    
    // This manual (re)initialzation will go away once appSettings and
    // other dependencies are observable (Such as AppIcon and netP)
    // and we can use subscribers (Currently called from the view onAppear)
    private func initState() {
        self.state = SettingsState(
            appTheme: appSettings.currentThemeName,
            appIcon: AppIconManager.shared.appIcon,
            fireButtonAnimation: appSettings.currentFireButtonAnimation,
            textSize: SettingsState.TextSize(enabled: !isPad, size: appSettings.textSize),
            addressbar: SettingsState.AddressBar(enabled: !isPad, position: appSettings.currentAddressBarPosition),
            sendDoNotSell: appSettings.sendDoNotSell,
            autoconsentEnabled: appSettings.autoconsentEnabled,
            autoclearDataEnabled: AutoClearSettingsModel(settings: appSettings) != nil,
            applicationLock: privacyStore.authenticationEnabled,
            autocomplete: appSettings.autocomplete,
            longPressPreviews: appSettings.longPressPreviews,
            allowUniversalLinks: appSettings.allowUniversalLinks,
            activeWebsiteAccount: nil,
            version: versionProvider.versionAndBuildNumber,
            debugModeEnabled: featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild,
            voiceSearchEnabled: AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled,
            speechRecognitionAvailable: AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable,
            loginsEnabled: featureFlagger.isFeatureOn(.autofillAccessCredentialManagement),
            networkProtection: getNetworkProtectionState(),
            subscription: getSubscriptionState(),
            sync: getSyncState()
        )
        
        setupSubscribers()
        
        #if SUBSCRIPTION
        if #available(iOS 15, *) {
            Task {
                if state.subscription.enabled {
                    await setupSubscriptionEnvironment()
                }
            }
        }
        #endif
    }
    
    private func getNetworkProtectionState() -> SettingsState.NetworkProtection {
        var enabled = false
        #if NETWORK_PROTECTION
            if #available(iOS 15, *) {
                let accessController = NetworkProtectionAccessController()
                enabled = accessController.networkProtectionAccessType() != .none
            }
        #endif
        return SettingsState.NetworkProtection(enabled: enabled, status: "")
    }
    
    private func getSubscriptionState() -> SettingsState.Subscription {
        var enabled = false
        var canPurchase = false
        let hasActiveSubscription = Self.cachedHasActiveSubscription
        #if SUBSCRIPTION
            enabled = featureFlagger.isFeatureOn(.subscription)
            canPurchase = SubscriptionPurchaseEnvironment.canPurchase
        #endif
        return SettingsState.Subscription(enabled: enabled,
                                        canPurchase: canPurchase,
                                        hasActiveSubscription: hasActiveSubscription)
    }
    
    private func getSyncState() -> SettingsState.SyncSettings {
        SettingsState.SyncSettings(enabled: legacyViewProvider.syncService.featureFlags.contains(.userInterface),
                                 title: {
                                     let syncService = legacyViewProvider.syncService
                                     let isDataSyncingDisabled = !syncService.featureFlags.contains(.dataSyncing)
                                      && syncService.authState == .active
                                     if SyncBookmarksAdapter.isSyncBookmarksPaused
                                         || SyncCredentialsAdapter.isSyncCredentialsPaused
                                         || isDataSyncingDisabled {
                                         return "⚠️ \(UserText.settingsSync)"
                                     }
                                     return SyncUI.UserText.syncTitle
                                 }())
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
            completion(true)
        }
    }

    #if SUBSCRIPTION
    @available(iOS 15.0, *)
    @MainActor
    private func setupSubscriptionEnvironment() async {
        
        // Active subscription check
        if let token = accountManager.accessToken {
            
            // Fetch available subscriptions from the backend (or sign out)
            if case .success(let response) = await SubscriptionService.getSubscriptionDetails(token: token) {
                if !response.isSubscriptionActive {
                    AccountManager().signOut()
                    setupSubscriptionPurchaseOptions()
                    return
                }
                
                // Check for valid entitlements
                let hasEntitlements = await AccountManager().hasEntitlement(for: Self.entitlementNames.first!)
                self.state.subscription.hasActiveSubscription = hasEntitlements ? true : false
                
                // Cache Subscription state
                Self.cachedHasActiveSubscription = self.state.subscription.hasActiveSubscription
                
                // Enable Subscription purchase if there's no active subscription
                if self.state.subscription.hasActiveSubscription == false {
                    setupSubscriptionPurchaseOptions()
                }
            }
        } else {
            setupSubscriptionPurchaseOptions()
        }
    }
    
    @available(iOS 15.0, *)
    private func setupSubscriptionPurchaseOptions() {
        self.state.subscription.hasActiveSubscription = false
        PurchaseManager.shared.$availableProducts
            .receive(on: RunLoop.main)
            .sink { [weak self] products in
                self?.state.subscription.canPurchase = !products.isEmpty
            }.store(in: &cancellables)
    }
    #endif
    
    #if NETWORK_PROTECTION
    private func updateNetPStatus(connectionStatus: ConnectionStatus) {
        switch NetworkProtectionAccessController().networkProtectionAccessType() {
        case .none, .waitlistAvailable, .waitlistJoined, .waitlistInvitedPendingTermsAcceptance:
            self.state.networkProtection.status = VPNWaitlist.shared.settingsSubtitle
        case .waitlistInvited, .inviteCodeInvited:
            switch connectionStatus {
            case .connected:
                self.state.networkProtection.status = UserText.netPCellConnected
            default:
                self.state.networkProtection.status = UserText.netPCellDisconnected
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
            .sink { [weak self] hasActiveSubscription in
                self?.updateNetPStatus(connectionStatus: hasActiveSubscription)
            }
            .store(in: &cancellables)
    #endif

    }
}

// MARK: Public Methods
extension SettingsViewModel {
    
    func onAppear() {
        initState()
        Task { await MainActor.run { navigateOnAppear() } }
    }
    
    func setAsDefaultBrowser() {
        firePixel(.defaultBrowserButtonPressedSettings)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    @MainActor func shouldPresentLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.activeWebsiteAccount = accountDetails
        presentLegacyView(.logins)
    }
    
    func openEmailProtection() {
        UIApplication.shared.open(URL.emailProtectionQuickLink,
                                  options: [:],
                                  completionHandler: nil)
    }
        
    @MainActor func openCookiePopupManagement() {
        pushViewController(legacyViewProvider.autoConsent)
    }
    
    @MainActor func dismissSettings() {
        onRequestDismissSettings?()
    }

    @MainActor
    private func navigateOnAppear() {
        // We need a short delay to let the SwifttUI view lifecycle complete
        // Otherwise the transition can be inconsistent
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            switch self.onAppearNavigationTarget {
            case .netP:
                self.presentLegacyView(.netP)
            case .dbp:
                self.shouldNavigateToDBP = true
            case .itr:
                self.shouldNavigateToITP = true
            default:
                break
            }
            self.onAppearNavigationTarget = .none
        }
    }

}

// MARK: Legacy View Presentation
// Some UIKit views have visual issues when presented via UIHostingController so
// for all existing subviews, default to UIKit based presentation until we
// can review and migrate
extension SettingsViewModel {
    
    // swiftlint:disable:next cyclomatic_complexity
    @MainActor func presentLegacyView(_ view: SettingsLegacyViewProvider.LegacyView) {
        
        switch view {
        
        case .addToDock: presentViewController(legacyViewProvider.addToDock, modal: true)
        case .sync: pushViewController(legacyViewProvider.syncSettings)
        case .appIcon: pushViewController(legacyViewProvider.appIcon)
        case .unprotectedSites: pushViewController(legacyViewProvider.unprotectedSites)
        case .fireproofSites: pushViewController(legacyViewProvider.fireproofSites)
        case .autoclearData: pushViewController(legacyViewProvider.autoclearData)
        case .keyboard: pushViewController(legacyViewProvider.keyboard)
        case .about: pushViewController(legacyViewProvider.about)
        case .debug: pushViewController(legacyViewProvider.debug)
            
        case .feedback:
            presentViewController(legacyViewProvider.feedback, modal: false)
        case .logins:
            firePixel(.autofillSettingsOpened)
            pushViewController(legacyViewProvider.loginSettings(delegate: self,
                                                            selectedAccount: state.activeWebsiteAccount))

        case .textSize:
            firePixel(.textSizeSettingsShown)
            pushViewController(legacyViewProvider.textSettings)

        case .gpc:
            firePixel(.settingsDoNotSellShown)
            pushViewController(legacyViewProvider.gpc)
        
        case .autoconsent:
            firePixel(.settingsAutoconsentShown)
            pushViewController(legacyViewProvider.autoConsent)
     
#if NETWORK_PROTECTION
        case .netP:
            if #available(iOS 15, *) {
                switch NetworkProtectionAccessController().networkProtectionAccessType() {
                case .inviteCodeInvited, .waitlistInvited:
                    pushViewController(legacyViewProvider.netP)
                default:
                    pushViewController(legacyViewProvider.netPWaitlist)
                }
            }
#endif
        
        }
    }
 
    @MainActor
    private func pushViewController(_ view: UIViewController) {
        onRequestPushLegacyView?(view)
    }
    
    @MainActor
    private func presentViewController(_ view: UIViewController, modal: Bool) {
        onRequestPresentLegacyView?(view, modal)
    }
    
}

// MARK: AutofillLoginSettingsListViewControllerDelegate
extension SettingsViewModel: AutofillLoginSettingsListViewControllerDelegate {
    
    @MainActor
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController) {
        onRequestPopLegacyView?()
    }
}
// swiftlint:enable file_length
