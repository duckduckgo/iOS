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
import Combine

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

    private let didAuthenticate = PassthroughSubject<Void, Never>()
    private let didSetupWebView = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Handle logic when transitioning from Launched to Foreground
    /// This transition occurs when the app has completed its launch process and becomes active.
    /// Note: You want to add here code that will happen one-time per app lifecycle, but you require the UI to be active at this point!
    init(stateContext: Launching.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle

        observeAppReadiness()

        onInitialForeground()
        onForeground()
    }

    private mutating func observeAppReadiness() {
        Publishers.CombineLatest(didAuthenticate, didSetupWebView)
            .sink { [self] _, _ in
                self.onAppReadyForInteraction()
            }
            .store(in: &cancellables)
    }

    private func onInitialForeground() {
        configureGlobalAppearance()
        appDependencies.subscriptionService.onInitialForeground()
        appDependencies.configurationService.onInitialForeground()
        appDependencies.remoteMessagingService.onInitialForeground()
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

        observeAppReadiness()

        onForeground()
    }

    // MARK: - Handle applicationDidBecomeActive(_:) logic here
    /// Before adding code here, ensure it does not depend on pending tasks:
    /// - If your app needs to be ready for web navigations, see `onReadyToPerformWebNavigations` — this runs after AutoClear is complete.
    /// - If install/search statistics are required, see `onStatisticsLoaded`.
    /// - If crucial configuration files (e.g., TDS, privacy config) are needed, see `onConfigurationFetched`.
    ///
    /// This is **THE LAST POINT** for setting up anything. If you need something to happen earlier,
    /// add it to Launching and Resuming to ensure it runs both on a cold start and when the app wakes up.
    private func onForeground() {
        /// Please note that authentication triggers a transition to the `Suspending` state.
        /// Once authentication is completed, the app reenters the `Foreground` state.
        appDependencies.authenticationService.beginAuthentication(onAuthenticated: onAuthenticated)
        appDependencies.autoClearService.registerForDataCleared(onWebViewReadyForInteraction)

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

    private func onAuthenticated() {
        didAuthenticate.send()
    }

    // MARK: - Handle any WebView related logic here
    /// Callback for the AutoClear feature, triggered when all browser data is cleared.
    /// This includes closing all tabs, clearing caches, and wiping `WKWebsiteDataStore.default()`.
    /// Place any code here related to browser navigation or web view handling
    /// to ensure it remains unaffected by the clearing process.
    private func onWebViewReadyForInteraction() {
        appDependencies.vpnService.onWebViewSetupComplete()
        handleLaunchActions()
        didSetupWebView.send()
    }

    private func onAppReadyForInteraction() {
        if urlToOpen == nil && shortcutItemToHandle == nil {
            appDependencies.keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
        }
    }

    private func handleLaunchActions() {
        if let url = urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle, appIsLaunching: true)
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

    // MARK: - Suspending logic

    // MARK: - Handle application suspension (applicationWillResignActive(_:))
    /// Called when the app is **briefly suspended** due to user actions or system interruptions.
    /// This happens when the app is about to move to the background but has not fully transitioned yet.
    ///
    /// **Scenarios when this happens:**
    /// - The user presses the home button or swipes up to enter the App Switcher.
    /// - The app triggers an authentication prompt, causing a temporary suspension.
    /// - A system alert (e.g., incoming call, notification) appears, momentarily pausing the app.
    func onSuspended() { }

    // MARK: - Handle app reactivation after suspension (applicationDidBecomeActive(_:))
    /// Called when the app **reenters the foreground after being suspended**.
    /// This is the counterpart to `onSuspended()`, triggered when the app **was previously suspended**
    /// and is now becoming active again.
    ///
    /// **Scenarios when this happens:**
    /// - The user successfully authenticates and returns to the app.
    /// - The user switches back to the app from the App Switcher.
    /// - The app was interrupted by a system alert and is now resuming.
    func onReenteredForeground() { }

}

extension Foreground {

    struct StateContext {

        let appDependencies: AppDependencies

        init(appDependencies: AppDependencies) {
            self.appDependencies = appDependencies
        }

    }

    func makeStateContext() -> StateContext {
        .init(appDependencies: appDependencies)
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
