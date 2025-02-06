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

        appDependencies.configurationService.onConfigurationFetched = onConfigurationFetched
        appDependencies.configurationService.onForeground()

        appDependencies.vpnService.onForeground()
        appDependencies.subscriptionService.onForeground()
        appDependencies.autofillService.onForeground()
        appDependencies.reportingService.onForeground()
        appDependencies.maliciousSiteProtectionService.onForeground()

        StatisticsLoader.shared.load(completion: onStatisticsLoaded)
        mainCoordinator.onForeground()
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
