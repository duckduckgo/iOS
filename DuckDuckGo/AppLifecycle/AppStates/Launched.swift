//
//  Launched.swift
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
import Configuration
import Crashes
import UIKit
import Persistence
import BrowserServicesKit
import WidgetKit
import DDGSync
import RemoteMessaging
import Subscription
import WebKit
import Common
import Combine

@MainActor
struct Launched: AppState {

    var appContext: AppContext

    @UserDefaultsWrapper(key: .privacyConfigCustomURL, defaultValue: nil)
    private var privacyConfigCustomURL: String?

    private let crashCollection = CrashCollection(platform: .iOS)
    private let bookmarksDatabase = BookmarksDatabase.make()
    private let marketplaceAdPostbackManager = MarketplaceAdPostbackManager()
    private let accountManager = AppDependencyProvider.shared.accountManager
    private let tunnelController = AppDependencyProvider.shared.networkProtectionTunnelController
    private let vpnFeatureVisibility = AppDependencyProvider.shared.vpnFeatureVisibility
    private let appSettings = AppDependencyProvider.shared.appSettings
    private let privacyStore = PrivacyUserDefaults()
    private let uiService = UIService()
    private let voiceSearchHelper = VoiceSearchHelper()
    private let autofillLoginSession = AppDependencyProvider.shared.autofillLoginSession
    private let onboardingPixelReporter = OnboardingPixelReporter()
    private let widgetRefreshModel = NetworkProtectionWidgetRefreshModel()
    private let tipKitAppEventsHandler = TipKitAppEventHandler()
    private let fireproofing = UserDefaultsFireproofing.xshared

    private let vpnWorkaround: VPNRedditSessionWorkaround
    private let privacyProDataReporter: PrivacyProDataReporting
    private let unService: UNService

    // TODO
    private var syncDataProviders: SyncDataProviders!
    private var autoClear: AutoClear!
    private var syncService: DDGSync!
    private var isSyncInProgressCancellable: AnyCancellable!
    private var remoteMessagingClient: RemoteMessagingClient!
    private var subscriptionCookieManager: SubscriptionCookieManaging!

    init(appContext: AppContext) {
        self.appContext = appContext
        privacyProDataReporter = PrivacyProDataReporter(fireproofing: fireproofing)
        vpnWorkaround = VPNRedditSessionWorkaround(accountManager: accountManager, tunnelController: tunnelController)
        unService = UNService(window: appContext.window, accountManager: accountManager)

        self.appContext.didFinishLaunchingStartTime = CFAbsoluteTimeGetCurrent()
        defer {
            if let didFinishLaunchingStartTime = appContext.didFinishLaunchingStartTime {
                let launchTime = CFAbsoluteTimeGetCurrent() - didFinishLaunchingStartTime
                Pixel.fire(pixel: .appDidFinishLaunchingTime(time: Pixel.Event.BucketAggregation(number: launchTime)),
                           withAdditionalParameters: [PixelParameters.time: String(launchTime)])
            }
        }

#if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["UITESTING"] == "true" {
            // Disable hardware keyboards.
            let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
            UITextInputMode.activeInputModes
            // Filter `UIKeyboardInputMode`s.
                .filter({ $0.responds(to: setHardwareLayout) })
                .forEach { $0.perform(setHardwareLayout, with: nil) }
        }
#endif

#if DEBUG
        Pixel.isDryRun = true
#else
        Pixel.isDryRun = false
#endif

        ContentBlocking.shared.onCriticalError = presentPreemptiveCrashAlert
        // Explicitly prepare ContentBlockingUpdating instance before Tabs are created
        _ = ContentBlockingUpdating.shared

