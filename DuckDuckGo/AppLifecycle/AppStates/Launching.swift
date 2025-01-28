//
//  Launching.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import Core
import Networking
import UIKit
import BrowserServicesKit
import WidgetKit
import WebKit

/// Represents the transient state where the app is being prepared for user interaction after being launched by the system.
/// - Usage:
///   - This state is typically associated with the `application(_:didFinishLaunchingWithOptions:)` method.
///   - It is responsible for performing the app's initial setup, including configuring dependencies and preparing the UI.
///   - As part of this state, the `MainViewController` is created and set as the `rootViewController` of the app's primary `UIWindow`.
/// - Transitions:
///   - `Foreground`: Standard transition when the app completes its launch process and becomes active.
///   - `Background`: Occurs when the app is launched but transitions directly to the background, e.g:
///     - The app is protected by a FaceID lock mechanism (introduced in iOS 18.0). If the user opens the app
///       but does not authenticate and then leaves.
///     - The app is launched by the system for background execution but does not immediately become active.
/// - Notes:
///   - Avoid performing heavy or blocking operations during this phase to ensure smooth app startup.
@MainActor
struct Launching: AppState {

    private let marketplaceAdPostbackManager = MarketplaceAdPostbackManager()
    private let accountManager = AppDependencyProvider.shared.accountManager
    private let appSettings = AppDependencyProvider.shared.appSettings
    private let voiceSearchHelper = VoiceSearchHelper()
    private let onboardingPixelReporter = OnboardingPixelReporter()
    private let fireproofing = UserDefaultsFireproofing.xshared
    private let featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger

    private let privacyProDataReporter: PrivacyProDataReporting
    private let didFinishLaunchingStartTime = CFAbsoluteTimeGetCurrent()

    private let screenshotService: ScreenshotService
    private let overlayWindowManager: OverlayWindowManager
    private let authenticationService: AuthenticationService
    private let syncService: SyncService
    private let vpnService: VPNService
    private let autofillService: AutofillService = AutofillService()
    private let persistenceService = PersistenceService()
    private let remoteMessagingService: RemoteMessagingService
    private let keyboardService: KeyboardService
    private let contentBlockingService: ContentBlockingService = ContentBlockingService()
    private let configurationService: ConfigurationService

    private let window: UIWindow

    private let mainViewController: MainViewController
    private let autoClear: AutoClear

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    private let application: UIApplication
    private let crashService: CrashService
    private let subscriptionService: SubscriptionService

    init(stateContext: Initializing.StateContext) {

        defer {
            let launchTime = CFAbsoluteTimeGetCurrent() - didFinishLaunchingStartTime
            Pixel.fire(pixel: .appDidFinishLaunchingTime(time: Pixel.Event.BucketAggregation(number: launchTime)),
                       withAdditionalParameters: [PixelParameters.time: String(launchTime)])
        }

        @UserDefaultsWrapper(key: .privacyConfigCustomURL, defaultValue: nil)
        var privacyConfigCustomURL: String?

        application = stateContext.application
        crashService = stateContext.crashService

        privacyProDataReporter = PrivacyProDataReporter(fireproofing: fireproofing)

        KeyboardConfiguration.configure()
        PixelConfiguration.configure(featureFlagger: featureFlagger)

        contentBlockingService.onLaunching()
        
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)

        configurationService = ConfigurationService(isDebugBuild: isDebugBuild)
        configurationService.onLaunching()

        crashService.startAttachingCrashLogMessages(application: application)

        persistenceService.onLaunching()

        _ = DefaultUserAgentManager.shared
        removeEmailWaitlistState()

        func removeEmailWaitlistState() {
            EmailWaitlist.removeEmailState()

            let autofillStorage = EmailKeychainManager()
            try? autofillStorage.deleteWaitlistState()

            // Remove the authentication state if this is a fresh install.
            if !Database.shared.isDatabaseFileInitialized {
                try? autofillStorage.deleteAuthenticationState()
            }
        }

        WidgetCenter.shared.reloadAllTimelines()

        PrivacyFeatures.httpsUpgrade.loadDataAsync()

        let variantManager = DefaultVariantManager()
        let daxDialogs = DaxDialogs.shared

        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        cleanUpATBAndAssignVariant(variantManager: variantManager,
                                   daxDialogs: daxDialogs,
                                   marketplaceAdPostbackManager: marketplaceAdPostbackManager)

