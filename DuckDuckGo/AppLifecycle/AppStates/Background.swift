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

/// Represents the state where the app is in the background and not visible to the user.
/// - Usage:
///   - This state is typically associated with the `applicationDidEnterBackground(_:)` method.
///   - The app transitions to this state when it is no longer in the foreground, either due to the user
///     minimizing the app, switching to another app, or locking the device.
@MainActor
struct Background: AppState {

    private let lastBackgroundDate: Date = Date()
    private let appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    init(stateContext: Launching.StateContext) {
        self.init(appDependencies: stateContext.appDependencies)
    }

    init(stateContext: Foreground.StateContext) {
        self.init(appDependencies: stateContext.appDependencies)
    }

    private init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies

        onSnooze()
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

// MARK: - Handle application resumption (applicationWillEnterForeground(_:)) logic here
extension Background {

    /// Called when the app is attempting to enter the foreground from the background.
    /// If the app uses the system Face ID lock feature and the user does not authenticate, it will return to the background, triggering `onSnooze()`.
    /// Use `onSnooze()` to revert any actions performed in `onWakeUp()`, e.g. suspend services that were resumed (if applicable).
    ///
    /// **Important note**
    /// By default, resume any services in the `onForeground()` method of the `Foreground` state.
    /// Use this method to resume **UI related tasks** that need to be completed promptly, preventing UI glitches when the user first sees the app.
    /// This ensures that your app remains responsive and smooth as it enters the foreground.
    func onWakeUp() {
        ThemeManager.shared.updateUserInterfaceStyle()
        appDependencies.autoClearService.onResuming()
    }

    /// Called when the app transitions from launching or foreground to background,
    /// or when the app fails to wake up from the background (due to system Face ID lock).
    /// This is the counterpart to `onWakeUp()`.
    ///
    /// Use this method to revert any actions performed in `onWakeUp` (if applicable).
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
