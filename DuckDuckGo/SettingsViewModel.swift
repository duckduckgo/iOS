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
import SyncUI_iOS
import DuckPlayer
import Crashes

import Subscription
import NetworkProtection
import AIChat

final class SettingsViewModel: ObservableObject {

    // Dependencies
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings
    private(set) var privacyStore = PrivacyUserDefaults()
    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    private var legacyViewProvider: SettingsLegacyViewProvider
    private lazy var versionProvider: AppVersion = AppVersion.shared
    private let voiceSearchHelper: VoiceSearchHelperProtocol
    private let syncPausedStateManager: any SyncPausedStateManaging
    var emailManager: EmailManager { EmailManager() }
    private let historyManager: HistoryManaging
    let privacyProDataReporter: PrivacyProDataReporting?
    let textZoomCoordinator: TextZoomCoordinating
    let aiChatSettings: AIChatSettingsProvider
    let maliciousSiteProtectionPreferencesManager: MaliciousSiteProtectionPreferencesManaging

    // Subscription Dependencies
    let subscriptionManager: SubscriptionManager
    let subscriptionFeatureAvailability: SubscriptionFeatureAvailability
    private var subscriptionSignOutObserver: Any?
    var duckPlayerContingencyHandler: DuckPlayerContingencyHandler {
        DefaultDuckPlayerContingencyHandler(privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager)
    }

    private enum UserDefaultsCacheKey: String, UserDefaultsCacheKeyStore {
        case subscriptionState = "com.duckduckgo.ios.subscription.state"
    }
    // Used to cache the lasts subscription state for up to a week
    private let subscriptionStateCache = UserDefaultsCache<SettingsState.Subscription>(key: UserDefaultsCacheKey.subscriptionState,
                                                                         settings: UserDefaultsCacheSettings(defaultExpirationInterval: .days(7)))
    // Properties
    private lazy var isPad = UIDevice.current.userInterfaceIdiom == .pad
    private var cancellables = Set<AnyCancellable>()
    