        // Can be removed after a couple of versions
        cleanUpMacPromoExperiment2()
        cleanUpIncrementalRolloutPixelTest()

        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)

        if isDebugBuild, let privacyConfigCustomURL, let url = URL(string: privacyConfigCustomURL) {
            Configuration.setURLProvider(CustomConfigurationURLProvider(customPrivacyConfigurationURL: url))
        } else {
            Configuration.setURLProvider(AppConfigurationURLProvider())
        }

        crashCollection.startAttachingCrashLogMessages { pixelParameters, payloads, sendReport in
            pixelParameters.forEach { params in
                Pixel.fire(pixel: .dbCrashDetected, withAdditionalParameters: params, includedParameters: [])
            }

            // Async dispatch because rootViewController may otherwise be nil here
            DispatchQueue.main.async {
                guard let viewController = appContext.window?.rootViewController else { return }

                let crashReportUploaderOnboarding = CrashCollectionOnboarding(appSettings: AppDependencyProvider.shared.appSettings)
                crashReportUploaderOnboarding.presentOnboardingIfNeeded(for: payloads, from: viewController, sendReport: sendReport) // test, does it show?
            }
        }

        clearTmp()

        _ = DefaultUserAgentManager.shared
        self.appContext.isTesting = ProcessInfo().arguments.contains("testing")
        if appContext.isTesting {
            Pixel.isDryRun = true
            _ = DefaultUserAgentManager.shared
            Database.shared.loadStore { _, _ in }
            _ = BookmarksDatabaseSetup().loadStoreAndMigrate(bookmarksDatabase: bookmarksDatabase)

            self.appContext.window = UIWindow(frame: UIScreen.main.bounds)
            self.appContext.window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()

            let blockingDelegate = BlockingNavigationDelegate()
            let webView = blockingDelegate.prepareWebView()
            self.appContext.window?.rootViewController?.view.addSubview(webView)
            self.appContext.window?.rootViewController?.view.backgroundColor = .red
            webView.frame = CGRect(x: 10, y: 10, width: 300, height: 300)

            let request = URLRequest(url: URL(string: "about:blank")!)
            webView.load(request)

            return
        }

        removeEmailWaitlistState()

        var shouldPresentInsufficientDiskSpaceAlertAndCrash = false
        Database.shared.loadStore { context, error in
            guard let context = context else {

                let parameters = [PixelParameters.applicationState: "\(appContext.application.applicationState.rawValue)",
                                  PixelParameters.dataAvailability: "\(appContext.application.isProtectedDataAvailable)"]

                switch error {
                case .none:
                    fatalError("Could not create database stack: Unknown Error")
                case .some(CoreDataDatabase.Error.containerLocationCouldNotBePrepared(let underlyingError)):
                    Pixel.fire(pixel: .dbContainerInitializationError,
                               error: underlyingError,
                               withAdditionalParameters: parameters)
                    Thread.sleep(forTimeInterval: 1)
                    fatalError("Could not create database stack: \(underlyingError.localizedDescription)")
                case .some(let error):
                    Pixel.fire(pixel: .dbInitializationError,
                               error: error,
                               withAdditionalParameters: parameters)
                    if error.isDiskFull {
                        shouldPresentInsufficientDiskSpaceAlertAndCrash = true
                        return
                    } else {
                        Thread.sleep(forTimeInterval: 1)
                        fatalError("Could not create database stack: \(error.localizedDescription)")
                    }
                }
            }
            DatabaseMigration.migrate(to: context)
        }

        switch BookmarksDatabaseSetup().loadStoreAndMigrate(bookmarksDatabase: bookmarksDatabase) {
        case .success:
            break
        case .failure(let error):
            Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase,
                       error: error)
            if error.isDiskFull {
                shouldPresentInsufficientDiskSpaceAlertAndCrash = true
            } else {
                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not create database stack: \(error.localizedDescription)")
            }
        }

        WidgetCenter.shared.reloadAllTimelines()

        Favicons.shared.migrateFavicons(to: Favicons.Constants.maxFaviconSize) {
            WidgetCenter.shared.reloadAllTimelines()
        }

        PrivacyFeatures.httpsUpgrade.loadDataAsync()

        let variantManager = DefaultVariantManager()
        let daxDialogs = DaxDialogs.shared

        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        cleanUpATBAndAssignVariant(variantManager: variantManager, daxDialogs: daxDialogs)

        // MARK: Sync initialisation
#if DEBUG
        let defaultEnvironment = ServerEnvironment.development
#else
        let defaultEnvironment = ServerEnvironment.production
