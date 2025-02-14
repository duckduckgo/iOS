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

import UIKit
import Core

/// Represents the state where the app is in the Foreground and is visible to the user.
/// - Usage:
///   - This state is typically associated with the `applicationDidBecomeActive(_:)` method.
///   - The app transitions to this state after completing the launch process or resuming from the background.
///   - During this state, the app is fully interactive, and the user can engage with the app's UI.
@MainActor
struct Foreground: AppState {

    private let appDependencies: AppDependencies
    var services: AppServices { appDependencies.services }

    /// Indicates whether this is the app's first transition to the foreground after launch.
    /// If you need to differentiate between a cold start and a wake-up from the background, use this flag.
    private let isFirstForeground: Bool

    private let launchAction: LaunchAction
    private let launchActionHandler: LaunchActionHandler
    private let interactionManager: UIInteractionManager

    init(stateContext: Launching.StateContext) {
        self.init(
            appDependencies: stateContext.appDependencies,
            urlToOpen: stateContext.urlToOpen,
            shortcutItemToHandle: stateContext.shortcutItemToHandle,
            lastBackgroundDate: nil,
            isFirstForeground: true
        )
    }

    init(stateContext: Background.StateContext) {
        self.init(
            appDependencies: stateContext.appDependencies,
            urlToOpen: stateContext.urlToOpen,
            shortcutItemToHandle: stateContext.shortcutItemToHandle,
            lastBackgroundDate: stateContext.lastBackgroundDate,
            isFirstForeground: stateContext.didTransitionFromLaunching
        )
    }

    private init(appDependencies: AppDependencies,
                 urlToOpen: URL?,
                 shortcutItemToHandle: UIApplicationShortcutItem?,
                 lastBackgroundDate: Date?,
                 isFirstForeground: Bool) {
        self.appDependencies = appDependencies
        self.isFirstForeground = isFirstForeground
        launchAction = LaunchAction(urlToOpen: urlToOpen,
                                    shortcutItemToHandle: shortcutItemToHandle,
                                    lastBackgroundDate: lastBackgroundDate)
        launchActionHandler = LaunchActionHandler(
            urlHandler: appDependencies.mainCoordinator,
            shortcutItemHandler: appDependencies.mainCoordinator,
            keyboardPresenter: KeyboardPresenter(mainViewController: appDependencies.mainCoordinator.controller)
        )
        interactionManager = UIInteractionManager(
            authenticationService: appDependencies.services.authenticationService,
            autoClearService: appDependencies.services.autoClearService,
            launchActionHandler: launchActionHandler
        )
    }

    // MARK: - Handle applicationDidBecomeActive(_:) logic here

    /// **Before adding code here, ensure it does not depend on pending tasks:**
    /// - If your code relies on web navigations, use `onWebViewReadyForInteractions` callback — it runs after `AutoClear` is complete.
    /// - If your code relies on UI interactions, use `onAppReadyForInteractions` callback - it runs after `AutoClear` and authentication.
    ///
    /// This is **the last moment** for setting up anything. If you need something to happen earlier,
    /// add it to `Launching.swift` -> `init()` and `Background.swift` -> `willLeave()` so it runs both on a cold start and when the app wakes up.
    ///
    /// **Important note**
    /// If your service needs to perform async work, handle it **within the service** instead of spawning `Task {}` blocks here.
    /// This ensures that each service manages its own async execution without unnecessary indirection.
    func onTransition() {
        configureAppearance()

        let vpnService = services.vpnService
        vpnService.resume()

        interactionManager.start(
            launchAction: launchAction,
            /// Handle **WebView related logic** here that could be affected by `AutoClear` feature.
            /// This is called when the **app is ready to handle web navigations** after all browser data has been cleared.
            onWebViewReadyForInteractions: {
                vpnService.installRedditSessionWorkaround()
            },
            /// Handle **UI related logic** here that could be affected by Authentication screen or `AutoClear` feature
            /// This is called when the **app is ready to handle user interactions** after data clear and authentication are complete.
            onAppReadyForInteractions: {
                /* ... */
            }
        )

        services.configurationService.resume()
        services.reportingService.resume()
        services.subscriptionService.resume()
        services.autofillService.resume()
        services.maliciousSiteProtectionService.resume()
        services.syncService.resume()
        services.remoteMessagingService.resume()
        services.statisticsService.resume()

        appDependencies.mainCoordinator.onForeground()
    }

    private func configureAppearance() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

}

// MARK: Handle application suspension (applicationWillResignActive(_:))

/// No active use case currently, but could apply to scenarios like pausing/resuming a game or video during a system alert.
extension Foreground {

    /// Called when the app is **briefly** paused due to user actions or system interruptions
    /// or when the app is about to move to the background but has not fully transitioned yet.
    ///
    /// **Scenarios when this happens:**
    /// - The user switches to another app or just swipes up to open the App Switcher.
    /// - The app prompts for system authentication (>iOS 18.0), causing a temporary suspension.
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

// MARK: - AppEventHandler

extension Foreground {

    func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            launchActionHandler.handleLaunchAction(.openURL(url))
        case .handleShortcutItem(let shortcutItem):
            launchActionHandler.handleLaunchAction(.handleShortcutItem(shortcutItem))
        }
    }

}

// MARK: - StateContext

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
