//
//  AppDelegate.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import UIKit
import Combine
import Common
import Core
import UserNotifications
import Kingfisher
import WidgetKit
import BackgroundTasks
import BrowserServicesKit
import Bookmarks
import Persistence
import Crashes
import Configuration
import Networking
import DDGSync
import SyncDataProviders
import Subscription

#if NETWORK_PROTECTION
import NetworkProtection
import WebKit
#endif

// swiftlint:disable file_length
// swiftlint:disable type_body_length
@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    // swiftlint:enable type_body_length
    
    private static let ShowKeyboardOnLaunchThreshold = TimeInterval(20)
    private struct ShortcutKey {
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
        static let passwords = "com.duckduckgo.mobile.ios.passwords"

#if NETWORK_PROTECTION
        static let openVPNSettings = "com.duckduckgo.mobile.ios.vpn.open-settings"
#endif
    }

    private var testing = false
    var appIsLaunching = false
    var overlayWindow: UIWindow?
    var window: UIWindow?

    private lazy var privacyStore = PrivacyUserDefaults()
    private var bookmarksDatabase: CoreDataDatabase = BookmarksDatabase.make()

#if NETWORK_PROTECTION
    private let widgetRefreshModel = NetworkProtectionWidgetRefreshModel()
    private let tunnelDefaults = UserDefaults.networkProtectionGroupDefaults
#endif

    private var autoClear: AutoClear?
    private var showKeyboardIfSettingOn = true
    private var lastBackgroundDate: Date?

    private(set) var syncService: DDGSync!
    private(set) var syncDataProviders: SyncDataProviders!
    private var syncDidFinishCancellable: AnyCancellable?
    private var syncStateCancellable: AnyCancellable?
    private var isSyncInProgressCancellable: AnyCancellable?

    private let crashCollection = CrashCollection(platform: .iOS, log: .generalLog)
    private var crashReportUploaderOnboarding: CrashCollectionOnboarding?

    // MARK: lifecycle

    @UserDefaultsWrapper(key: .privacyConfigCustomURL, defaultValue: nil)
    private var privacyConfigCustomURL: String?

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // SKAD4 support
        updateSKAd(conversionValue: 1)

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