        func cleanUpATBAndAssignVariant(variantManager: VariantManager,
                                        daxDialogs: DaxDialogs,
                                        marketplaceAdPostbackManager: MarketplaceAdPostbackManager) {
            let historyMessageManager = HistoryMessageManager()

            AtbAndVariantCleanup.cleanup()
            variantManager.assignVariantIfNeeded { _ in
                let launchOptionsHandler = LaunchOptionsHandler()

                // MARK: perform first time launch logic here
                // If it's running UI Tests check if the onboarding should be in a completed state.
                if launchOptionsHandler.isUITesting && launchOptionsHandler.isOnboardingCompleted {
                    daxDialogs.dismiss()
                } else {
                    daxDialogs.primeForUse()
                }

                // New users don't see the message
                historyMessageManager.dismiss()

                // Setup storage for marketplace postback
                marketplaceAdPostbackManager.updateReturningUserValue()
            }
        }

        let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
        syncService = SyncService(bookmarksDatabase: persistenceService.bookmarksDatabase)
        remoteMessagingService = RemoteMessagingService(persistenceService: persistenceService,
                                                        appSettings: appSettings,
                                                        internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                                        configurationStore: AppDependencyProvider.shared.configurationStore,
                                                        privacyConfigurationManager: privacyConfigurationManager)

        subscriptionService = SubscriptionService(privacyConfigurationManager: privacyConfigurationManager)

        let homePageConfiguration = HomePageConfiguration(variantManager: AppDependencyProvider.shared.variantManager,
                                                          remoteMessagingClient: remoteMessagingService.remoteMessagingClient,
                                                          privacyProDataReporter: privacyProDataReporter)
        let previewsSource = TabPreviewsSource()
        let historyManager = Self.makeHistoryManager()
        let tabsModel = Self.prepareTabsModel(previewsSource: previewsSource)

        privacyProDataReporter.injectTabsModel(tabsModel)

        let daxDialogsFactory = ExperimentContextualDaxDialogsFactory(contextualOnboardingLogic: daxDialogs, contextualOnboardingPixelReporter: onboardingPixelReporter)
        let contextualOnboardingPresenter = ContextualOnboardingPresenter(variantManager: variantManager, daxDialogsFactory: daxDialogsFactory)
        mainViewController = MainViewController(bookmarksDatabase: persistenceService.bookmarksDatabase,
                                                bookmarksDatabaseCleaner: syncService.syncDataProviders.bookmarksAdapter.databaseCleaner,
                                                historyManager: historyManager,
                                                homePageConfiguration: homePageConfiguration,
                                                syncService: syncService.sync,
                                                syncDataProviders: syncService.syncDataProviders,
                                                appSettings: AppDependencyProvider.shared.appSettings,
                                                previewsSource: previewsSource,
                                                tabsModel: tabsModel,
                                                syncPausedStateManager: syncService.syncErrorHandler,
                                                privacyProDataReporter: privacyProDataReporter,
                                                variantManager: variantManager,
                                                contextualOnboardingPresenter: contextualOnboardingPresenter,
                                                contextualOnboardingLogic: daxDialogs,
                                                contextualOnboardingPixelReporter: onboardingPixelReporter,
                                                subscriptionFeatureAvailability: subscriptionService.subscriptionFeatureAvailability,
                                                voiceSearchHelper: voiceSearchHelper,
                                                featureFlagger: featureFlagger,
                                                fireproofing: fireproofing,
                                                subscriptionCookieManager: subscriptionService.subscriptionCookieManager,
                                                textZoomCoordinator: Self.makeTextZoomCoordinator(),
                                                websiteDataManager: Self.makeWebsiteDataManager(fireproofing: fireproofing),
                                                appDidFinishLaunchingStartTime: didFinishLaunchingStartTime)

        mainViewController.loadViewIfNeeded()
        syncService.syncErrorHandler.alertPresenter = mainViewController

        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
        application.setWindow(window)

        let autoClear = AutoClear(worker: mainViewController)
        self.autoClear = autoClear
        let applicationState = application.applicationState
        vpnService = VPNService(window: window)
        Task { [vpnService] in
            await autoClear.clearDataIfEnabled(applicationState: .init(with: applicationState))
            await vpnService.installRedditSessionWorkaround()
        }

        screenshotService = ScreenshotService(window: window)
        overlayWindowManager = OverlayWindowManager(window: window)
        authenticationService = AuthenticationService(overlayWindowManager: overlayWindowManager)
        keyboardService = KeyboardService(mainViewController: mainViewController)

        ThemeManager.shared.updateUserInterfaceStyle(window: window)

