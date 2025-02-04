//
//  Foreground.swift
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
import Core
import BackgroundTasks

/// Represents the state where the app is active and available for user interaction.
/// - Usage:
///   - This state is typically associated with the `applicationDidBecomeActive(_:)` method.
///   - The app transitions to this state after completing the launch process or resuming from the background.
///   - During this state, the app is fully interactive, and the user can engage with the app's UI.
/// - Transitions:
///   - `Suspending`: The app transitions to this state when it begins the process of moving to the background,
///     typically triggered by the `applicationWillResignActive(_:)` method, e.g.:
///     - When the user presses the home button, swipes up to the App Switcher, or receives a system interruption.
/// - Notes:
///   - This is one of the two long-living states in the app's lifecycle (along with `Background`).
@MainActor
struct Foreground: AppState {

    var appDependencies: AppDependencies
    private var mainCoordinator: MainCoordinator { appDependencies.mainCoordinator }

    private var urlToOpen: URL?
    private var shortcutItemToHandle: UIApplicationShortcutItem?
    private var lastBackgroundDate: Date?

    // MARK: - Handle logic when transitioning from Launched to Foreground
    /// This transition occurs when the app has completed its launch process and becomes active.
    /// Note: You want to add here code that will happen one-time per app lifecycle, but you require the UI to be active at this point!
    init(stateContext: Launching.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        configureGlobalAppearance()
        appDependencies.subscriptionService.onInitialForeground()
        appDependencies.configurationService.onInitialForeground()
        appDependencies.remoteMessagingService.onInitialForeground()

<<<<<<< HEAD
        /// Authentication triggers a transition to the `Suspending` state.
        /// Once authentication is completed, the app reenters the `Foreground` state.
        /// We escape early here to prevent executing foreground-related code twice.
        let authenticationService = appDependencies.authenticationService
        guard authenticationService.isAuthenticated else {
            authenticationService.beginAuthentication()
=======
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
        Task { @MainActor [self] in
            await beginAuthentication()
            initialiseBackgroundFetch(application)
            applyAppearanceChanges()
            refreshRemoteMessages(remoteMessagingClient: appDependencies.remoteMessagingClient)
        }

        // TODO: it should happen after autoclear
        if let url = stateContext.urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = stateContext.shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: true)
        }

