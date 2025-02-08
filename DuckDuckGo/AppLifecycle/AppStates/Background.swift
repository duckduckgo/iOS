//
//  Background.swift
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

/// Represents the state where the app is fully in the background and not visible to the user.
/// - Usage:
///   - This state is typically associated with the `applicationDidEnterBackground(_:)` method.
///   - The app transitions to this state when it is no longer in the foreground, either due to the user
///     minimizing the app, switching to another app, or locking the device.
/// - Transitions:
///   - `Foreground`: The app transitions to the `Foreground` state when the user brings the app back to the foreground.
/// - Notes:
///   - Background tasks, such as saving data or refreshing content, should be handled in this state.
///   - Use this state to ensure that the app's current state is saved and any necessary cleanup is performed
///     to release resources or prepare for a potential termination.
@MainActor
struct Background: AppState {

    private let lastBackgroundDate: Date = Date()
    private let appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    // MARK: - Handle logic when transitioning from Launching to Background
    /// This transition can occur if the app is protected by FaceID (e.g., the app is launched, but the user doesn't authenticate).
    init(stateContext: Launching.StateContext) {
        appDependencies = stateContext.appDependencies

        onBackground()
    }

    // MARK: - Handle logic when transitioning from Foreground to Background
    init(stateContext: Foreground.StateContext) {
        appDependencies = stateContext.appDependencies

        onSnooze() // We need to call this to ensure that all services resumed in onWakeUp() are now properly suspended.
        onBackground()
    }

    // MARK: - Handle applicationDidEnterBackground(_:) logic here
    private func onBackground() {
        appDependencies.vpnService.onBackground()
        appDependencies.authenticationService.onBackground()
        appDependencies.autoClearService.onBackground()
        appDependencies.autofillService.onBackground()
        appDependencies.syncService.onBackground()
        appDependencies.reportingService.onBackground()

        appDependencies.mainCoordinator.resetAppStartTime()
    }

}

// MARK: Wake up and snooze logic
extension Background {

    // MARK: - Handle applicationWillEnterForeground(_:) logic here
    /// Called when the app is about to enter the foreground from the background.
    /// This occurs when the app is transitioning back to an active state, but has not fully entered the foreground yet.
    ///
    /// **Scenarios when this is called:**
    /// - The user returns to the app from another app or the home screen.
    ///
    /// **Important note:**
    /// By default, if you want to resume any service, it should be handled inside the `onForeground` method in the `Foreground` state.
    /// Use `onWakeUp` for resuming **UI-related tasks** that need to happen sooner to avoid glitches when the user sees the app.
    /// This ensures that your app remains responsive and smooth as it enters the foreground.
    func onWakeUp() {
        ThemeManager.shared.updateUserInterfaceStyle()
        appDependencies.autoClearService.onResuming()
    }

    // MARK: - Handle applicationDidEnterBackground(_:) logic here
    /// Called when app transitions from `Foreground` or when the app attempts to wake up but fails and re-enters the `Background`.
    ///
    /// **Scenarios when this is called:**
    /// - Each time app goes to Background
    /// - But also, when the app is protected by a FaceID lock (introduced in iOS 18.0) and the user fails to authenticate, then exits the app.
    ///
    /// Use this method to revert any actions performed in `onWakeUp` (only if needed).
    func onSnooze() { }

}

extension Background {

    struct StateContext {

        let lastBackgroundDate: Date
        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(lastBackgroundDate: lastBackgroundDate,
              urlToOpen: urlToOpen,
              shortcutItemToHandle: shortcutItemToHandle,
              appDependencies: appDependencies)
    }

}

extension Background {

    mutating func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            urlToOpen = url
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
        }
    }

}