        // Temporary logic for rollout of Autofill as on by default for new installs only
        if AppDependencyProvider.shared.appSettings.autofillIsNewInstallForOnByDefault == nil {
            AppDependencyProvider.shared.appSettings.setAutofillIsNewInstallForOnByDefault()
        }

        NewTabPageIntroMessageSetup().perform()
        vpnService.onLaunching()
        subscriptionService.onLaunching()
        autofillService.onLaunching()
        crashService.handleCrashDuringCrashHandlersSetup()
    }

    private var appDependencies: AppDependencies {
        AppDependencies(
            window: window,
            accountManager: accountManager,
            vpnService: vpnService,
            appSettings: appSettings,
            overlayWindowManager: overlayWindowManager,
            authenticationService: authenticationService,
            screenshotService: screenshotService,
            mainViewController: mainViewController,
            voiceSearchHelper: voiceSearchHelper,
            autoClear: autoClear,
            marketplaceAdPostbackManager: marketplaceAdPostbackManager,
            syncService: syncService,
            privacyProDataReporter: privacyProDataReporter,
            remoteMessagingService: remoteMessagingService,
            subscriptionService: subscriptionService,
            onboardingPixelReporter: onboardingPixelReporter,
            autofillService: autofillService,
            crashService: crashService,
            keyboardService: keyboardService,
            configurationService: configurationService
        )
    }

    private static func makeHistoryManager() -> HistoryManaging {
        let provider = AppDependencyProvider.shared
        switch HistoryManager.make(isAutocompleteEnabledByUser: provider.appSettings.autocomplete,
                                   isRecentlyVisitedSitesEnabledByUser: provider.appSettings.recentlyVisitedSites,
                                   privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager,
                                   tld: provider.storageCache.tld) {

        case .failure(let error):
            Pixel.fire(pixel: .historyStoreLoadFailed, error: error)
// Commenting out as it didn't work anyway - the window was just always nil at this point
//            if error.isDiskFull {
//                self.presentInsufficientDiskSpaceAlert()
//            } else {
//                self.presentPreemptiveCrashAlert()
//            }
            return NullHistoryManager()

        case .success(let historyManager):
            return historyManager
        }
    }

    private static func prepareTabsModel(previewsSource: TabPreviewsSource = TabPreviewsSource(),
                                         appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
                                         isDesktop: Bool = UIDevice.current.userInterfaceIdiom == .pad) -> TabsModel {
        let isPadDevice = UIDevice.current.userInterfaceIdiom == .pad
        let tabsModel: TabsModel
        if AutoClearSettingsModel(settings: appSettings) != nil {
            tabsModel = TabsModel(desktop: isPadDevice)
            tabsModel.save()
            previewsSource.removeAllPreviews()
        } else {
            if let storedModel = TabsModel.get() {
                // Save new model in case of migration
                storedModel.save()
                tabsModel = storedModel
            } else {
                tabsModel = TabsModel(desktop: isPadDevice)
            }
        }
        return tabsModel
    }

    private static func makeTextZoomCoordinator() -> TextZoomCoordinator {
        let provider = AppDependencyProvider.shared
        let storage = TextZoomStorage()

        return TextZoomCoordinator(appSettings: provider.appSettings,
                                   storage: storage,
                                   featureFlagger: provider.featureFlagger)
    }

    private static func makeWebsiteDataManager(fireproofing: Fireproofing,
                                               dataStoreIDManager: DataStoreIDManaging = DataStoreIDManager.shared) -> WebsiteDataManaging {
        return WebCacheManager(cookieStorage: MigratableCookieStorage(),
                               fireproofing: fireproofing,
                               dataStoreIDManager: dataStoreIDManager)
    }

}

extension Launching {

    struct StateContext {

        let application: UIApplication
        let didFinishLaunchingStartTime: CFAbsoluteTime
        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(application: application,
              didFinishLaunchingStartTime: didFinishLaunchingStartTime,
              urlToOpen: urlToOpen,
              shortcutItemToHandle: shortcutItemToHandle,
              appDependencies: appDependencies)
    }

}

extension Launching {

    mutating func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            urlToOpen = url
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
        }
    }

}

extension UIApplication {

    enum TerminationReason {

        case insufficientDiskSpace
        case rulesCompilationFatalError

    }

    func setWindow(_ window: UIWindow?) {
        (delegate as? AppDelegate)?.window = window
    }

    var window: UIWindow? {
        delegate?.window ?? nil
    }

}
