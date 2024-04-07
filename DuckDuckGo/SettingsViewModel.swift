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
    private var signOutObserver: Any?
    private var isPrivacyProEnabled: Bool {
        AppDependencyProvider.shared.subscriptionFeatureAvailability.isFeatureAvailable
    }
    // Cache subscription state in memory to prevent UI glitches
    private var cacheSubscriptionState: SettingsState.Subscription = SettingsState.Subscription(enabled: false,
                                                                                                canPurchase: false,
                                                                                                hasActiveSubscription: false,
                                                                                                isSubscriptionPendingActivation: false)
        
    // Sheet Presentation & Navigation
    @Published var isRestoringSubscription: Bool = false
    @Published var shouldDisplayRestoreSubscriptionError: Bool = false
    @Published var shouldShowNetP = false
    @Published var shouldShowDBP = false
    @Published var shouldShowITP = false
#endif
    @UserDefaultsWrapper(key: .subscriptionIsActive, defaultValue: false)
    static private var cachedHasActiveSubscription: Bool
    
    
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
    var autocompleteSubtitle: String?

#if SUBSCRIPTION
    // MARK: - Deep linking
    
    // Used to automatically navigate to a specific section
    // immediately after loading the Settings View
    @Published private(set) var deepLinkTarget: SettingsDeepLinkSection?
#endif

    // MARK: Bindings
    
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.appTheme },
            set: {
                self.state.appTheme = $0
                ThemeManager.shared.enableTheme(with: $0)
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

    var addressBarShowsFullURL: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.showsFullURL },
            set: {
                self.state.showsFullURL = $0
                self.appSettings.showFullSiteAddress = $0
                self.firePixel($0 ? .settingsShowFullSiteAddressEnabled : .settingsShowFullSiteAddressDisabled)
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

                Pixel.fire(pixel: self.state.autocomplete ? .autocompleteEnabled : .autocompleteDisabled)
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
         variantManager: VariantManager = AppDependencyProvider.shared.variantManager,
         deepLink: SettingsDeepLinkSection? = nil) {
        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
        self.accountManager = accountManager
        self.voiceSearchHelper = voiceSearchHelper
        self.deepLinkTarget = deepLink
        
        setupNotificationObservers()
        autocompleteSubtitle = variantManager.isSupported(feature: .history) ? UserText.settingsAutocompleteSubtitle : nil
    }
    
    deinit {
        signOutObserver = nil
    }
    
#else
    // MARK: Default Init
    init(state: SettingsState? = nil,
         legacyViewProvider: SettingsLegacyViewProvider,
         variantManager: VariantManager = AppDependencyProvider.shared.variantManager,
         voiceSearchHelper: VoiceSearchHelperProtocol = AppDependencyProvider.shared.voiceSearchHelper) {
        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
        self.voiceSearchHelper = voiceSearchHelper
        autocompleteSubtitle = variantManager.isSupported(feature: .history) ? UserText.settingsAutocompleteSubtitle : nil
    }
