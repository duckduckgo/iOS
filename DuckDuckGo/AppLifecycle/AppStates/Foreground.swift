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
import BrowserServicesKit
import Core
import WidgetKit
import BackgroundTasks
import NetworkProtection

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
struct Foreground: AppState {

    let application: UIApplication
    let appDependencies: AppDependencies

    private let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager

    private var window: UIWindow {
        appDependencies.uiService.window // should it be application.window?
    }

    private var mainViewController: MainViewController {
        appDependencies.mainViewController
    }

    // MARK: Handle logic when transitioning from Launched to Foreground
    // This transition occurs when the app has completed its launch process and becomes active.
    // Note: You want to add here code that will happen one-time per app lifecycle, but you require the UI to be active at this point!
    init(stateContext: Launching.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        let subscriptionService = appDependencies.subscriptionService
        subscriptionService.onFirstForeground()

        // onApplicationLaunch code
        Task { @MainActor [self] in
            await beginAuthentication()
            // TODO: onAuthentication()?
            initialiseBackgroundFetch(application)
            applyAppearanceChanges()
            appDependencies.remoteMessagingService.onForeground() // TODO: perhaps it should be onAuthentication (if it actually depends on it)
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
        appDependencies.syncService.setUpDatabaseCleanersIfNeeded()

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

        appDependencies.syncService.notifyAppLifecycleEvent()
        appDependencies.privacyProDataReporter.injectSyncService(appDependencies.syncService.sync)

        fireFailedCompilationsPixelIfNeeded()

        appDependencies.vpnService.onForeground(mainViewController: mainViewController)

        let subscriptionService = appDependencies.subscriptionService
        subscriptionService.onForeground()

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(syncService: appDependencies.syncService.sync)
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

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem, appIsLaunching: Bool = false) {
        Logger.general.debug("Handling shortcut item: \(shortcutItem.type)")
        let autoClear = appDependencies.autoClear
        Task { @MainActor in

            // This if/else could potentially be removed by ensuring previous autoClear calls (triggered during both Launch and Active states) are completed before proceeding. To be looked at in next milestones
            if appIsLaunching {
                await autoClear.clearDataIfEnabled()
            } else {
                await autoClear.clearDataIfEnabledAndTimeExpired(applicationState: .active)
            }

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

extension Foreground {

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