    // App Data State Notification Observer
    private var appDataClearingObserver: Any?
    private var textZoomObserver: Any?

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
        case zoomLevel
        case voiceSearch
        case addressbarPosition
        case speechRecognition
        case networkProtection
    }
    
    var shouldShowNoMicrophonePermissionAlert: Bool = false
    @Published var shouldShowEmailAlert: Bool = false

    @Published var shouldShowRecentlyVisitedSites: Bool = true
    
    @Published var isInternalUser: Bool = AppDependencyProvider.shared.internalUserDecider.isInternalUser

    @Published var selectedFeedbackFlow: String?

    // MARK: - Deep linking
    // Used to automatically navigate to a specific section
    // immediately after loading the Settings View
    @Published private(set) var deepLinkTarget: SettingsDeepLinkSection?
    
    // MARK: Bindings
    
    var themeBinding: Binding<ThemeName> {
        Binding<ThemeName>(
            get: { self.state.appTheme },
            set: {
                Pixel.fire(pixel: .settingsThemeSelectorPressed)
                self.state.appTheme = $0
                ThemeManager.shared.enableTheme(with: $0)
            }
        )
    }
    var fireButtonAnimationBinding: Binding<FireButtonAnimationType> {
        Binding<FireButtonAnimationType>(
            get: { self.state.fireButtonAnimation },
            set: {
                Pixel.fire(pixel: .settingsFireButtonSelectorPressed)
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
                self.state.addressBar.position
            },
            set: {
                Pixel.fire(pixel: $0 == .top ? .settingsAddressBarTopSelected : .settingsAddressBarBottomSelected)
                self.appSettings.currentAddressBarPosition = $0
                self.state.addressBar.position = $0
            }
        )
    }

    var addressBarShowsFullURL: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.showsFullURL },
            set: {
                Pixel.fire(pixel: $0 ? .settingsShowFullURLOn : .settingsShowFullURLOff)
                self.state.showsFullURL = $0
                self.appSettings.showFullSiteAddress = $0
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

    var autocompleteGeneralBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.autocomplete },
            set: {
                self.appSettings.autocomplete = $0
                self.state.autocomplete = $0
                self.clearHistoryIfNeeded()
                self.updateRecentlyVisitedSitesVisibility()
                
                if $0 {
                    Pixel.fire(pixel: .settingsGeneralAutocompleteOn)
                } else {
                    Pixel.fire(pixel: .settingsGeneralAutocompleteOff)
                }
            }
        )
    }

    var autocompletePrivateSearchBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.autocomplete },
            set: {
                self.appSettings.autocomplete = $0
                self.state.autocomplete = $0
                self.clearHistoryIfNeeded()
                self.updateRecentlyVisitedSitesVisibility()

                if $0 {
                    Pixel.fire(pixel: .settingsPrivateSearchAutocompleteOn)
                } else {
                    Pixel.fire(pixel: .settingsPrivateSearchAutocompleteOff)
                }
            }
        )
    }

    var autocompleteRecentlyVisitedSitesBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.recentlyVisitedSites },
            set: {
                self.appSettings.recentlyVisitedSites = $0
                self.state.recentlyVisitedSites = $0
                if $0 {
                    Pixel.fire(pixel: .settingsRecentlyVisitedOn)
                } else {
                    Pixel.fire(pixel: .settingsRecentlyVisitedOff)
                }
                self.clearHistoryIfNeeded()
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
                    Pixel.fire(pixel: .settingsGpcOn)
                } else {
                    Pixel.fire(pixel: .settingsGpcOff)
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
                    Pixel.fire(pixel: .settingsAutoconsentOn)
                } else {
                    Pixel.fire(pixel: .settingsAutoconsentOff)
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
                    Pixel.fire(pixel: .settingsVoiceSearchOn)
                } else {
                    Pixel.fire(pixel: .settingsVoiceSearchOff)
                }
            }
        )
    }

    var aiChatBrowsingMenuEnabledBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.aiChatSettings.isAIChatBrowsingMenuUserSettingsEnabled },
            set: { newValue in
                self.aiChatSettings.enableAIChatBrowsingMenuUserSettings(enable: newValue)
            }
        )
    }

    var aiChatAddressBarEnabledBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.aiChatSettings.isAIChatAddressBarUserSettingsEnabled },
            set: { newValue in
                self.aiChatSettings.enableAIChatAddressBarUserSettings(enable: newValue)
            }
        )
    }

    var textZoomLevelBinding: Binding<TextZoomLevel> {
        Binding<TextZoomLevel>(
            get: { self.state.textZoom.level },
            set: { newValue in
                Pixel.fire(.settingsAccessiblityTextZoom, withAdditionalParameters: [
                    PixelParameters.textZoomInitial: String(self.appSettings.defaultTextZoomLevel.rawValue),
                    PixelParameters.textZoomUpdated: String(newValue.rawValue),
                ])
                self.appSettings.defaultTextZoomLevel = newValue
                self.state.textZoom.level = newValue
            }
        )
    }

    var duckPlayerModeBinding: Binding<DuckPlayerMode> {
        Binding<DuckPlayerMode>(
            get: {
                return self.state.duckPlayerMode ?? .alwaysAsk
            },
            set: {
                self.appSettings.duckPlayerMode = $0
                self.state.duckPlayerMode = $0
                
                switch self.state.duckPlayerMode {
                case .alwaysAsk:
                    Pixel.fire(pixel: Pixel.Event.duckPlayerSettingBackToDefault)
                case .disabled:
                    Pixel.fire(pixel: Pixel.Event.duckPlayerSettingNeverSettings)
                case .enabled:
                    Pixel.fire(pixel: Pixel.Event.duckPlayerSettingAlwaysSettings)
                default:
                    break
                }
            }
        )
    }
    
    var duckPlayerOpenInNewTabBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.duckPlayerOpenInNewTab },
            set: {
                self.appSettings.duckPlayerOpenInNewTab = $0
                self.state.duckPlayerOpenInNewTab = $0
                if self.state.duckPlayerOpenInNewTab {
                    Pixel.fire(pixel: Pixel.Event.duckPlayerNewTabSettingOn)
                } else {
                    Pixel.fire(pixel: Pixel.Event.duckPlayerNewTabSettingOff)
                }
            }
        )
    }
    
    var duckPlayerNativeUI: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.duckPlayerNativeUI },
            set: {
                self.appSettings.duckPlayerNativeUI = $0
                self.state.duckPlayerNativeUI = $0
            }
        )
    }
    
    var duckPlayerAutoplay: Binding<Bool> {
        Binding<Bool>(
            get: { self.state.duckPlayerAutoplay },
            set: {
                self.appSettings.duckPlayerAutoplay = $0
                self.state.duckPlayerAutoplay = $0
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
                if self.appSettings.crashCollectionOptInStatus == .optedIn && $0 == false {
                    let crashCollection = CrashCollection(crashReportSender: CrashReportSender(platform: .iOS, pixelEvents: CrashReportSender.pixelEvents))
                    crashCollection.clearCRCID()
                }
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

    var usesUnifiedFeedbackForm: Bool {
        subscriptionManager.accountManager.isUserAuthenticated && subscriptionFeatureAvailability.usesUnifiedFeedbackForm
    }

    // MARK: Default Init
    init(state: SettingsState? = nil,
         legacyViewProvider: SettingsLegacyViewProvider,
         subscriptionManager: SubscriptionManager,
         subscriptionFeatureAvailability: SubscriptionFeatureAvailability,
         voiceSearchHelper: VoiceSearchHelperProtocol,
         variantManager: VariantManager = AppDependencyProvider.shared.variantManager,
         deepLink: SettingsDeepLinkSection? = nil,
         historyManager: HistoryManaging,
         syncPausedStateManager: any SyncPausedStateManaging,
         privacyProDataReporter: PrivacyProDataReporting,
         textZoomCoordinator: TextZoomCoordinating,
         aiChatSettings: AIChatSettingsProvider,
         maliciousSiteProtectionPreferencesManager: MaliciousSiteProtectionPreferencesManaging
    ) {

        self.state = SettingsState.defaults
        self.legacyViewProvider = legacyViewProvider
        self.subscriptionManager = subscriptionManager
        self.subscriptionFeatureAvailability = subscriptionFeatureAvailability
        self.voiceSearchHelper = voiceSearchHelper
        self.deepLinkTarget = deepLink
        self.historyManager = historyManager
        self.syncPausedStateManager = syncPausedStateManager
        self.privacyProDataReporter = privacyProDataReporter
        self.textZoomCoordinator = textZoomCoordinator
        self.aiChatSettings = aiChatSettings
        self.maliciousSiteProtectionPreferencesManager = maliciousSiteProtectionPreferencesManager
        setupNotificationObservers()
        updateRecentlyVisitedSitesVisibility()
    }

    deinit {
        subscriptionSignOutObserver = nil
        appDataClearingObserver = nil
        textZoomObserver = nil
    }
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
            textZoom: SettingsState.TextZoom(enabled: textZoomCoordinator.isEnabled, level: appSettings.defaultTextZoomLevel),
            addressBar: SettingsState.AddressBar(enabled: !isPad, position: appSettings.currentAddressBarPosition),
            showsFullURL: appSettings.showFullSiteAddress,
            sendDoNotSell: appSettings.sendDoNotSell,
            autoconsentEnabled: appSettings.autoconsentEnabled,
            autoclearDataEnabled: AutoClearSettingsModel(settings: appSettings) != nil,
            applicationLock: privacyStore.authenticationEnabled,
            autocomplete: appSettings.autocomplete,
            recentlyVisitedSites: appSettings.recentlyVisitedSites,
            longPressPreviews: appSettings.longPressPreviews,
            allowUniversalLinks: appSettings.allowUniversalLinks,
            activeWebsiteAccount: nil,
            version: versionProvider.versionAndBuildNumber,
            crashCollectionOptInStatus: appSettings.crashCollectionOptInStatus,
            debugModeEnabled: featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild,
            voiceSearchEnabled: voiceSearchHelper.isVoiceSearchEnabled,
            speechRecognitionAvailable: voiceSearchHelper.isSpeechRecognizerAvailable,
            loginsEnabled: featureFlagger.isFeatureOn(.autofillAccessCredentialManagement),
            networkProtectionConnected: false,
            subscription: SettingsState.defaults.subscription,
            sync: getSyncState(),
            syncSource: nil,
            duckPlayerEnabled: featureFlagger.isFeatureOn(.duckPlayer) || shouldDisplayDuckPlayerContingencyMessage,
            duckPlayerMode: appSettings.duckPlayerMode,
            duckPlayerOpenInNewTab: appSettings.duckPlayerOpenInNewTab,
            duckPlayerOpenInNewTabEnabled: featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab),
            duckPlayerNativeUI: appSettings.duckPlayerNativeUI,
            duckPlayerAutoplay: appSettings.duckPlayerAutoplay,
            aiChat: SettingsState.AIChat(enabled: aiChatSettings.isAIChatFeatureEnabled,
                                         isAIChatBrowsingMenuFeatureFlagEnabled: aiChatSettings.isAIChatBrowsingMenubarShortcutFeatureEnabled,
                                         isAIChatAddressBarFeatureFlagEnabled: aiChatSettings.isAIChatAddressBarShortcutFeatureEnabled)
        )
        
        updateRecentlyVisitedSitesVisibility()
        setupSubscribers()
        Task { await setupSubscriptionEnvironment() }
    }

    private func updateRecentlyVisitedSitesVisibility() {
        withAnimation {
            shouldShowRecentlyVisitedSites = historyManager.isHistoryFeatureEnabled() && state.autocomplete
        }
    }

    private func clearHistoryIfNeeded() {
        if !historyManager.isEnabledByUser {
            Task {
                await self.historyManager.removeAllHistory()
            }
        }
    }

    private func getSyncState() -> SettingsState.SyncSettings {
        SettingsState.SyncSettings(enabled: legacyViewProvider.syncService.featureFlags.contains(.userInterface),
                                   title: {
            let syncService = legacyViewProvider.syncService
            let isDataSyncingDisabled = !syncService.featureFlags.contains(.dataSyncing)
            && syncService.authState == .active
            if isDataSyncingDisabled
                || syncPausedStateManager.isSyncPaused
                || syncPausedStateManager.isSyncBookmarksPaused
                || syncPausedStateManager.isSyncCredentialsPaused {
                return "⚠️ \(UserText.settingsSync)"
            }
            return SyncUI_iOS.UserText.syncTitle
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

    private func updateNetPStatus(connectionStatus: ConnectionStatus) {
        switch connectionStatus {
        case .connected:
            self.state.networkProtectionConnected = true
        default:
            self.state.networkProtectionConnected = false
        }
    }
    
}

// MARK: Subscribers
extension SettingsViewModel {
    
    private func setupSubscribers() {

        AppDependencyProvider.shared.connectionObserver.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateNetPStatus(connectionStatus: status)
            }
            .store(in: &cancellables)

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
        Pixel.fire(pixel: .settingsSetAsDefault)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    @MainActor func shouldPresentLoginsViewWithAccount(accountDetails: SecureVaultModels.WebsiteAccount) {
        state.activeWebsiteAccount = accountDetails
        presentLegacyView(.logins)
    }

    @MainActor func shouldPresentSyncViewWithSource(_ source: String? = nil) {
        state.syncSource = source
        presentLegacyView(.sync)
    }

    func openEmailProtection() {
        UIApplication.shared.open(URL.emailProtectionQuickLink)
    }

    func openEmailAccountManagement() {
        UIApplication.shared.open(URL.emailProtectionAccountLink)
    }

    func openEmailSupport() {
        UIApplication.shared.open(URL.emailProtectionSupportLink)
    }

    func openOtherPlatforms() {
        UIApplication.shared.open(URL.apps)
    }

    func openMoreSearchSettings() {
        Pixel.fire(pixel: .settingsMoreSearchSettings)
        UIApplication.shared.open(URL.searchSettings)
    }

    var shouldDisplayDuckPlayerContingencyMessage: Bool {
        duckPlayerContingencyHandler.shouldDisplayContingencyMessage
    }

    func openDuckPlayerContingencyMessageSite() {
        guard let url = duckPlayerContingencyHandler.learnMoreURL else { return }
        Pixel.fire(pixel: .duckPlayerContingencyLearnMoreClicked)
        UIApplication.shared.open(url)
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
    
    @MainActor func presentLegacyView(_ view: SettingsLegacyViewProvider.LegacyView) {
        
        switch view {
        
        case .addToDock:
            presentViewController(legacyViewProvider.addToDock, modal: true)
        case .sync:
            pushViewController(legacyViewProvider.syncSettings(source: state.syncSource))
        case .appIcon: pushViewController(legacyViewProvider.appIcon)
        case .unprotectedSites: pushViewController(legacyViewProvider.unprotectedSites)
        case .fireproofSites: pushViewController(legacyViewProvider.fireproofSites)
        case .autoclearData:
            pushViewController(legacyViewProvider.autoclearData)
        case .keyboard: pushViewController(legacyViewProvider.keyboard)
        case .debug: pushViewController(legacyViewProvider.debug)
            
        case .feedback:
            presentViewController(legacyViewProvider.feedback, modal: false)
        case .logins:
            pushViewController(legacyViewProvider.loginSettings(delegate: self,
                                                            selectedAccount: state.activeWebsiteAccount))

        case .gpc:
            firePixel(.settingsDoNotSellShown)
            pushViewController(legacyViewProvider.gpc)
        
        case .autoconsent:
            pushViewController(legacyViewProvider.autoConsent)
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

    enum SettingsDeepLinkSection: Identifiable, Equatable {
        case netP
        case dbp
        case itr
        case subscriptionFlow(origin: String? = nil)
        case restoreFlow
        case duckPlayer
        case aiChat
        // Add other cases as needed

        var id: String {
            switch self {
            case .netP: return "netP"
            case .dbp: return "dbp"
            case .itr: return "itr"
            case .subscriptionFlow: return "subscriptionFlow"
            case .restoreFlow: return "restoreFlow"
            case .duckPlayer: return "duckPlayer"
            case .aiChat: return "aiChat"
            // Ensure all cases are covered
            }
        }

        // Define the presentation type: .sheet or .push
        // Default to .sheet, specify .push where needed
        var type: DeepLinkType {
            switch self {
            case .netP, .dbp, .itr, .subscriptionFlow, .restoreFlow, .duckPlayer, .aiChat:
                return .navigationLink
            }
        }
    }

    // Define DeepLinkType outside the enum if not already defined
    enum DeepLinkType {
        case sheet
        case navigationLink
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
        }

        // Update if can purchase based on App Store product availability
        state.subscription.canPurchase = subscriptionManager.canPurchase

        // Update if user is signed in based on the presence of token
        state.subscription.isSignedIn = subscriptionManager.accountManager.isUserAuthenticated

        // Active subscription check
        guard let token = subscriptionManager.accountManager.accessToken else {
            // Reset state in case cache was outdated
            state.subscription.hasSubscription = false
            state.subscription.hasActiveSubscription = false
            state.subscription.entitlements = []
            state.subscription.platform = .unknown
            state.subscription.isActiveTrialOffer = false

            subscriptionStateCache.set(state.subscription) // Sync cache
            return
        }
        
        let subscriptionResult = await subscriptionManager.subscriptionEndpointService.getSubscription(accessToken: token)
        switch subscriptionResult {
            
        case .success(let subscription):
            state.subscription.platform = subscription.platform
            state.subscription.hasSubscription = true
            state.subscription.hasActiveSubscription = subscription.isActive
            state.subscription.isActiveTrialOffer = subscription.hasActiveTrialOffer

            // Check entitlements and update state
            var currentEntitlements: [Entitlement.ProductName] = []
            let entitlementsToCheck: [Entitlement.ProductName] = [.networkProtection, .dataBrokerProtection, .identityTheftRestoration, .identityTheftRestorationGlobal]

            for entitlement in entitlementsToCheck {
                if case .success(true) = await subscriptionManager.accountManager.hasEntitlement(forProductName: entitlement) {
                    currentEntitlements.append(entitlement)
                }
            }

            self.state.subscription.entitlements = currentEntitlements
            self.state.subscription.subscriptionFeatures = await subscriptionManager.currentSubscriptionFeatures()

        case .failure(let subscriptionServiceError):
            if case let .apiError(apiError) = subscriptionServiceError,
               case let .serverError(statusCode, error) = apiError {
                if statusCode == 400 && error == "No subscription found" {
                    state.subscription.hasSubscription = false
                    state.subscription.hasActiveSubscription = false
                    state.subscription.entitlements = []
                    state.subscription.platform = .unknown
                    state.subscription.isActiveTrialOffer = false

                    DailyPixel.fireDailyAndCount(pixel: .settingsPrivacyProAccountWithNoSubscriptionFound)
                }
            }
        }
        
        // Sync Cache
        subscriptionStateCache.set(state.subscription)
    }
    
    private func setupNotificationObservers() {
        subscriptionSignOutObserver = NotificationCenter.default.addObserver(forName: .accountDidSignOut,
                                                                             object: nil,
                                                                             queue: .main) { [weak self] _ in
            guard let strongSelf = self else { return }
            Task {
                strongSelf.subscriptionStateCache.reset()
                await strongSelf.setupSubscriptionEnvironment()
            }
        }
        
        // Observe App Data clearing state
        appDataClearingObserver = NotificationCenter.default.addObserver(forName: AppUserDefaults.Notifications.appDataClearingUpdated,
                                                                         object: nil,
                                                                         queue: .main) { [weak self] _ in
            guard let settings = self?.appSettings else { return }
            self?.state.autoclearDataEnabled = (AutoClearSettingsModel(settings: settings) != nil)
        }
        
        textZoomObserver = NotificationCenter.default.addObserver(forName: AppUserDefaults.Notifications.textZoomChange,
                                                                  object: nil,
                                                                  queue: .main, using: { [weak self] _ in
            guard let self = self else { return }
            self.state.textZoom = SettingsState.TextZoom(enabled: true, level: self.appSettings.defaultTextZoomLevel)
        })
    }
    
    func restoreAccountPurchase() async {
        DispatchQueue.main.async { self.state.subscription.isRestoring = true }
        let appStoreRestoreFlow = DefaultAppStoreRestoreFlow(accountManager: subscriptionManager.accountManager,
                                                             storePurchaseManager: subscriptionManager.storePurchaseManager(),
                                                             subscriptionEndpointService: subscriptionManager.subscriptionEndpointService,
                                                             authEndpointService: subscriptionManager.authEndpointService)
        let result = await appStoreRestoreFlow.restoreAccountFromPastPurchase()
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.state.subscription.isRestoring = false
            }
            await self.setupSubscriptionEnvironment()
            
        case .failure(let restoreFlowError):
            DispatchQueue.main.async {
                self.state.subscription.isRestoring = false
                self.state.subscription.shouldDisplayRestoreSubscriptionError = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.state.subscription.shouldDisplayRestoreSubscriptionError = false
                }
            }

            switch restoreFlowError {
            case .missingAccountOrTransactions:
                DailyPixel.fireDailyAndCount(pixel: .privacyProActivatingRestoreErrorMissingAccountOrTransactions)
            case .pastTransactionAuthenticationError:
                DailyPixel.fireDailyAndCount(pixel: .privacyProActivatingRestoreErrorPastTransactionAuthenticationError)
            case .failedToObtainAccessToken:
                DailyPixel.fireDailyAndCount(pixel: .privacyProActivatingRestoreErrorFailedToObtainAccessToken)
            case .failedToFetchAccountDetails:
                DailyPixel.fireDailyAndCount(pixel: .privacyProActivatingRestoreErrorFailedToFetchAccountDetails)
            case .failedToFetchSubscriptionDetails:
                DailyPixel.fireDailyAndCount(pixel: .privacyProActivatingRestoreErrorFailedToFetchSubscriptionDetails)
            case .subscriptionExpired:
                DailyPixel.fireDailyAndCount(pixel: .privacyProActivatingRestoreErrorSubscriptionExpired)
            }
        }
    }
    
}

// Deeplink notification handling
extension NSNotification.Name {
    static let settingsDeepLinkNotification: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.settingsDeepLink")
}
