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

/// Represents the state where the app is in the Foreground and is visible to the user.
/// - Usage:
///   - This state is typically associated with the `applicationDidBecomeActive(_:)` method.
///   - The app transitions to this state after completing the launch process or resuming from the background.
///   - During this state, the app is fully interactive, and the user can engage with the app's UI.
@MainActor
struct Foreground: AppState {

    let appDependencies: AppDependencies
    private var mainCoordinator: MainCoordinator { appDependencies.mainCoordinator }

    private let urlToOpen: URL?
    private let shortcutItemToHandle: UIApplicationShortcutItem?
    private var lastBackgroundDate: Date?

    /// Indicates whether this is the app's first transition to the foreground after launch.
    /// If you need to differentiate between a cold start and a wake-up from the background, use this flag.
    private let isFirstForeground: Bool

    init(stateContext: Launching.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle
        isFirstForeground = true
    }

    init(stateContext: Background.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle
        lastBackgroundDate = stateContext.lastBackgroundDate
        isFirstForeground = stateContext.didTransitionFromLaunching
    }

    // MARK: - Handle applicationDidBecomeActive(_:) logic here
    /// **Before adding code here, ensure it does not depend on pending tasks:**
    /// - If the app needs to be ready for web navigations, use `onWebViewReadyForInteractions()` — this runs after `AutoClear` is complete.
    /// - If the app needs to be ready for any interactions, use `onAppReadyForInteractions()` - this runs after `AutoClear` and authentication.
    /// - If install/search statistics are required, use `onStatisticsLoaded()`.
    /// - If crucial configuration files (e.g., TDS, privacy config) are needed, use `onConfigurationFetched()`.
    ///
    /// This is **the last moment** for setting up anything. If you need something to happen earlier,
    /// add it to `Launching.swift` -> `init()` and `Background.swift` -> `willLeave()` so it runs both on a cold start and when the app wakes up.
    func onTransition() {
        configureAppearance()

        orchestrateForegroundAsyncTasks()

        appDependencies.syncService.onForeground()
        appDependencies.remoteMessagingService.onForeground()
        appDependencies.vpnService.onForeground()
        appDependencies.subscriptionService.onForeground()
        appDependencies.autofillService.onForeground()
        appDependencies.reportingService.onForeground()
        appDependencies.maliciousSiteProtectionService.onForeground()

        StatisticsLoader.shared.load(completion: onStatisticsLoaded)
        mainCoordinator.onForeground()
    }

    private func configureAppearance() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    // MARK: - Handle any WebView related logic here
    /// Callback for the `AutoClear` feature, triggered when all browser data is cleared.
    /// This includes closing all tabs, clearing caches, and wiping `WKWebsiteDataStore.default()`.
    /// Place any code here related to browser navigation or web view handling to ensure it remains unaffected by the clearing process.
    private func onWebViewReadyForInteractions() {
        appDependencies.vpnService.onWebViewReadyForInteractions()
        handleLaunchActions()
    }

    // MARK: - Handle UI-related logic here that could be affected by Authentication screen or AutoClear feature
    /// This is called when the app is ready to handle user interactions after data clear and authentication are complete.
    private func onAppReadyForInteractions() {
        if urlToOpen == nil && shortcutItemToHandle == nil {
            appDependencies.keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
        }
    }

    // MARK: - Handle StatisticsLoader completion logic here
    /// Place any code here that requires install and search statistics to be available before executing.
    private func onStatisticsLoaded() {
        appDependencies.reportingService.onStatisticsLoaded()
    }

    // MARK: - Handle AppConfiguration fetch completion logic here
    /// Called when crucial configuration files (e.g., TDS, privacy configuration) have been fetched.
    /// Place any code here that depends on up-to-date configuration data before executing.
    private func onConfigurationFetched() {
        appDependencies.reportingService.onConfigurationFetched()
    }

}

// MARK: - Synchronization Layer
/// This handles foreground-related async tasks that require coordination between services.
/// It is **not** part of the public API of `Foreground`
///
/// **Important note**
/// - Only use this for work that requires callbacks for other services.
/// - If your service needs to perform async work, handle it **within the service itself** instead of spawning `Task` blocks here.
/// - This ensures that each service manages its own async execution without unnecessary indirection.
extension Foreground {

    private func orchestrateForegroundAsyncTasks() {
        Task { @MainActor in
            async let authentication: () = authenticate()
            async let dataClearing: () = clearData()

            await (_, _) = (authentication, dataClearing)
            onAppReadyForInteractions()
        }
        Task { @MainActor in
            await appDependencies.configurationService.resume()
            onConfigurationFetched()
        }
    }

    private func authenticate() async {
        await appDependencies.authenticationService.resume()
    }

    private func clearData() async {
        await appDependencies.autoClearService.waitForDataCleared()
        onWebViewReadyForInteractions()
    }

}

// MARK: - URL and shortcut items handling
extension Foreground {

    func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            openURL(url)
        case .handleShortcutItem(let shortcutItem):
            handleShortcutItem(shortcutItem)
        }
    }

    private func handleLaunchActions() {
        if let url = urlToOpen {
            openURL(url)
        } else if let shortcutItemToHandle = shortcutItemToHandle {
            handleShortcutItem(shortcutItemToHandle)
        }
    }

    // MARK: Handle application(_:open:options:) logic here
    private func openURL(_ url: URL) {
        Logger.sync.debug("App launched with url \(url.absoluteString)")
        guard mainCoordinator.shouldProcessDeepLink(url) else { return }

        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

        mainCoordinator.handleURL(url)
    }

    // MARK: Handle application(_:performActionFor:completionHandler:) logic here
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        Logger.general.debug("Handling shortcut item: \(shortcutItem.type)")
        if shortcutItem.type == ShortcutKey.clipboard, let query = UIPasteboard.general.string {
            mainCoordinator.handleQuery(query)
        } else if shortcutItem.type == ShortcutKey.passwords {
            mainCoordinator.handleSearchPassword()
        } else if shortcutItem.type == ShortcutKey.openVPNSettings {
            mainCoordinator.presentNetworkProtectionStatusSettingsModal()
        }
    }

}

// MARK: Handle application suspension (applicationWillResignActive(_:))
/// No active use case currently, but could apply to scenarios like pausing/resuming a game or video during a system alert.
extension Foreground {

    /// Called when the app is **briefly** paused due to user actions or system interruptions.
    /// or when the app is about to move to the background but has not fully transitioned yet.
    ///
    /// **Scenarios when this happens:**
    /// - The user switches to another app or just swipes up to open the App Switcher.
    /// - The app prompts for authentication, causing a temporary suspension.
    /// - A system alert (e.g., an incoming call or notification) momentarily interrupts the app.
    ///
    /// **Important note**
    /// By default, suspend any services in the `onTransition()` method of the `Background` state.
    /// Use this method only to pause specific tasks, like video playback, when the app displays a system alert.
    func willLeave() { }

    /// Called when the app resumes activity after being **paused** or when transitioning from launching or background.
    /// This is the counterpart to `willLeave()`.
    ///
    /// Use this method to revert any actions performed in `willLeave()` (if applicable).
    func didReturn() { }

}

// MARK: - State context
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
