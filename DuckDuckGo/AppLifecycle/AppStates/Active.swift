//
//  Active.swift
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
import UIKit
import BrowserServicesKit
import Core
import WidgetKit
import BackgroundTasks
import Subscription
import NetworkProtection

struct Active: AppState {

    let application: UIApplication
    let appDependencies: AppDependencies

    private let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
    private let tunnelDefaults = UserDefaults.networkProtectionGroupDefaults

    private var window: UIWindow {
        appDependencies.uiService.window
    }

    private var mainViewController: MainViewController {
        appDependencies.mainViewController
    }

    // MARK: handle one-time (after launch) logic here
    init(stateContext: Launched.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        defer {
            let launchTime = CFAbsoluteTimeGetCurrent() - stateContext.didFinishLaunchingStartTime
            Pixel.fire(pixel: .appDidBecomeActiveTime(time: Pixel.Event.BucketAggregation(number: launchTime)),
                       withAdditionalParameters: [PixelParameters.time: String(launchTime)])
        }

        // Keep track of feature flag changes
        let subscriptionCookieManager = appDependencies.subscriptionService.subscriptionCookieManager
        appDependencies.subscriptionService.onPrivacyConfigurationUpdate = { [privacyConfigurationManager] in
            let isEnabled = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(PrivacyProSubfeature.setAccessTokenCookieForSubscriptionDomains)

            Task { @MainActor in
                if isEnabled {
                    subscriptionCookieManager.enableSettingSubscriptionCookie()
                } else {
                    await subscriptionCookieManager.disableSettingSubscriptionCookie()
                }
            }
        }

        // onApplicationLaunch code
        Task { @MainActor [self] in // is capturing self here ok?
            await beginAuthentication()
            initialiseBackgroundFetch(application)
            applyAppearanceChanges()
            refreshRemoteMessages(remoteMessagingClient: appDependencies.remoteMessagingClient)
        }

        if let url = stateContext.urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = stateContext.shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle)
        }

        activateApp(isTesting: stateContext.isTesting)
    }

    // MARK: handle applicationWillEnterForeground(_:) logic here
    init(stateContext: Background.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        ThemeManager.shared.updateUserInterfaceStyle()

        let uiService = appDependencies.uiService
        let syncService = appDependencies.syncService
        let autoClear = appDependencies.autoClear
        Task { @MainActor [self] in // is capturing self here ok?
            await beginAuthentication(lastBackgroundDate: stateContext.lastBackgroundDate)
            await autoClear.clearDataIfEnabledAndTimeExpired(applicationState: .active)
            uiService.showKeyboardIfSettingOn = true
            syncService.scheduler.resumeSyncQueue()
        }

        if let url = stateContext.urlToOpen {
            openURL(url)
        }

        activateApp()
    }

    init(stateContext: Inactive.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        activateApp()
    }

    // MARK: handle applicationDidBecomeActive(_:) logic here
    private func activateApp(isTesting: Bool = false) {
        guard !isTesting else { return } // Leaving this as is for now to ensure this code is never executed, regardless of where it's called from.
        // In the future, we may consider creating separate states specifically for testing purposes.
        StorageInconsistencyMonitor().didBecomeActive(isProtectedDataAvailable: application.isProtectedDataAvailable)
        appDependencies.syncService.initializeIfNeeded()
        appDependencies.syncDataProviders.setUpDatabaseCleanersIfNeeded(syncService: appDependencies.syncService)

        if !(appDependencies.uiService.overlayWindow?.rootViewController is AuthenticationViewController) {
            appDependencies.uiService.removeOverlay()
        }

        StatisticsLoader.shared.load {
            StatisticsLoader.shared.refreshAppRetentionAtb()
            self.fireAppLaunchPixel()
            self.reportAdAttribution()
            self.appDependencies.onboardingPixelReporter.fireEnqueuedPixelsIfNeeded()
        }

        mainViewController.showBars()
        mainViewController.didReturnFromBackground()

        if !appDependencies.privacyStore.authenticationEnabled {
            showKeyboardOnLaunch()
        }

        if AppConfigurationFetch.shouldScheduleRulesCompilationOnAppLaunch {
            ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
            AppConfigurationFetch.shouldScheduleRulesCompilationOnAppLaunch = false
        }
        AppDependencyProvider.shared.configurationManager.loadPrivacyConfigFromDiskIfNeeded()

        AppConfigurationFetch().start { result in
            self.sendAppLaunchPostback(marketplaceAdPostbackManager: appDependencies.marketplaceAdPostbackManager)
            if case .assetsUpdated(let protectionsUpdated) = result, protectionsUpdated {
                ContentBlocking.shared.contentBlockingManager.scheduleCompilation()
            }
        }

        appDependencies.syncService.scheduler.notifyAppLifecycleEvent()

        appDependencies.privacyProDataReporter.injectSyncService(appDependencies.syncService)

        fireFailedCompilationsPixelIfNeeded()

        appDependencies.widgetRefreshModel.refreshVPNWidget()

        if tunnelDefaults.showEntitlementAlert {
            presentExpiredEntitlementAlert()
        }

        presentExpiredEntitlementNotificationIfNeeded()

        Task {
            await stopAndRemoveVPNIfNotAuthenticated()
            await application.refreshVPNShortcuts(vpnFeatureVisibility: appDependencies.vpnFeatureVisibility,
                                                  accountManager: appDependencies.accountManager)
            await appDependencies.vpnWorkaround.installRedditSessionWorkaround()

            if #available(iOS 17.0, *) {
                await VPNSnoozeLiveActivityManager().endSnoozeActivityIfNecessary()
            }
        }

        AppDependencyProvider.shared.subscriptionManager.refreshCachedSubscriptionAndEntitlements { isSubscriptionActive in
            if isSubscriptionActive {
                DailyPixel.fire(pixel: .privacyProSubscriptionActive)
            }
        }

        Task {
            await appDependencies.subscriptionService.subscriptionCookieManager.refreshSubscriptionCookie()
        }

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(syncService: appDependencies.syncService)
        importPasswordsStatusHandler.checkSyncSuccessStatus()

        Task {
            await appDependencies.privacyProDataReporter.saveWidgetAdded()
        }

        AppDependencyProvider.shared.persistentPixel.sendQueuedPixels { _ in }
    }

    // MARK: handle application(_:open:options:) logic here
    func openURL(_ url: URL) {
         Logger.sync.debug("App launched with url \(url.absoluteString)")
         // If showing the onboarding intro ignore deeplinks
         guard mainViewController.needsToShowOnboardingIntro() == false else {
             return
         }

         if handleEmailSignUpDeepLink(url) {
             return
         }

         NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

         // The openVPN action handles the navigation stack on its own and does not need it to be cleared
         if url != AppDeepLinkSchemes.openVPN.url {
             mainViewController.clearNavigationStack()
         }

         Task { @MainActor in
             // Autoclear should have happened by now
             appDependencies.uiService.showKeyboardIfSettingOn = false

             if !handleAppDeepLink(application, mainViewController, url) {
                 mainViewController.loadUrlInNewTab(url, reuseExisting: true, inheritedAttribution: nil, fromExternalLink: true)
             }
         }
    }

    @MainActor
    private func beginAuthentication(lastBackgroundDate: Date? = nil) async {
        guard appDependencies.privacyStore.authenticationEnabled else { return }

        let uiService = appDependencies.uiService
        uiService.removeOverlay()
        uiService.displayAuthenticationWindow()

        guard let controller = uiService.overlayWindow?.rootViewController as? AuthenticationViewController else {
            uiService.removeOverlay()
            return
        }

        await controller.beginAuthentication {
            uiService.removeOverlay()
            showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
        }
    }

    private func showKeyboardOnLaunch(lastBackgroundDate: Date? = nil) {
        guard KeyboardSettings().onAppLaunch && appDependencies.uiService.showKeyboardIfSettingOn && shouldShowKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainViewController.enterSearch()
        }
        appDependencies.uiService.showKeyboardIfSettingOn = false
    }

    private func shouldShowKeyboardOnLaunch(lastBackgroundDate: Date? = nil) -> Bool {
        guard let lastBackgroundDate else { return true }
        return Date().timeIntervalSince(lastBackgroundDate) > AppDelegate.ShowKeyboardOnLaunchThreshold
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

    private func sendAppLaunchPostback(marketplaceAdPostbackManager: MarketplaceAdPostbackManaging) {
        // Attribution support
        let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
        if privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .marketplaceAdPostback) {
            marketplaceAdPostbackManager.sendAppLaunchPostback()
        }
    }

    private func reportAdAttribution() {
        Task.detached(priority: .background) {
            await AdAttributionPixelReporter.shared.reportAttributionIfNeeded()
        }
    }

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

            let hasRemoteMessageFetchTask = tasks.contains { $0.identifier == RemoteMessagingClient.Constants.backgroundRefreshTaskIdentifier }
            if !hasRemoteMessageFetchTask {
                RemoteMessagingClient.scheduleBackgroundRefreshTask()
            }
        }
    }

    private func applyAppearanceChanges() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    /// It's public in order to allow refreshing on demand via Debug menu. Otherwise it shouldn't be called from outside.
    func refreshRemoteMessages(remoteMessagingClient: RemoteMessagingClient) {
        Task {
            try? await remoteMessagingClient.fetchAndProcess(using: remoteMessagingClient.store)
        }
    }

    private func presentExpiredEntitlementAlert() {
        let alertController = CriticalAlerts.makeExpiredEntitlementAlert { [weak mainViewController] in
            mainViewController?.segueToPrivacyPro()
        }
        window.rootViewController?.present(alertController, animated: true) { [weak tunnelDefaults] in
            tunnelDefaults?.showEntitlementAlert = false
        }
    }

    private func handleEmailSignUpDeepLink(_ url: URL) -> Bool {
        guard url.absoluteString.starts(with: URL.emailProtection.absoluteString),
              let navViewController = mainViewController.presentedViewController as? UINavigationController,
              let emailSignUpViewController = navViewController.topViewController as? EmailSignupViewController else {
            return false
        }
        emailSignUpViewController.loadUrl(url)
        return true
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

    private func stopAndRemoveVPNIfNotAuthenticated() async {
        // Only remove the VPN if the user is not authenticated, and it's installed:
        guard !appDependencies.accountManager.isUserAuthenticated, await AppDependencyProvider.shared.networkProtectionTunnelController.isInstalled else {
            return
        }

        await AppDependencyProvider.shared.networkProtectionTunnelController.stop()
        await AppDependencyProvider.shared.networkProtectionTunnelController.removeVPN(reason: .didBecomeActiveCheck)
    }

    private func presentExpiredEntitlementNotificationIfNeeded() {
        let presenter = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: AppDependencyProvider.shared.vpnSettings,
            defaults: .networkProtectionGroupDefaults,
            wrappee: NetworkProtectionUNNotificationPresenter()
        )
        presenter.showEntitlementNotification()
    }


    @MainActor
    func handleAppDeepLink(_ app: UIApplication, _ mainViewController: MainViewController?, _ url: URL) -> Bool {
        guard let mainViewController else { return false }

        switch AppDeepLinkSchemes.fromURL(url) {

        case .newSearch:
            mainViewController.newTab(reuseExisting: true)
            mainViewController.enterSearch()

        case .favorites:
            mainViewController.newTab(reuseExisting: true, allowingKeyboard: false)

        case .quickLink:
            let query = AppDeepLinkSchemes.query(fromQuickLink: url)
            mainViewController.loadQueryInNewTab(query, reuseExisting: true)

        case .addFavorite:
            mainViewController.startAddFavoriteFlow()

        case .fireButton:
            mainViewController.forgetAllWithAnimation()

        case .voiceSearch:
            mainViewController.onVoiceSearchPressed()

        case .newEmail:
            mainViewController.newEmailAddress()

        case .openVPN:
            presentNetworkProtectionStatusSettingsModal()

        case .openPasswords:
            var source: AutofillSettingsSource = .homeScreenWidget

            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItems = components.queryItems,
                queryItems.first(where: { $0.name == "ls" }) != nil {
                Pixel.fire(pixel: .autofillLoginsLaunchWidgetLock)
                source = .lockScreenWidget
            } else {
                Pixel.fire(pixel: .autofillLoginsLaunchWidgetHome)
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                mainViewController.launchAutofillLogins(openSearch: true, source: source)
            }

        default:
            guard app.applicationState == .active,
                  let currentTab = mainViewController.currentTab else {
                return false
            }

            // If app is in active state, treat this navigation as something initiated form the context of the current tab.
            mainViewController.tab(currentTab,
                                   didRequestNewTabForUrl: url,
                                   openedByPage: true,
                                   inheritingAttribution: nil)
        }

        return true
    }

    @MainActor
    func presentNetworkProtectionStatusSettingsModal() {
        Task {
            if case .success(let hasEntitlements) = await appDependencies.accountManager.hasEntitlement(forProductName: .networkProtection), hasEntitlements {
                (window.rootViewController as? MainViewController)?.segueToVPN()
            } else {
                (window.rootViewController as? MainViewController)?.segueToPrivacyPro()
            }
        }
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        Logger.general.debug("Handling shortcut item: \(shortcutItem.type)")

        Task { @MainActor in
            if shortcutItem.type == AppDelegate.ShortcutKey.clipboard, let query = UIPasteboard.general.string {
                mainViewController.clearNavigationStack()
                mainViewController.loadQueryInNewTab(query)
                return
            }

            if shortcutItem.type == AppDelegate.ShortcutKey.passwords {
                mainViewController.clearNavigationStack()
                // Give the `clearNavigationStack` call time to complete.
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [application] in
                    (application.window?.rootViewController as? MainViewController)?.launchAutofillLogins(openSearch: true, source: .appIconShortcut)
                }
                Pixel.fire(pixel: .autofillLoginsLaunchAppShortcut)
                return
            }

            if shortcutItem.type == AppDelegate.ShortcutKey.openVPNSettings {
                presentNetworkProtectionStatusSettingsModal()
            }

        }
    }

}

extension Active {

    struct StateContext {

        let application: UIApplication
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(
            application: application,
            appDependencies: appDependencies
        )
    }

}
