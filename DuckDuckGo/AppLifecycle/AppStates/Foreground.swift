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

/// Represents the state where the app is in the Foreground.
/// - Usage:
///   - This state is typically associated with the `applicationDidBecomeActive(_:)` method.
///   - The app transitions to this state after completing the launch process or resuming from the background.
///   - During this state, the app is fully interactive, and the user can engage with the app's UI.
/// - Transitions:
///   - `Background`: The app transitions to this state when it begins the process of moving to the background,
///     triggered by the `applicationDidEnterBackground(_:)` method
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

        onForeground()
    }

    init(stateContext: Background.StateContext) {
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen
        shortcutItemToHandle = stateContext.shortcutItemToHandle
        lastBackgroundDate = stateContext.lastBackgroundDate

        observeAppReadiness()

        onResume() // We need to call this to ensure that all services suspended in onPause() are now properly resumed.
        onForeground()
    }

    private mutating func observeAppReadiness() {
        Publishers.CombineLatest(didAuthenticate, didSetupWebView)
            .sink { [self] _, _ in
                self.onAppReadyForInteractions()
            }
            .store(in: &cancellables)
    }

    private func configureGlobalAppearance() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    // MARK: - Handle applicationDidBecomeActive(_:) logic here
    /// Before adding code here, ensure it does not depend on pending tasks:
    /// - If the app requires authentication (e.g., to prevent the keyboard from covering the Authentication screen), see `onAuthenticated`.
    /// - If the app needs to be ready for web navigations, see `onWebViewReadyForInteractions` — this runs after AutoClear is complete.
    /// - If the app needs to be ready for any interactions, see `onAppReadyForInteractions` - this runs after AutoClear and after Authentication
    /// - If install/search statistics are required, see `onStatisticsLoaded`.
    /// - If crucial configuration files (e.g., TDS, privacy config) are needed, see `onConfigurationFetched`.
    ///
    /// This is **THE LAST POINT** for setting up anything. If you need something to happen earlier,
    /// add it to Launching's `init()` and Background's `onWakeUp()` to ensure it runs both on a cold start and when the app wakes up.
    private func onForeground() {
        configureGlobalAppearance()

        appDependencies.authenticationService.beginAuthentication(onAuthenticated: onAuthenticated)
        appDependencies.autoClearService.registerForDataCleared(onWebViewReadyForInteractions)

        appDependencies.syncService.onForeground()

        appDependencies.configurationService.onConfigurationFetched = onConfigurationFetched
        appDependencies.configurationService.onForeground()

        appDependencies.remoteMessagingService.onForeground()
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
    /// Place any code here related to browser navigation or web view handling to ensure it remains unaffected by the clearing process.
    private func onWebViewReadyForInteractions() {
        appDependencies.vpnService.onWebViewReadyForInteractions()
        handleLaunchActions()
        didSetupWebView.send()
    }

    // MARK: - Handle UI-related logic that could be affected by Authentication screen or AutoClear feature
    /// This is called when the app is ready to handle user interactions after data clear and authentication are complete.
    private func onAppReadyForInteractions() {
        if urlToOpen == nil && shortcutItemToHandle == nil {
            appDependencies.keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
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
    func openURL(_ url: URL) {
        Logger.sync.debug("App launched with url \(url.absoluteString)")
        guard mainCoordinator.shouldProcessDeepLink(url) else { return }

        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)

        appDependencies.keyboardService.showKeyboardIfSettingOn = false
        mainCoordinator.handleURL(url)
    }

    // MARK: Handle application(_:performActionFor:completionHandler:) logic here
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
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

// MARK: - Pausing and resuming logic
/// Currently, there’s no active use case, but in the future, this could apply to scenarios like pausing/resuming a game or video,
/// where we wouldn’t want playback to continue during a system alert.
extension Foreground {

    // MARK: Handle application suspension (applicationWillResignActive(_:))
    /// Called when the app is briefly paused due to user actions or system interruptions.
    /// This occurs when the app is about to move to the background but has not fully transitioned yet.
    ///
    /// **Scenarios when this happens:**
    /// - The user presses the home button or swipes up to just open the App Switcher.
    /// - The app prompts for authentication, causing a temporary suspension.
    /// - A system alert (e.g., an incoming call or notification) momentarily interrupts the app.
    func onPause() { }

    // MARK: Handle app activation (applicationDidBecomeActive(_:))
    /// Called when the app resumes activity after being **paused** or transitioning from launch or the background.
    /// This is the counterpart to `onPause()`.
    ///
    /// **Scenarios when this happens:**
    /// - The app completes its launch process and becomes active.
    /// - The user returns to the app after authentication.
    /// - The user switches back to the app from the App Switcher.
    /// - The app was temporarily interrupted (e.g., by a system alert) and is now resuming.
    func onResume() { }

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