#endif
    
}
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
            debugModeEnabled: featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild,
            voiceSearchEnabled: AppDependencyProvider.shared.voiceSearchHelper.isVoiceSearchEnabled,
            speechRecognitionAvailable: AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable,
            loginsEnabled: featureFlagger.isFeatureOn(.autofillAccessCredentialManagement),
            networkProtection: getNetworkProtectionState(),
            subscription: cacheSubscriptionState,
            sync: getSyncState()
        )
        
        setupSubscribers()
        Task { await refreshSubscriptionState() }
        
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
    
    private func refreshSubscriptionState() async {
        let state = await self.getSubscriptionState()
        DispatchQueue.main.async {
            self.state.subscription = state
        }
    }
       
    private func getSubscriptionState() async -> SettingsState.Subscription {
            var enabled = false
            var canPurchase = false
            var hasActiveSubscription = false
            var isSubscriptionPendingActivation = false

    #if SUBSCRIPTION
        if #available(iOS 15, *) {
            enabled = isPrivacyProEnabled
            canPurchase = SubscriptionPurchaseEnvironment.canPurchase
            await setupSubscriptionEnvironment()
            if let token = AccountManager().accessToken {
                let subscriptionResult = await SubscriptionService.getSubscription(accessToken: token)
                switch subscriptionResult {
                case .success(let subscription):
                    hasActiveSubscription = subscription.isActive
                                            
                    cacheSubscriptionState = SettingsState.Subscription(enabled: enabled,
                                                                        canPurchase: canPurchase,
                                                                        hasActiveSubscription: hasActiveSubscription,
                                                                        isSubscriptionPendingActivation: isSubscriptionPendingActivation)
                    
                case .failure:
                    if await PurchaseManager.hasActiveSubscription() {
                        isSubscriptionPendingActivation = true
                    }
                }
            }
        }
    #endif
        return SettingsState.Subscription(enabled: enabled,
                                        canPurchase: canPurchase,
                                        hasActiveSubscription: hasActiveSubscription,
                                        isSubscriptionPendingActivation: isSubscriptionPendingActivation)
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
        guard let token = accountManager.accessToken else {
            setupSubscriptionPurchaseOptions()
            return
        }
                
        // Fetch available subscriptions from the backend (or sign out)
        switch await SubscriptionService.getSubscription(accessToken: token) {
        
        case .success(let subscription):
            if subscription.isActive {
                state.subscription.hasActiveSubscription = true
                state.subscription.isSubscriptionPendingActivation = false

                // Check entitlements and update UI accordingly
                let entitlements: [Entitlement.ProductName] = [.networkProtection, .dataBrokerProtection, .identityTheftRestoration]
                for entitlement in entitlements {
                    if case let .success(result) = await AccountManager().hasEntitlement(for: entitlement) {
                        switch entitlement {
                        case .identityTheftRestoration:
                            self.shouldShowITP = result
                        case .dataBrokerProtection:
                            self.shouldShowDBP = result
                        case .networkProtection:
                            self.shouldShowNetP = result
                        case .unknown:
                            return
                        }
                    }
                }
            } else {
                // Sign out in case subscription is no longer active, reset the state
                state.subscription.hasActiveSubscription = false
                state.subscription.isSubscriptionPendingActivation = false
                signOutUser()
            }

        case .failure:
            // Account is active but there's not a valid subscription / entitlements
            if await PurchaseManager.hasActiveSubscription() {
                state.subscription.isSubscriptionPendingActivation = true
            } else {
                // Sign out in case access token is present but no subscription and there is no active transaction on Apple ID
                signOutUser()
            }
        }
        
    }
    
    @available(iOS 15.0, *)
    private func signOutUser() {
        AccountManager().signOut()
        setupSubscriptionPurchaseOptions()
    }
    
    @available(iOS 15.0, *)
    private func setupSubscriptionPurchaseOptions() {
        PurchaseManager.shared.$availableProducts
            .receive(on: RunLoop.main)
            .sink { [weak self] products in
                self?.state.subscription.canPurchase = !products.isEmpty
            }.store(in: &cancellables)
    }
        
    private func setupNotificationObservers() {
        signOutObserver = NotificationCenter.default.addObserver(forName: .accountDidSignOut, object: nil, queue: .main) { [weak self] _ in
            if #available(iOS 15.0, *) {
                guard let strongSelf = self else { return }
                Task { await strongSelf.refreshSubscriptionState() }
            }
        }
    }
    
    @available(iOS 15.0, *)
    func restoreAccountPurchase() async {
        DispatchQueue.main.async { self.isRestoringSubscription = true }
        let result = await AppStoreRestoreFlow.restoreAccountFromPastPurchase(subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs))
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.isRestoringSubscription = false
            }
            await self.setupSubscriptionEnvironment()
            
        case .failure:
            DispatchQueue.main.async {
                self.isRestoringSubscription = false
                self.shouldDisplayRestoreSubscriptionError = true
            }
        }
    }
    
#endif  // SUBSCRIPTION
    
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
#if SUBSCRIPTION
            triggerDeepLinkNavigation(to: self.deepLinkTarget)
#endif
        }
    }
    
    func onDissapear() {
#if SUBSCRIPTION
        self.deepLinkTarget = nil
#endif
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
                Pixel.fire(pixel: .privacyProVPNSettings)
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
#if SUBSCRIPTION
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
#endif
// swiftlint:enable file_length
