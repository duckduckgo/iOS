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
@MainActor
struct Foreground: AppState {

    let application: UIApplication
    var appDependencies: AppDependencies

    private var urlToOpen: URL?
    private var shortcutItemToHandle: UIApplicationShortcutItem?

    private let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
    private var mainCoordinator: MainCoordinator { appDependencies.mainCoordinator }

    private var lastBackgroundDate: Date?

    // MARK: Handle logic when transitioning from Launched to Foreground
    // This transition occurs when the app has completed its launch process and becomes active.
    // Note: You want to add here code that will happen one-time per app lifecycle, but you require the UI to be active at this point!
    init(stateContext: Launching.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        let subscriptionService = appDependencies.subscriptionService
        subscriptionService.onFirstForeground() // could it be on launching then?

        initialiseBackgroundFetch(application) // could it be on launching then?
        applyAppearanceChanges() // could it be on launching then?
        appDependencies.remoteMessagingService.onForeground() // could it be on launching then?

        let authenticationService = appDependencies.authenticationService
        guard authenticationService.isAuthenticated else {
            authenticationService.beginAuthentication()
            return
        }

        appDependencies.autoClearService.registerForAutoClear(onDataCleared)

        activateApp()
    }

    // MARK: Handle logic when transitioning from Resuming to Foreground
    // This transition occurs when the app returns to the foreground after being backgrounded (e.g., after unlocking the app).
    init(stateContext: Resuming.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle
        lastBackgroundDate = stateContext.lastBackgroundDate

        let authenticationService = appDependencies.authenticationService
        guard authenticationService.isAuthenticated else {
            authenticationService.beginAuthentication()
            return
        }

        appDependencies.autoClearService.registerForAutoClear(onDataCleared)

        activateApp()
    }

    // MARK: Handle logic when transitioning from Suspending to Foreground
    // This transition occurs when the app returns to the foreground after briefly being suspended (e.g., user dismisses a notification).
    init(stateContext: Suspending.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        activateApp()
    }

    // MARK: handle applicationDidBecomeActive(_:) logic here
    private func activateApp(isTesting: Bool = false) {
        appDependencies.syncService.onForeground()

        StatisticsLoader.shared.load {
            StatisticsLoader.shared.refreshAppRetentionAtb()
            self.fireAppLaunchPixel()
            self.reportAdAttribution()
            self.appDependencies.onboardingPixelReporter.fireEnqueuedPixelsIfNeeded()
        }

        mainCoordinator.onForeground()

        appDependencies.configurationService.onConfigurationFetch = onConfigurationFetch
        appDependencies.configurationService.onForeground()

        appDependencies.privacyProDataReporter.injectSyncService(appDependencies.syncService.sync)

        fireFailedCompilationsPixelIfNeeded()

        appDependencies.vpnService.onForeground()
        appDependencies.subscriptionService.onForeground()

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(syncService: appDependencies.syncService.sync)
        importPasswordsStatusHandler.checkSyncSuccessStatus()

        Task {
            await appDependencies.privacyProDataReporter.saveWidgetAdded()
        }

        AppDependencyProvider.shared.persistentPixel.sendQueuedPixels { _ in }
    }

    private func onDataCleared() {
        appDependencies.overlayWindowManager.removeNonAuthenticationOverlay()
        appDependencies.vpnService.onDataCleared()
        if let url = urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: true)
        } else {
            appDependencies.keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
            // is this logic alright? should we show keyboard on link/shortcut opening?
        }
    }

    private func onConfigurationFetch() { // TODO: needs documentation
        sendAppLaunchPostback(marketplaceAdPostbackManager: appDependencies.marketplaceAdPostbackManager)
    }

    // MARK: handle application(_:open:options:) logic here
    func openURL(_ url: URL) {
        Logger.sync.debug("App launched with url \(url.absoluteString)")
        guard mainCoordinator.shouldProcessDeepLink(url) else { return }

        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

        // TODO: to be refactored after introducing autoclearservice, we won't need clearNavigationStack, it should be hidden implementation, we
        // TODO: should just call mainCoordinator.handleURL or processDeeplink
        // The openVPN action handles the navigation stack on its own and does not need it to be cleared
        if url != AppDeepLinkSchemes.openVPN.url {
            mainCoordinator.clearNavigationStack()
        }

        appDependencies.keyboardService.showKeyboardIfSettingOn = false
        mainCoordinator.handleURL(url)
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

    private func fireFailedCompilationsPixelIfNeeded() {
        let store = FailedCompilationsStore()
        if store.hasAnyFailures {
            DailyPixel.fire(pixel: .compilationFailed, withAdditionalParameters: store.summary) { error in
                guard error != nil else { return }
                store.cleanup()
            }
        }
    }

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