#if DEBUG && !ALPHA
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

        crashCollection.start { pixelParameters, payloads, sendReport in
            pixelParameters.forEach { params in
                Pixel.fire(pixel: .dbCrashDetected, withAdditionalParameters: params, includedParameters: [])
            }

            // Async dispatch because rootViewController may otherwise be nil here
            DispatchQueue.main.async {
                guard let viewController = self.window?.rootViewController else {
                    return
                }
                let dataPayloads = payloads.map { $0.jsonRepresentation() }
                let crashReportUploaderOnboarding = CrashCollectionOnboarding(appSettings: AppDependencyProvider.shared.appSettings)
                crashReportUploaderOnboarding.presentOnboardingIfNeeded(for: dataPayloads, from: viewController, sendReport: sendReport)
                self.crashReportUploaderOnboarding = crashReportUploaderOnboarding
            }
        }

        clearTmp()

        _ = DefaultUserAgentManager.shared
        testing = ProcessInfo().arguments.contains("testing")
        if testing {
            Pixel.isDryRun = true
            _ = DefaultUserAgentManager.shared
            Database.shared.loadStore { _, _ in }
            _ = BookmarksDatabaseSetup(crashOnError: true).loadStoreAndMigrate(bookmarksDatabase: bookmarksDatabase)
            window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            return true
        }

        removeEmailWaitlistState()

        var shouldPresentInsufficientDiskSpaceAlertAndCrash = false
        Database.shared.loadStore { context, error in
            guard let context = context else {
                
                let parameters = [PixelParameters.applicationState: "\(application.applicationState.rawValue)",
                                  PixelParameters.dataAvailability: "\(application.isProtectedDataAvailable)"]

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

        if BookmarksDatabaseSetup(crashOnError: !shouldPresentInsufficientDiskSpaceAlertAndCrash)
                .loadStoreAndMigrate(bookmarksDatabase: bookmarksDatabase) {
            // MARK: post-Bookmarks migration logic
        }

        WidgetCenter.shared.reloadAllTimelines()

        Favicons.shared.migrateFavicons(to: Favicons.Constants.maxFaviconSize) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        PrivacyFeatures.httpsUpgrade.loadDataAsync()
        
        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        AtbAndVariantCleanup.cleanup()
        DefaultVariantManager().assignVariantIfNeeded { _ in
            // MARK: perform first time launch logic here
            DaxDialogs.shared.primeForUse()
        }

        PixelExperimentForBrokenSites.install()
        PixelExperiment.install()

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
            secureVaultErrorReporter: SecureVaultReporter.shared,
            settingHandlers: [FavoritesDisplayModeSyncHandler()],
            favoritesDisplayModeStorage: FavoritesDisplayModeStorage(),
            syncErrorHandler: syncErrorHandler
        )

        let syncService = DDGSync(
            dataProvidersSource: syncDataProviders,
            errorEvents: SyncErrorHandler(),
            privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
            log: .syncLog,
            environment: environment
        )
        syncService.initializeIfNeeded()
        self.syncService = syncService

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

        let previewsSource = TabPreviewsSource()
        let historyManager = makeHistoryManager()
        let tabsModel = prepareTabsModel(previewsSource: previewsSource)

        let main = MainViewController(bookmarksDatabase: bookmarksDatabase,
                                      bookmarksDatabaseCleaner: syncDataProviders.bookmarksAdapter.databaseCleaner,
                                      historyManager: historyManager,
                                      syncService: syncService,
                                      syncDataProviders: syncDataProviders,
                                      appSettings: AppDependencyProvider.shared.appSettings,
                                      previewsSource: previewsSource,
                                      tabsModel: tabsModel,
                                      syncPausedStateManager: syncErrorHandler)

        main.loadViewIfNeeded()
        syncErrorHandler.alertPresenter = main

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = main
        window?.makeKeyAndVisible()

        if shouldPresentInsufficientDiskSpaceAlertAndCrash {
            presentInsufficientDiskSpaceAlert()
        }

        autoClear = AutoClear(worker: main)
        Task {
            await autoClear?.clearDataIfEnabled(launching: true)
        }

        AppDependencyProvider.shared.voiceSearchHelper.migrateSettingsFlagIfNecessary()

        // Task handler registration needs to happen before the end of `didFinishLaunching`, otherwise submitting a task can throw an exception.
        // Having both in `didBecomeActive` can sometimes cause the exception when running on a physical device, so registration happens here.
        AppConfigurationFetch.registerBackgroundRefreshTaskHandler()

        RemoteMessaging.registerBackgroundRefreshTaskHandler(
            bookmarksDatabase: bookmarksDatabase,
            favoritesDisplayMode: AppDependencyProvider.shared.appSettings.favoritesDisplayMode
        )

        UNUserNotificationCenter.current().delegate = self
        
        window?.windowScene?.screenshotService?.delegate = self
        ThemeManager.shared.updateUserInterfaceStyle(window: window)

        appIsLaunching = true

        // Temporary logic for rollout of Autofill as on by default for new installs only
        if AppDependencyProvider.shared.appSettings.autofillIsNewInstallForOnByDefault == nil {
            AppDependencyProvider.shared.appSettings.setAutofillIsNewInstallForOnByDefault()
        }

#if NETWORK_PROTECTION
        widgetRefreshModel.beginObservingVPNStatus()
        AppDependencyProvider.shared.networkProtectionAccessController.refreshNetworkProtectionAccess()
#endif

        if AppDependencyProvider.shared.vpnFeatureVisibility.shouldKeepVPNAccessViaWaitlist() {
            clearDebugWaitlistState()
        }

        AppDependencyProvider.shared.toggleProtectionsCounter.sendEventsIfNeeded()

        AppDependencyProvider.shared.userBehaviorMonitor.handleAction(.reopenApp)

        return true
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

    private func makeHistoryManager() -> HistoryManager {
        let historyManager = HistoryManager(privacyConfigManager: ContentBlocking.shared.privacyConfigurationManager,
                              variantManager: DefaultVariantManager(),
                              database: HistoryDatabase.make()) { error in
            Pixel.fire(pixel: .historyStoreLoadFailed, error: error)
            if error.isDiskFull {
                self.presentInsufficientDiskSpaceAlert()
            } else {
                self.presentPreemptiveCrashAlert()
            }
        }

        // This is a compromise to support hot reloading via privacy config.
        //  * If the history is disabled this will do nothing. If it is subsequently enabled then it won't start collecting history
        //     until the app cold launches at least once.
        //  * If the history is enabled this loads the store sets up the history manager
        //     correctly. If the history manager is subsequently disabled it will stop working immediately.
        historyManager.loadStore()
        return historyManager
    }

    private func presentPreemptiveCrashAlert() {
        Task { @MainActor in
            let alertController = CriticalAlerts.makePreemptiveCrashAlert()
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    private func presentInsufficientDiskSpaceAlert() {
        let alertController = CriticalAlerts.makeInsufficientDiskSpaceAlert()
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

#if NETWORK_PROTECTION
    private func presentExpiredEntitlementAlert() {
        let alertController = CriticalAlerts.makeExpiredEntitlementAlert { [weak self] in
            self?.mainViewController?.segueToPrivacyPro()
        }
        window?.rootViewController?.present(alertController, animated: true) { [weak self] in
            DailyPixel.fireDailyAndCount(pixel: .privacyProVPNAccessRevokedDialogShown)
            self?.tunnelDefaults.showEntitlementAlert = false
        }
    }

    private func presentExpiredEntitlementNotificationIfNeeded() {
        let presenter = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: VPNSettings(defaults: .networkProtectionGroupDefaults),
            defaults: .networkProtectionGroupDefaults,
            wrappee: NetworkProtectionUNNotificationPresenter()
        )
        presenter.showEntitlementNotification()
    }
#endif

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
            os_log("Failed to delete tmp dir")
        }
    }

    private func reportAdAttribution() {
        guard AdAttributionPixelReporter.isAdAttributionReportingEnabled else { return }

        Task.detached(priority: .background) {
            await AdAttributionPixelReporter.shared.reportAttributionIfNeeded()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard !testing else { return }

        syncService.initializeIfNeeded()
        if syncService.authState == .active &&
            (InternalUserStore().isInternalUser == false && syncService.serverEnvironment == .development) {
            UniquePixel.fire(pixel: .syncWrongEnvironment)
        }
        syncDataProviders.setUpDatabaseCleanersIfNeeded(syncService: syncService)

        if !(overlayWindow?.rootViewController is AuthenticationViewController) {
            removeOverlay()
        }
        
        StatisticsLoader.shared.load {
            StatisticsLoader.shared.refreshAppRetentionAtb()
            self.fireAppLaunchPixel()
            self.firePrivacyProFeatureEnabledPixel()
            self.reportAdAttribution()
        }
        
        if appIsLaunching {
            appIsLaunching = false
            onApplicationLaunch(application)
        }

        mainViewController?.showBars()
        mainViewController?.didReturnFromBackground()
        
        if !privacyStore.authenticationEnabled {
            showKeyboardOnLaunch()
        }

        if AppConfigurationFetch.shouldScheduleRulesCompilationOnAppLaunch {
            ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
            AppConfigurationFetch.shouldScheduleRulesCompilationOnAppLaunch = false
        }

        AppConfigurationFetch().start { result in
            if case .assetsUpdated(let protectionsUpdated) = result, protectionsUpdated {
                ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
            }
        }

        checkWaitlists()
        syncService.scheduler.notifyAppLifecycleEvent()
        fireFailedCompilationsPixelIfNeeded()
        refreshShortcuts()

#if NETWORK_PROTECTION
        widgetRefreshModel.refreshVPNWidget()

        stopTunnelAndShowThankYouMessagingIfNeeded()

        if tunnelDefaults.showEntitlementAlert {
            presentExpiredEntitlementAlert()
        }

        presentExpiredEntitlementNotificationIfNeeded()
#endif

        updateSubscriptionStatus()

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(syncService: syncService)
        importPasswordsStatusHandler.checkSyncSuccessStatus()
    }

    private func stopTunnelAndShowThankYouMessagingIfNeeded() {

        if AppDependencyProvider.shared.accountManager.isUserAuthenticated {
            tunnelDefaults.vpnEarlyAccessOverAlertAlreadyShown = true
            return
        }

        if AppDependencyProvider.shared.vpnFeatureVisibility.shouldShowThankYouMessaging()
            && !tunnelDefaults.vpnEarlyAccessOverAlertAlreadyShown {
            Task {
                await self.stopAndRemoveVPN(with: "thank-you-dialog")
            }
        } else if AppDependencyProvider.shared.vpnFeatureVisibility.isPrivacyProLaunched()
                    && !AppDependencyProvider.shared.accountManager.isUserAuthenticated {
            Task {
                await self.stopAndRemoveVPN(with: "subscription-check")
            }
        }
    }

    private func stopAndRemoveVPN(with reason: String) async {
        guard await AppDependencyProvider.shared.networkProtectionTunnelController.isInstalled else {
            return
        }

        let isConnected = await AppDependencyProvider.shared.networkProtectionTunnelController.isConnected

        DailyPixel.fireDailyAndCount(pixel: .privacyProVPNBetaStoppedWhenPrivacyProEnabled, withAdditionalParameters: [
            "reason": reason,
            "vpn-connected": String(isConnected)
        ])

        await AppDependencyProvider.shared.networkProtectionTunnelController.stop()
        await AppDependencyProvider.shared.networkProtectionTunnelController.removeVPN()
    }

    func updateSubscriptionStatus() {
        Task {
            guard let token = AppDependencyProvider.shared.accountManager.accessToken else { return }
            var subscriptionService: SubscriptionService {
                AppDependencyProvider.shared.subscriptionManager.subscriptionService
            }
            if case .success(let subscription) = await subscriptionService.getSubscription(accessToken: token,
                                                                                           cachePolicy: .reloadIgnoringLocalCacheData) {
                if subscription.isActive {
                    DailyPixel.fire(pixel: .privacyProSubscriptionActive)
                }
            }
            await AppDependencyProvider.shared.accountManager.fetchEntitlements(cachePolicy: .reloadIgnoringLocalCacheData)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        refreshShortcuts()
    }

    private func fireAppLaunchPixel() {
        
        WidgetCenter.shared.getCurrentConfigurations { result in
            let paramKeys: [WidgetFamily: String] = [
                .systemSmall: PixelParameters.widgetSmall,
                .systemMedium: PixelParameters.widgetMedium,
                .systemLarge: PixelParameters.widgetLarge
            ]
            
            switch result {
            case .failure(let error):
                Pixel.fire(pixel: .appLaunch, withAdditionalParameters: [
                    PixelParameters.widgetError: "1",
                    PixelParameters.widgetErrorCode: "\((error as NSError).code)",
                    PixelParameters.widgetErrorDomain: (error as NSError).domain
                ], includedParameters: [.appVersion, .atb])
                
            case .success(let widgetInfo):
                let params = widgetInfo.reduce([String: String]()) {
                    var result = $0
                    if let key = paramKeys[$1.family] {
                        result[key] = "1"
                    }
                    return result
                }
                Pixel.fire(pixel: .appLaunch, withAdditionalParameters: params, includedParameters: [.appVersion, .atb])
            }
            
        }
    }

    private func firePrivacyProFeatureEnabledPixel() {
        let subscriptionFeatureAvailability = AppDependencyProvider.shared.subscriptionFeatureAvailability
        guard subscriptionFeatureAvailability.isFeatureAvailable,
              subscriptionFeatureAvailability.isSubscriptionPurchaseAllowed else {
            return
        }

        DailyPixel.fire(pixel: .privacyProFeatureEnabled)
    }

    private func fireFailedCompilationsPixelIfNeeded() {
        let store = FailedCompilationsStore()
        if store.hasAnyFailures {
            DailyPixel.fire(pixel: .compilationFailed, withAdditionalParameters: store.summary) { error in
                guard error != nil else { return }
                store.cleanup()
            }
        }
    }
    
    private func shouldShowKeyboardOnLaunch() -> Bool {
        guard let date = lastBackgroundDate else { return true }
        return Date().timeIntervalSince(date) > AppDelegate.ShowKeyboardOnLaunchThreshold
    }

    private func showKeyboardOnLaunch() {
        guard KeyboardSettings().onAppLaunch && showKeyboardIfSettingOn && shouldShowKeyboardOnLaunch() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainViewController?.enterSearch()
        }
        showKeyboardIfSettingOn = false
    }
    
    private func onApplicationLaunch(_ application: UIApplication) {
        Task { @MainActor in
            await beginAuthentication()
            initialiseBackgroundFetch(application)
            applyAppearanceChanges()
            refreshRemoteMessages()
        }
    }
    
    private func applyAppearanceChanges() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    private func refreshRemoteMessages() {
        Task {
            try? await RemoteMessaging.fetchAndProcess(
                bookmarksDatabase: self.bookmarksDatabase,
                favoritesDisplayMode: AppDependencyProvider.shared.appSettings.favoritesDisplayMode
            )
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        ThemeManager.shared.updateUserInterfaceStyle()

        Task { @MainActor in
            await beginAuthentication()
            await autoClear?.clearDataIfEnabledAndTimeExpired()
            showKeyboardIfSettingOn = true
            syncService.scheduler.resumeSyncQueue()
        }

        AppDependencyProvider.shared.userBehaviorMonitor.handleAction(.reopenApp)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        displayBlankSnapshotWindow()
        autoClear?.startClearingTimer()
        lastBackgroundDate = Date()
        AppDependencyProvider.shared.autofillLoginSession.endSession()
        suspendSync()
        syncDataProviders.bookmarksAdapter.cancelFaviconsFetching(application)
    }

    private func suspendSync() {
        if syncService.isSyncInProgress {
            os_log(.debug, log: .syncLog, "Sync is in progress. Starting background task to allow it to gracefully complete.")

            var taskID: UIBackgroundTaskIdentifier!
            taskID = UIApplication.shared.beginBackgroundTask(withName: "Cancelled Sync Completion Task") {
                os_log(.debug, log: .syncLog, "Forcing background task completion")
                UIApplication.shared.endBackgroundTask(taskID)
            }
            syncDidFinishCancellable?.cancel()
            syncDidFinishCancellable = syncService.isSyncInProgressPublisher.filter { !$0 }
                .prefix(1)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    os_log(.debug, log: .syncLog, "Ending background task")
                    UIApplication.shared.endBackgroundTask(taskID)
                }
        }

        syncService.scheduler.cancelSyncAndSuspendSyncQueue()
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        handleShortCutItem(shortcutItem)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        os_log("App launched with url %s", log: .lifecycleLog, type: .debug, url.absoluteString)

        if handleEmailSignUpDeepLink(url) {
            return true
        }

        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

        // The openVPN action handles the navigation stack on its own and does not need it to be cleared
        if url != AppDeepLinkSchemes.openVPN.url {
            mainViewController?.clearNavigationStack()
        }

        Task { @MainActor in
            // Autoclear should have happened by now
            showKeyboardIfSettingOn = false

            if !handleAppDeepLink(app, mainViewController, url) {
                mainViewController?.loadUrlInNewTab(url, reuseExisting: true, inheritedAttribution: nil, fromExternalLink: true)
            }
        }

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        os_log(#function, log: .lifecycleLog, type: .debug)

        AppConfigurationFetch().start(isBackgroundFetch: true) { result in
            switch result {
            case .noData:
                completionHandler(.noData)
            case .assetsUpdated:
                completionHandler(.newData)
            }
        }
    }

    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }

    // MARK: private

    private func initialiseBackgroundFetch(_ application: UIApplication) {
        guard UIApplication.shared.backgroundRefreshStatus == .available else {
            return
        }

        // BackgroundTasks will automatically replace an existing task in the queue if one with the same identifier is queued, so we should only
        // schedule a task if there are none pending in order to avoid the config task getting perpetually replaced.
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            let hasConfigurationTask = tasks.contains { $0.identifier == AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier }
            if !hasConfigurationTask {
                AppConfigurationFetch.scheduleBackgroundRefreshTask()
            }

            let hasRemoteMessageFetchTask = tasks.contains { $0.identifier == RemoteMessaging.Constants.backgroundRefreshTaskIdentifier }
            if !hasRemoteMessageFetchTask {
                RemoteMessaging.scheduleBackgroundRefreshTask()
            }
        }
    }
    
    private func displayAuthenticationWindow() {
        guard overlayWindow == nil, let frame = window?.frame else { return }
        overlayWindow = UIWindow(frame: frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert
        overlayWindow?.rootViewController = AuthenticationViewController.loadFromStoryboard()
        overlayWindow?.makeKeyAndVisible()
        window?.isHidden = true
    }
    
    private func displayBlankSnapshotWindow() {
        guard overlayWindow == nil, let frame = window?.frame else { return }
        guard autoClear?.isClearingEnabled ?? false || privacyStore.authenticationEnabled else { return }
        
        overlayWindow = UIWindow(frame: frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert
        
        let overlay = BlankSnapshotViewController(appSettings: AppDependencyProvider.shared.appSettings)
        overlay.delegate = self

        overlayWindow?.rootViewController = overlay
        overlayWindow?.makeKeyAndVisible()
        window?.isHidden = true
    }

    private func beginAuthentication() async {
        
        guard privacyStore.authenticationEnabled else { return }

        removeOverlay()
        displayAuthenticationWindow()
        
        guard let controller = overlayWindow?.rootViewController as? AuthenticationViewController else {
            removeOverlay()
            return
        }
        
        await controller.beginAuthentication { [weak self] in
            self?.removeOverlay()
            self?.showKeyboardOnLaunch()
        }
    }
    
    private func tryToObtainOverlayWindow() {
        for window in UIApplication.shared.windows where window.rootViewController is BlankSnapshotViewController {
            overlayWindow = window
            return
        }
    }

    private func removeOverlay() {
        if overlayWindow == nil {
            tryToObtainOverlayWindow()
        }

        if let overlay = overlayWindow {
            overlay.isHidden = true
            overlayWindow = nil
            window?.makeKeyAndVisible()
        }
    }

    private func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
        os_log("Handling shortcut item: %s", log: .generalLog, type: .debug, shortcutItem.type)

        Task { @MainActor in

            if appIsLaunching {
                await autoClear?.clearDataIfEnabled()
            } else {
                await autoClear?.clearDataIfEnabledAndTimeExpired()
            }

            if shortcutItem.type == ShortcutKey.clipboard, let query = UIPasteboard.general.string {
                mainViewController?.clearNavigationStack()
                mainViewController?.loadQueryInNewTab(query)
                return
            }

            if shortcutItem.type == ShortcutKey.passwords {
                mainViewController?.clearNavigationStack()
                // Give the `clearNavigationStack` call time to complete.
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                    self?.mainViewController?.launchAutofillLogins(openSearch: true)
                }
                Pixel.fire(pixel: .autofillLoginsLaunchAppShortcut)
                return
            }

#if NETWORK_PROTECTION
            if shortcutItem.type == ShortcutKey.openVPNSettings {
                if AppDependencyProvider.shared.vpnFeatureVisibility.shouldShowVPNShortcut() {
                    presentNetworkProtectionStatusSettingsModal()
                }
            }
#endif

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

    private func handleEmailSignUpDeepLink(_ url: URL) -> Bool {
        guard url.absoluteString.starts(with: URL.emailProtection.absoluteString),
              let navViewController = mainViewController?.presentedViewController as? UINavigationController,
              let emailSignUpViewController = navViewController.topViewController as? EmailSignupViewController else {
            return false
        }
        emailSignUpViewController.loadUrl(url)
        return true
    }

    private var mainViewController: MainViewController? {
        return window?.rootViewController as? MainViewController
    }

    func refreshShortcuts() {
#if NETWORK_PROTECTION
        guard AppDependencyProvider.shared.vpnFeatureVisibility.shouldShowVPNShortcut() else {
            UIApplication.shared.shortcutItems = nil
            return
        }

        let items = [
            UIApplicationShortcutItem(type: ShortcutKey.openVPNSettings,
                                      localizedTitle: UserText.netPOpenVPNQuickAction,
                                      localizedSubtitle: nil,
                                      icon: UIApplicationShortcutIcon(templateImageName: "VPN-16"),
                                      userInfo: nil)
        ]

        UIApplication.shared.shortcutItems = items
#endif
    }

}

extension AppDelegate: BlankSnapshotViewRecoveringDelegate {
    
    func recoverFromPresenting(controller: BlankSnapshotViewController) {
        if overlayWindow == nil {
            tryToObtainOverlayWindow()
        }
        
        overlayWindow?.isHidden = true
        overlayWindow = nil
        window?.makeKeyAndVisible()
    }
    
}

extension AppDelegate: UIScreenshotServiceDelegate {
    func screenshotService(_ screenshotService: UIScreenshotService,
                           generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        guard let webView = mainViewController?.currentTab?.webView else {
            completionHandler(nil, 0, .zero)
            return
        }

        let zoomScale = webView.scrollView.zoomScale

        // The PDF's coordinate space has its origin at the bottom left, so the view's origin.y needs to be converted
        let visibleBounds = CGRect(
            x: webView.scrollView.contentOffset.x / zoomScale,
            y: (webView.scrollView.contentSize.height - webView.scrollView.contentOffset.y - webView.bounds.height) / zoomScale,
            width: webView.bounds.width / zoomScale,
            height: webView.bounds.height / zoomScale
        )

        webView.createPDF { result in
            let data = try? result.get()
            completionHandler(data, 0, visibleBounds)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let identifier = response.notification.request.identifier

#if NETWORK_PROTECTION
            if NetworkProtectionNotificationIdentifier(rawValue: identifier) != nil {
                Task {
                    if case .success(let hasEntitlements) = await AppDependencyProvider.shared.accountManager.hasEntitlement(for: .networkProtection),
                        hasEntitlements {
                        presentNetworkProtectionStatusSettingsModal()
                    }
                }
            }

            if AppDependencyProvider.shared.vpnFeatureVisibility.shouldKeepVPNAccessViaWaitlist(), identifier == VPNWaitlist.notificationIdentifier {
                presentNetworkProtectionWaitlistModal()
            }
#endif
        }

        completionHandler()
    }

#if NETWORK_PROTECTION
    private func presentNetworkProtectionWaitlistModal() {
        if #available(iOS 15, *) {
            let networkProtectionRoot = VPNWaitlistViewController(nibName: nil, bundle: nil)
            presentSettings(with: networkProtectionRoot)
        }
    }

    func presentNetworkProtectionStatusSettingsModal() {
        if #available(iOS 15, *) {
            let networkProtectionRoot = NetworkProtectionRootViewController()
            presentSettings(with: networkProtectionRoot)
        }
    }
#endif

    private func presentSettings(with viewController: UIViewController) {
        guard let window = window, let rootViewController = window.rootViewController as? MainViewController else { return }

        if let navigationController = rootViewController.presentedViewController as? UINavigationController {
            if let lastViewController = navigationController.viewControllers.last, lastViewController.isKind(of: type(of: viewController)) {
                // Avoid presenting dismissing and re-presenting the view controller if it's already visible:
                return
            } else {
                // Otherwise, replace existing view controllers with the presented one:
                navigationController.popToRootViewController(animated: false)
                navigationController.pushViewController(viewController, animated: false)
                return
            }
        }

        // If the previous checks failed, make sure the nav stack is reset and present the view controller from scratch:
        rootViewController.clearNavigationStack()

        // Give the `clearNavigationStack` call time to complete.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            rootViewController.segueToSettings()
            let navigationController = rootViewController.presentedViewController as? UINavigationController
            navigationController?.popToRootViewController(animated: false)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

private extension Error {

    var isDiskFull: Bool {
        let nsError = self as NSError
        if let underlyingError = nsError.userInfo["NSUnderlyingError"] as? NSError, underlyingError.code == 13 {
            return true
        }
        return false
    }

}
