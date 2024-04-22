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

import Subscription

#if APP_TRACKING_PROTECTION
import NetworkExtension
#endif

#if NETWORK_PROTECTION
import NetworkProtection
#endif

// swiftlint:disable type_body_length
final class SettingsViewModel: ObservableObject {

    
    // Dependencies
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings
    private(set) var privacyStore = PrivacyUserDefaults()
    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    private var legacyViewProvider: SettingsLegacyViewProvider
    private lazy var versionProvider: AppVersion = AppVersion.shared
    private let voiceSearchHelper: VoiceSearchHelperProtocol
    var emailManager: EmailManager { EmailManager() }

    // Subscription Dependencies
    private var subscriptionAccountManager: AccountManager
    private var subscriptionSignOutObserver: Any?
    
    // Used to cache the lasts subscription state for up to a week
    private var subscriptionStateCache = UserDefaultsCache<SettingsState.Subscription>(key: UserDefaultsCacheKey.subscriptionState,
                                                                         settings: UserDefaultsCacheSettings(defaultExpirationInterval: .days(7)))
    
#if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
#endif
    
    // Properties
    private lazy var isPad = UIDevice.current.userInterfaceIdiom == .pad
    private var cancellables = Set<AnyCancellable>()
    
    // Closures to interact with legacy view controllers through the container
    var onRequestPushLegacyView: ((UIViewController) -> Void)?
    var onRequestPresentLegacyView: ((UIViewController, _ modal: Bool) -> Void)?
    var onRequestPopLegacyView: (() -> Void)?
    var onRequestDismissSettings: (() -> Void)?
    
    // View State
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
    @Published var shouldShowEmailAlert: Bool = false
    var autocompleteSubtitle: String?
    
    // MARK: - Deep linking
    // Used to automatically navigate to a specific section
    // immediately after loading the Settings View
    @Published private(set) var deepLinkTarget: SettingsDeepLinkSection?
    