#endif

        let environment = ServerEnvironment(
            UserDefaultsWrapper(
                key: .syncEnvironment,
                defaultValue: defaultEnvironment.description
            ).wrappedValue
        ) ?? defaultEnvironment

        let syncErrorHandler = SyncErrorHandler()

        syncDataProviders = SyncDataProviders(
            bookmarksDatabase: bookmarksDatabase,
            secureVaultErrorReporter: SecureVaultReporter(),
            settingHandlers: [FavoritesDisplayModeSyncHandler()],
            favoritesDisplayModeStorage: FavoritesDisplayModeStorage(),
            syncErrorHandler: syncErrorHandler,
            faviconStoring: Favicons.shared
        )

        syncService = DDGSync(
            dataProvidersSource: syncDataProviders,
            errorEvents: SyncErrorHandler(),
            privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
            environment: environment
        )
        syncService.initializeIfNeeded()
        isSyncInProgressCancellable = syncService.isSyncInProgressPublisher
            .filter { $0 }
            .sink { [weak syncService] _ in
                DailyPixel.fire(pixel: .syncDaily, includedParameters: [.appVersion])
                syncService?.syncDailyStats.sendStatsIfNeeded(handler: { params in
                    Pixel.fire(pixel: .syncSuccessRateDaily,
                               withAdditionalParameters: params,
                               includedParameters: [.appVersion])
                })
            }

        remoteMessagingClient = RemoteMessagingClient(
            bookmarksDatabase: bookmarksDatabase,
            appSettings: AppDependencyProvider.shared.appSettings,
            internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
            configurationStore: AppDependencyProvider.shared.configurationStore,
            database: Database.shared,
            errorEvents: RemoteMessagingStoreErrorHandling(),
            remoteMessagingAvailabilityProvider: PrivacyConfigurationRemoteMessagingAvailabilityProvider(
                privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager
            ),
            duckPlayerStorage: DefaultDuckPlayerStorage()
        )
        remoteMessagingClient.registerBackgroundRefreshTaskHandler()

        let subscriptionFeatureAvailability = DefaultSubscriptionFeatureAvailability(
            privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
            purchasePlatform: .appStore)

        subscriptionCookieManager = makeSubscriptionCookieManager()

        let homePageConfiguration = HomePageConfiguration(variantManager: AppDependencyProvider.shared.variantManager,
                                                          remoteMessagingClient: remoteMessagingClient,
                                                          privacyProDataReporter: privacyProDataReporter)


        let previewsSource = TabPreviewsSource()
        let historyManager = makeHistoryManager()
        let tabsModel = prepareTabsModel(previewsSource: previewsSource)

        privacyProDataReporter.injectTabsModel(tabsModel)

        if shouldPresentInsufficientDiskSpaceAlertAndCrash {

            self.appContext.window = UIWindow(frame: UIScreen.main.bounds)
            appContext.window?.rootViewController = BlankSnapshotViewController(addressBarPosition: appSettings.currentAddressBarPosition,
                                                                                voiceSearchHelper: voiceSearchHelper)
            appContext.window?.makeKeyAndVisible()

            presentInsufficientDiskSpaceAlert()
        } else {
            let daxDialogsFactory = ExperimentContextualDaxDialogsFactory(contextualOnboardingLogic: daxDialogs, contextualOnboardingPixelReporter: onboardingPixelReporter)
            let contextualOnboardingPresenter = ContextualOnboardingPresenter(variantManager: variantManager, daxDialogsFactory: daxDialogsFactory)
            let main = MainViewController(bookmarksDatabase: bookmarksDatabase,
                                          bookmarksDatabaseCleaner: syncDataProviders.bookmarksAdapter.databaseCleaner,
                                          historyManager: historyManager,
                                          homePageConfiguration: homePageConfiguration,
                                          syncService: syncService,
                                          syncDataProviders: syncDataProviders,
                                          appSettings: AppDependencyProvider.shared.appSettings,
                                          previewsSource: previewsSource,
                                          tabsModel: tabsModel,
                                          syncPausedStateManager: syncErrorHandler,
                                          privacyProDataReporter: privacyProDataReporter,
                                          variantManager: variantManager,
                                          contextualOnboardingPresenter: contextualOnboardingPresenter,
                                          contextualOnboardingLogic: daxDialogs,
                                          contextualOnboardingPixelReporter: onboardingPixelReporter,
                                          subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                          voiceSearchHelper: voiceSearchHelper,
                                          featureFlagger: AppDependencyProvider.shared.featureFlagger,
                                          fireproofing: fireproofing,
                                          subscriptionCookieManager: subscriptionCookieManager,
                                          textZoomCoordinator: makeTextZoomCoordinator(),
                                          websiteDataManager: makeWebsiteDataManager(fireproofing: fireproofing),
                                          appDidFinishLaunchingStartTime: appContext.didFinishLaunchingStartTime)

            main.loadViewIfNeeded()
            syncErrorHandler.alertPresenter = main

            self.appContext.window = UIWindow(frame: UIScreen.main.bounds)
            appContext.window?.rootViewController = main
            appContext.window?.makeKeyAndVisible()

            autoClear = AutoClear(worker: main)
            let applicationState = appContext.application.applicationState
            Task { [self] in // todo
                await autoClear.clearDataIfEnabled(applicationState: .init(with: applicationState))
                await vpnWorkaround.installRedditSessionWorkaround()
            }
        }

        voiceSearchHelper.migrateSettingsFlagIfNecessary()

        // Task handler registration needs to happen before the end of `didFinishLaunching`, otherwise submitting a task can throw an exception.
        // Having both in `didBecomeActive` can sometimes cause the exception when running on a physical device, so registration happens here.
        AppConfigurationFetch.registerBackgroundRefreshTaskHandler()

        UNUserNotificationCenter.current().delegate = unService

        appContext.window?.windowScene?.screenshotService?.delegate = uiService
        ThemeManager.shared.updateUserInterfaceStyle(window: appContext.window)

        // Temporary logic for rollout of Autofill as on by default for new installs only
        if AppDependencyProvider.shared.appSettings.autofillIsNewInstallForOnByDefault == nil {
            AppDependencyProvider.shared.appSettings.setAutofillIsNewInstallForOnByDefault()
        }

        NewTabPageIntroMessageSetup().perform()

        widgetRefreshModel.beginObservingVPNStatus()

        AppDependencyProvider.shared.subscriptionManager.loadInitialData()

        let autofillPixelReporter = AutofillPixelReporter(
            userDefaults: .standard,
            autofillEnabled: AppDependencyProvider.shared.appSettings.autofillCredentialsEnabled,
            eventMapping: EventMapping<AutofillPixelEvent> {event, _, params, _ in
                switch event {
                case .autofillActiveUser:
                    Pixel.fire(pixel: .autofillActiveUser)
                case .autofillEnabledUser:
                    Pixel.fire(pixel: .autofillEnabledUser)
                case .autofillOnboardedUser:
                    Pixel.fire(pixel: .autofillOnboardedUser)
                case .autofillToggledOn:
                    Pixel.fire(pixel: .autofillToggledOn, withAdditionalParameters: params ?? [:])
                case .autofillToggledOff:
                    Pixel.fire(pixel: .autofillToggledOff, withAdditionalParameters: params ?? [:])
                case .autofillLoginsStacked:
                    Pixel.fire(pixel: .autofillLoginsStacked, withAdditionalParameters: params ?? [:])
                default:
                    break
                }
            },
            installDate: StatisticsUserDefaults().installDate ?? Date())

        _ = NotificationCenter.default.addObserver(forName: AppUserDefaults.Notifications.autofillEnabledChange,
                                                   object: nil,
                                                   queue: nil) { /*[weak self]*/ _ in
            autofillPixelReporter.updateAutofillEnabledStatus(AppDependencyProvider.shared.appSettings.autofillCredentialsEnabled) // todo: autofillPixelReporter is local var
        }

        if appContext.didCrashDuringCrashHandlersSetUp {
            Pixel.fire(pixel: .crashOnCrashHandlersSetUp)
            self.appContext.didCrashDuringCrashHandlersSetUp = false
        }

        tipKitAppEventsHandler.appDidFinishLaunching()
    }

    var appDependencies: AppDependencies {
        AppDependencies(
            accountManager: accountManager,
            vpnWorkaround: vpnWorkaround,
            vpnFeatureVisibility: vpnFeatureVisibility,
            appSettings: appSettings,
            privacyStore: privacyStore,
            uiService: uiService,
            voiceSearchHelper: voiceSearchHelper,
            autoClear: autoClear,
            autofillLoginSession: autofillLoginSession,
            marketplaceAdPostbackManager: marketplaceAdPostbackManager,
            syncService: syncService,
            isSyncInProgressCancellable: isSyncInProgressCancellable,
            privacyProDataReporter: privacyProDataReporter,
            remoteMessagingClient: remoteMessagingClient,
            subscriptionService: SubscriptionService(subscriptionCookieManager: subscriptionCookieManager),
            onboardingPixelReporter: onboardingPixelReporter
        )
    }

    private func presentPreemptiveCrashAlert() {
        Task { @MainActor in
            let alertController = CriticalAlerts.makePreemptiveCrashAlert()
            appContext.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    private func cleanUpMacPromoExperiment2() {
        UserDefaults.standard.removeObject(forKey: "com.duckduckgo.ios.macPromoMay23.exp2.cohort")
    }

    private func cleanUpIncrementalRolloutPixelTest() {
        UserDefaults.standard.removeObject(forKey: "network-protection.incremental-feature-flag-test.has-sent-pixel")
    }

    private func clearTmp() {
        let tmp = FileManager.default.temporaryDirectory
        do {
            try FileManager.default.removeItem(at: tmp)
        } catch {
            Logger.general.error("Failed to delete tmp dir")
        }
    }

    private func removeEmailWaitlistState() {
        EmailWaitlist.removeEmailState()

        let autofillStorage = EmailKeychainManager()
        try? autofillStorage.deleteWaitlistState()

        // Remove the authentication state if this is a fresh install.
        if !Database.shared.isDatabaseFileInitialized {
            try? autofillStorage.deleteAuthenticationState()
        }
    }

    private func cleanUpATBAndAssignVariant(variantManager: VariantManager, daxDialogs: DaxDialogs) {
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

    private func makeSubscriptionCookieManager() -> SubscriptionCookieManaging {
        let subscriptionCookieManager = SubscriptionCookieManager(subscriptionManager: AppDependencyProvider.shared.subscriptionManager,
                                                                  currentCookieStore: { //[weak self] in
//            guard self?.mainViewController?.tabManager.model.hasActiveTabs ?? false else { // TODO
//                // We shouldn't interact with WebKit's cookie store unless we have a WebView,
//                // eventually the subscription cookie will be refreshed on opening the first tab
//                return nil
//            }
            return WKHTTPCookieStoreWrapper(store: WKWebsiteDataStore.current().httpCookieStore)
        }, eventMapping: SubscriptionCookieManageEventPixelMapping())

        return subscriptionCookieManager
    }

    private func makeHistoryManager() -> HistoryManaging {

        let provider = AppDependencyProvider.shared

        switch HistoryManager.make(isAutocompleteEnabledByUser: provider.appSettings.autocomplete,
                                   isRecentlyVisitedSitesEnabledByUser: provider.appSettings.recentlyVisitedSites,
                                   privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager,
                                   tld: provider.storageCache.tld) {

        case .failure(let error):
            Pixel.fire(pixel: .historyStoreLoadFailed, error: error)
            if error.isDiskFull {
                self.presentInsufficientDiskSpaceAlert()
            } else {
                self.presentPreemptiveCrashAlert()
            }
            return NullHistoryManager()

        case .success(let historyManager):
            return historyManager
        }
    }

    private func presentInsufficientDiskSpaceAlert() {
        let alertController = CriticalAlerts.makeInsufficientDiskSpaceAlert()
        appContext.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    private func prepareTabsModel(previewsSource: TabPreviewsSource = TabPreviewsSource(),
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

    private func makeTextZoomCoordinator() -> TextZoomCoordinator {
        let provider = AppDependencyProvider.shared
        let storage = TextZoomStorage()

        return TextZoomCoordinator(appSettings: provider.appSettings,
                                   storage: storage,
                                   featureFlagger: provider.featureFlagger)
    }

    private func makeWebsiteDataManager(fireproofing: Fireproofing,
                                        dataStoreIDManager: DataStoreIDManaging = DataStoreIDManager.shared) -> WebsiteDataManaging {
        return WebCacheManager(cookieStorage: MigratableCookieStorage(),
                               fireproofing: fireproofing,
                               dataStoreIDManager: dataStoreIDManager)
    }


}