        activateApp()
    }

    // MARK: Handle logic when transitioning from Resuming to Foreground
    // This transition occurs when the app returns to the foreground after being backgrounded (e.g., after unlocking the app).
    init(stateContext: Resuming.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        // TODO: it should happen after autoclear
        if let url = stateContext.urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = stateContext.shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: false)
        }

        activateApp()
    }

    // MARK: Handle logic when transitioning from Suspending to Foreground
    // This transition occurs when the app returns to the foreground after briefly being suspended (e.g., user dismisses a notification).
    init(stateContext: Suspending.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        if let url = stateContext.urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = stateContext.shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: false)
        }

        activateApp()
    }

    // MARK: handle applicationDidBecomeActive(_:) logic here
    private func activateApp(isTesting: Bool = false) {
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
        if url != AppDeepLinkSchemes.openVPN.url && url.scheme != AppDeepLinkSchemes.openAIChat.url.scheme {
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
>>>>>>> main
            return
        }

        onForeground()
    }

    private func configureGlobalAppearance() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    // MARK: - Handle logic when transitioning from Resuming to Foreground
    /// This transition occurs when the app returns to the foreground after being backgrounded (e.g., after unlocking the app).
    init(stateContext: Resuming.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle
        lastBackgroundDate = stateContext.lastBackgroundDate

        /// Authentication triggers a transition to the `Suspending` state.
        /// Once authentication is completed, the app reenters the `Foreground` state.
        /// We escape early here to prevent executing foreground-related code twice.
        let authenticationService = appDependencies.authenticationService
        guard authenticationService.isAuthenticated else {
            authenticationService.beginAuthentication()
            return
        }

        onForeground()
    }

    // MARK: - Handle logic when transitioning from Suspending to Foreground
    /// This transition occurs when the app returns to the foreground after briefly being suspended (e.g., user dismisses a notification).
    init(stateContext: Suspending.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        onForeground()
    }

    // MARK: - Handle applicationDidBecomeActive(_:) logic here
    /// Before adding code here, ensure it does not depend on pending tasks:
    /// - If AutoClear needs to complete, put your code in `onDataCleared`.
    /// - If install/search statistics are required, see `onStatisticsLoaded`.
    /// - If crucial configuration files (e.g., TDS, privacy config) are needed, see `onConfigurationFetched`.
    private func onForeground() {
        appDependencies.autoClearService.registerForDataCleared(onDataCleared)

        appDependencies.syncService.onForeground()

        StatisticsLoader.shared.load(completion: onStatisticsLoaded)

        mainCoordinator.onForeground()

        appDependencies.configurationService.onConfigurationFetched = onConfigurationFetched
        appDependencies.configurationService.onForeground()

        appDependencies.vpnService.onForeground()
        appDependencies.subscriptionService.onForeground()
        appDependencies.autofillService.syncService = appDependencies.syncService
        appDependencies.autofillService.onForeground()

<<<<<<< HEAD
        appDependencies.reportingService.syncService = appDependencies.syncService
        appDependencies.reportingService.onForeground()
=======
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
        case .openAIChat:
            AIChatDeepLinkHandler().handleDeepLink(url, on: mainViewController)
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
>>>>>>> main
    }

    // MARK: - Handle AutoClear completion logic here
    /// Callback for the AutoClear feature, triggered when all browser data is cleared.
    /// This includes closing all tabs, clearing caches, and wiping `WKWebsiteDataStore.default()`.
    /// Place any code here related to browser navigation or web view handling
    /// to ensure it remains unaffected by the clearing process.
    private func onDataCleared() {
        appDependencies.vpnService.onDataCleared()
        handleLaunchActions()
    }

    private func handleLaunchActions() {
        if let url = urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: true)
        } else {
            appDependencies.keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
            // TODO: is this logic correct? should we show keyboard on link/shortcut opening?
        }
    }

    // MARK: - Handle StatisticsLoader completion logic here
    /// Place any code here that requires install and search statistics to be available before executing.
    private func onStatisticsLoaded() {
        StatisticsLoader.shared.refreshAppRetentionAtb() // TODO: can we move it inside StatisticsLoader.shared.load?
        appDependencies.reportingService.onStatisticsLoaded()
    }

    // MARK: - Handle AppConfiguration fetch completion logic here
    /// Called when crucial configuration files (e.g., TDS, privacy configuration) have been fetched.
    /// Place any code here that depends on up-to-date configuration data before executing.
    private func onConfigurationFetched() {
        appDependencies.reportingService.onConfigurationFetched()
    }

    // MARK: - Handle application(_:open:options:) logic here
    func openURL(_ url: URL) {
        Logger.sync.debug("App launched with url \(url.absoluteString)")
        guard mainCoordinator.shouldProcessDeepLink(url) else { return }

        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

        appDependencies.keyboardService.showKeyboardIfSettingOn = false
        mainCoordinator.handleURL(url)
    }

    // MARK: - Handle application(_:performActionFor:completionHandler:) logic here
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem, appIsLaunching: Bool = false) {
        Logger.general.debug("Handling shortcut item: \(shortcutItem.type)")
        if shortcutItem.type == AppDelegate.ShortcutKey.clipboard, let query = UIPasteboard.general.string {
            mainCoordinator.handleQuery(query)
        } else if shortcutItem.type == AppDelegate.ShortcutKey.passwords {
            mainCoordinator.handleSearchPassword()
        } else if shortcutItem.type == AppDelegate.ShortcutKey.openVPNSettings {
            mainCoordinator.presentNetworkProtectionStatusSettingsModal()
        }
    }

}

extension Foreground {

    struct StateContext {

        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

        init(urlToOpen: URL? = nil, shortcutItemToHandle: UIApplicationShortcutItem? = nil, appDependencies: AppDependencies) {
            self.urlToOpen = urlToOpen
            self.shortcutItemToHandle = shortcutItemToHandle
            self.appDependencies = appDependencies
        }

    }

    func makeStateContext() -> StateContext {
        /// Authentication causes the app to leave the `Foreground` state and move to the `Suspending` state.
        /// This means we must retain `urlToOpen` and `shortcutItemToHandle` to ensure they are available
        /// when the app resumes after authentication. Otherwise, they would be lost during state transitions.
        if appDependencies.authenticationService.isAuthenticated {
            return .init(appDependencies: appDependencies)
        }
        return .init(
            urlToOpen: urlToOpen,
            shortcutItemToHandle: shortcutItemToHandle,
            appDependencies: appDependencies
        )
    }

}

extension Foreground {

    func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            openURL(url)
        case .handleShortcutItem(let shortcutItem):
            handleShortcutItem(shortcutItem)
        }
    }

}