    // MARK: Bindings
    
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.appTheme },
            set: {
                self.state.appTheme = $0
                ThemeManager.shared.enableTheme(with: $0)
                Pixel.fire(pixel: .settingsThemeSelectorPressed, withAdditionalParameters: PixelExperiment.parameters)
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
                Pixel.fire(pixel: .settingsFireButtonSelectorPressed,
                           withAdditionalParameters: PixelExperiment.parameters)
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
                if $0 == .top {
                    Pixel.fire(pixel: .settingsAddressBarTopSelected,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsAddressBarBottomSelected,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    var addressBarShowsFullURL: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.showsFullURL },
            set: {
                self.state.showsFullURL = $0
                self.appSettings.showFullSiteAddress = $0
                if $0 {
                    Pixel.fire(pixel: .settingsShowFullSiteAddressEnabled,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsShowFullSiteAddressDisabled,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
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
                if $0 {
                    Pixel.fire(pixel: .settingsAutocompleteOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsAutocompleteOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    // Remove after Settings experiment
    var autocompletePrivateSearchBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.autocomplete },
            set: {
                self.appSettings.autocomplete = $0
                self.state.autocomplete = $0
                if $0 {
                    Pixel.fire(pixel: .settingsPrivateSearchAutocompleteOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsPrivateSearchAutocompleteOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    // Remove after Settings experiment
    var autocompleteGeneralBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.autocomplete },
            set: {
                self.appSettings.autocomplete = $0
                self.state.autocomplete = $0
                if $0 {
                    Pixel.fire(pixel: .settingsGeneralAutocompleteOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsGeneralAutocompleteOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    var gpcBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.sendDoNotSell },
            set: {
                self.appSettings.sendDoNotSell = $0
                self.state.sendDoNotSell = $0
                NotificationCenter.default.post(name: AppUserDefaults.Notifications.doNotSellStatusChange, object: nil)
                if $0 {
                    Pixel.fire(pixel: .settingsGpcOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsGpcOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    var autoconsentBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.autoconsentEnabled },
            set: {
                self.appSettings.autoconsentEnabled = $0
                self.state.autoconsentEnabled = $0
                if $0 {
                    Pixel.fire(pixel: .settingsAutoconsentOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsAutoconsentOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    var voiceSearchEnabledBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.voiceSearchEnabled },
            set: { newValue in
                self.setVoiceSearchEnabled(to: newValue)
                if newValue {
                    Pixel.fire(pixel: .settingsVoiceSearchOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsVoiceSearchOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    // Remove after Settings experiment
    var voiceSearchEnabledPrivateSearchBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.voiceSearchEnabled },
            set: { newValue in
                self.setVoiceSearchEnabled(to: newValue)
                if newValue {
                    Pixel.fire(pixel: .settingsPrivateSearchVoiceSearchOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsPrivateSearchVoiceSearchOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    // Remove after Settings experiment
    var voiceSearchEnabledGeneralBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.voiceSearchEnabled },
            set: { newValue in
                self.setVoiceSearchEnabled(to: newValue)
                if newValue {
                    Pixel.fire(pixel: .settingsGeneralVoiceSearchOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsGeneralVoiceSearchOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    // Remove after Settings experiment
    var voiceSearchEnabledAccessibilityBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.voiceSearchEnabled },
            set: { newValue in
                self.setVoiceSearchEnabled(to: newValue)
                if newValue {
                    Pixel.fire(pixel: .settingsAccessibilityVoiceSearchOn,
                               withAdditionalParameters: PixelExperiment.parameters)
                } else {
                    Pixel.fire(pixel: .settingsAccessibilityVoiceSearchOff,
                               withAdditionalParameters: PixelExperiment.parameters)
                }
            }
        )
    }

    func setVoiceSearchEnabled(to value: Bool) {
        if value {
            enableVoiceSearch { [weak self] result in
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
            voiceSearchHelper.enableVoiceSearch(false)
            state.voiceSearchEnabled = false
        }
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

    var crashCollectionOptInStatusBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.crashCollectionOptInStatus == .optedIn },
            set: {
                self.appSettings.crashCollectionOptInStatus = $0 ? .optedIn : .optedOut
                self.state.crashCollectionOptInStatus = $0 ? .optedIn : .optedOut
            }
        )
    }

    var cookiePopUpProtectionStatus: StatusIndicator {
        return appSettings.autoconsentEnabled ? .on : .off
    }
    
    var emailProtectionStatus: StatusIndicator {
        return emailManager.isSignedIn ? .on : .off
    }
    
    var syncStatus: StatusIndicator {
        legacyViewProvider.syncService.authState != .inactive ? .on : .off
    }
    
    // MARK: Default Init
    init(state: SettingsState? = nil,
         legacyViewProvider: SettingsLegacyViewProvider,
         accountManager: AccountManager,
         voiceSearchHelper: VoiceSearchHelperProtocol = AppDependencyProvider.shared.voiceSearchHelper,
         variantManager: VariantManager = AppDependencyProvider.shared.variantManager,
         deepLink: SettingsDeepLinkSection? = nil) {
        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
        self.subscriptionAccountManager = accountManager
        self.voiceSearchHelper = voiceSearchHelper
        self.deepLinkTarget = deepLink
        
        setupNotificationObservers()
        autocompleteSubtitle = variantManager.isSupported(feature: .history) ? UserText.settingsAutocompleteSubtitle : nil
    }
    
    deinit {
        subscriptionSignOutObserver = nil
    }
}
// swiftlint:enable type_body_length

// MARK: Private methods
extension SettingsViewModel {
    
    // This manual (re)initialization will go away once appSettings and
    // other dependencies are observable (Such as AppIcon and netP)
    // and we can use subscribers (Currently called from the view onAppear)
    @MainActor
    private func initState() {
        self.state = SettingsState(
            appTheme: appSettings.currentThemeName,
            appIcon: AppIconManager.shared.appIcon,
            fireButtonAnimation: appSettings.currentFireButtonAnimation,
            textSize: SettingsState.TextSize(enabled: !isPad, size: appSettings.textSize),
            addressbar: SettingsState.AddressBar(enabled: !isPad, position: appSettings.currentAddressBarPosition),
            showsFullURL: appSettings.showFullSiteAddress,
            sendDoNotSell: appSettings.sendDoNotSell,
            autoconsentEnabled: appSettings.autoconsentEnabled,
            autoclearDataEnabled: AutoClearSettingsModel(settings: appSettings) != nil,
            applicationLock: privacyStore.authenticationEnabled,
            autocomplete: appSettings.autocomplete,
            longPressPreviews: appSettings.longPressPreviews,
            allowUniversalLinks: appSettings.allowUniversalLinks,
            activeWebsiteAccount: nil,
            version: versionProvider.versionAndBuildNumber,
            crashCollectionOptInStatus: appSettings.crashCollectionOptInStatus,
            debugModeEnabled: featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild,
            voiceSearchEnabled: AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled,
            speechRecognitionAvailable: AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable,
            loginsEnabled: featureFlagger.isFeatureOn(.autofillAccessCredentialManagement),
            networkProtection: getNetworkProtectionState(),
            subscription: SettingsState.defaults.subscription,
            sync: getSyncState()
        )
        
        setupSubscribers()
        Task { await setupSubscriptionEnvironment() }
        
    }
    
    private func getNetworkProtectionState() -> SettingsState.NetworkProtection {
        var enabled = false
#if NETWORK_PROTECTION
        if #available(iOS 15, *) {
            enabled = DefaultNetworkProtectionVisibility().shouldKeepVPNAccessViaWaitlist()
        }
#endif
        return SettingsState.NetworkProtection(enabled: enabled, status: "")
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
    
    private func firePixel(_ event: Pixel.Event,
                           withAdditionalParameters params: [String: String] = [:]) {
        Pixel.fire(pixel: event, withAdditionalParameters: params)
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
    
    
#if NETWORK_PROTECTION
    private func updateNetPStatus(connectionStatus: ConnectionStatus) {
        if DefaultNetworkProtectionVisibility().isPrivacyProLaunched() {
            switch connectionStatus {
            case .connected:
                self.state.networkProtection.status = UserText.netPCellConnected
            default:
                self.state.networkProtection.status = UserText.netPCellDisconnected
            }
        } else {
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
        Task {
            await initState()
            triggerDeepLinkNavigation(to: self.deepLinkTarget)
        }
    }
    
    func onDisappear() {
        self.deepLinkTarget = nil
    }
    
    func setAsDefaultBrowser() {
        Pixel.fire(pixel: .settingsSetAsDefault,
                   withAdditionalParameters: PixelExperiment.parameters)
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

    func openEmailAccountManagement() {
        UIApplication.shared.open(URL.emailProtectionAccountLink,
                                  options: [:],
                                  completionHandler: nil)
    }

    func openEmailSupport() {
        UIApplication.shared.open(URL.emailProtectionSupportLink,
                                  options: [:],
                                  completionHandler: nil)
    }

    func openOtherPlatforms() {
        UIApplication.shared.open(URL.apps,
                                  options: [:],
                                  completionHandler: nil)
    }

    func openMoreSearchSettings() {
        UIApplication.shared.open(URL.searchSettings,
                                  options: [:],
                                  completionHandler: nil)
    }

    @MainActor func openCookiePopupManagement() {
        pushViewController(legacyViewProvider.autoConsent)
    }
    
    @MainActor func dismissSettings() {
        onRequestDismissSettings?()
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
        
        case .addToDock:
            firePixel(.settingsNextStepsAddAppToDock,
                      withAdditionalParameters: PixelExperiment.parameters)
            presentViewController(legacyViewProvider.addToDock, modal: true)
        case .sync:
            firePixel(.settingsSyncOpen,
                      withAdditionalParameters: PixelExperiment.parameters)
            pushViewController(legacyViewProvider.syncSettings)
        case .appIcon: pushViewController(legacyViewProvider.appIcon)
        case .unprotectedSites: pushViewController(legacyViewProvider.unprotectedSites)
        case .fireproofSites: pushViewController(legacyViewProvider.fireproofSites)
        case .autoclearData:
            firePixel(.settingsAutomaticallyClearDataOpen, withAdditionalParameters: PixelExperiment.parameters)
            pushViewController(legacyViewProvider.autoclearData)
        case .keyboard: pushViewController(legacyViewProvider.keyboard)
        case .about: pushViewController(legacyViewProvider.about)
        case .debug: pushViewController(legacyViewProvider.debug)
            
        case .feedback:
            presentViewController(legacyViewProvider.feedback, modal: false)
        case .logins:
            firePixel(.autofillSettingsOpened, withAdditionalParameters: PixelExperiment.parameters)
            pushViewController(legacyViewProvider.loginSettings(delegate: self,
                                                            selectedAccount: state.activeWebsiteAccount))

        case .textSize:
            firePixel(.settingsAccessiblityTextSize,
                      withAdditionalParameters: PixelExperiment.parameters)
            pushViewController(legacyViewProvider.textSettings)

        case .gpc:
            firePixel(.settingsDoNotSellShown)
            pushViewController(legacyViewProvider.gpc)
        
        case .autoconsent:
            pushViewController(legacyViewProvider.autoConsent)
     
#if NETWORK_PROTECTION
        case .netP:
            if #available(iOS 15, *) {
                firePixel(.privacyProVPNSettings,
                          withAdditionalParameters: PixelExperiment.parameters)
                pushViewController(legacyViewProvider.netP)
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

// MARK: DeepLinks
extension SettingsViewModel {

    enum SettingsDeepLinkSection: Identifiable {
        case netP
        case dbp
        case itr
        case subscriptionFlow
        case subscriptionRestoreFlow
        // Add other cases as needed

        var id: String {
            switch self {
            case .netP: return "netP"
            case .dbp: return "dbp"
            case .itr: return "itr"
            case .subscriptionFlow: return "subscriptionFlow"
            case .subscriptionRestoreFlow: return "subscriptionRestoreFlow"
            // Ensure all cases are covered
            }
        }

        // Define the presentation type: .sheet or .push
        // Default to .sheet, specify .push where needed
        var type: DeepLinkType {
            switch self {
            // Specify cases that require .push presentation
            // Example:
            // case .dbp:
            //     return .sheet
            case .netP:
                return .UIKitView
            default:
                return .navigationLink
            }
        }
    }

    // Define DeepLinkType outside the enum if not already defined
    enum DeepLinkType {
        case sheet
        case navigationLink
        case UIKitView
    }
            
    // Navigate to a section in settings
    func triggerDeepLinkNavigation(to target: SettingsDeepLinkSection?) {
        guard let target else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.deepLinkTarget = target
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.deepLinkTarget = nil
            }
        }
    }
}

// MARK: Subscriptions
extension SettingsViewModel {

    @MainActor
    private func setupSubscriptionEnvironment() async {
        
        // If there's cached data use it by default
        if let cachedSubscription = subscriptionStateCache.get() {
            state.subscription = cachedSubscription
            
        // Otherwise use defaults and setup purchase availability
        } else {
            state.subscription = SettingsState.defaults.subscription
            state.subscription.canPurchase = SubscriptionPurchaseEnvironment.canPurchase
        }
        
        // Update visibility based on Feature flag
        state.subscription.enabled = AppDependencyProvider.shared.subscriptionFeatureAvailability.isFeatureAvailable
        
        // Active subscription check
        guard let token = subscriptionAccountManager.accessToken else {
            subscriptionStateCache.set(state.subscription) // Sync cache
            return
        }
        
        let subscriptionResult = await SubscriptionService.getSubscription(accessToken: token)
        switch subscriptionResult {
            
        case .success(let subscription):
            
            state.subscription.isSignedIn = true
            state.subscription.platform = subscription.platform
            
            if subscription.isActive {
                state.subscription.hasActiveSubscription = true
                
                // Check entitlements and update state
                let entitlements: [Entitlement.ProductName] = [.networkProtection, .dataBrokerProtection, .identityTheftRestoration]
                for entitlement in entitlements {
                    if case .success = await AccountManager().hasEntitlement(for: entitlement) {
                        switch entitlement {
                        case .identityTheftRestoration:
                            self.state.subscription.entitlements.append(.identityTheftRestoration)
                        case .dataBrokerProtection:
                            self.state.subscription.entitlements.append(.dataBrokerProtection)
                        case .networkProtection:
                            self.state.subscription.entitlements.append(.networkProtection)
                        case .unknown:
                            return
                        }
                    }
                }
            } else {
                // Mark the subscription as 'inactive' 
                state.subscription.hasActiveSubscription = false
            }
            
        case .failure:
            break
            
        }
        
        // Sync Cache
        subscriptionStateCache.set(state.subscription)
    }
    
    private func setupNotificationObservers() {
        subscriptionSignOutObserver = NotificationCenter.default.addObserver(forName: .accountDidSignOut,
                                                                             object: nil,
                                                                             queue: .main) { [weak self] _ in
            if #available(iOS 15.0, *) {
                guard let strongSelf = self else { return }
                Task {
                    strongSelf.subscriptionStateCache.reset()
                    await strongSelf.setupSubscriptionEnvironment()
                }
            }
        }
    }
    
    @available(iOS 15.0, *)
    func restoreAccountPurchase() async {
        DispatchQueue.main.async { self.state.subscription.isRestoring = true }
        let result = await AppStoreRestoreFlow.restoreAccountFromPastPurchase(subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs))
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.state.subscription.isRestoring = false
            }
            await self.setupSubscriptionEnvironment()
            
        case .failure:
            DispatchQueue.main.async {
                self.state.subscription.isRestoring = false
                self.state.subscription.shouldDisplayRestoreSubscriptionError = true
                self.state.subscription.shouldDisplayRestoreSubscriptionError = false
                
            }
        }
    }
    
}
// swiftlint:enable file_length
