//
//  Suspending.swift
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

/// Represents the transient state where the app is in the process of moving out of the foreground.
/// - Usage:
///   - This state is typically associated with the `applicationWillResignActive(_:)` method.
///   - The app transitions to this state when it is temporarily interrupted or begins moving to the background.
///   - Common triggers include:
///     - The user receives a system notification.
///     - The user accesses the App Switcher.
///     - The user starts swiping up to exit the app but does not complete the gesture.
/// - Transitions:
///   - `Foreground`: The app transitions back to `Foreground` if the user dismisses the system notification or
///     returns from the App Switcher to the app without fully transitioning to the background.
///   - `Background`: The app transitions to `Background` if the user completes the gesture to move the app out
///     of the foreground or another action causes the app to enter the background.
/// - Notes:
///   - This is a short-lived state and is part of the app's standard lifecycle.
///   - It allows the app to prepare for a potential transition to `Background`, such as pausing animations
///     or saving transient state information.
struct Suspending: AppState {

    private let application: UIApplication
    private let appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    init(stateContext: Foreground.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        let vpnFeatureVisibility = appDependencies.vpnFeatureVisibility
        let accountManager = appDependencies.accountManager
        let vpnWorkaround = appDependencies.vpnWorkaround
        Task { @MainActor [application] in
            await application.refreshVPNShortcuts(vpnFeatureVisibility: vpnFeatureVisibility,
                                                  accountManager: accountManager)
            await vpnWorkaround.removeRedditSessionWorkaround()
        }
    }

}

extension Suspending {

    struct StateContext {

        let application: UIApplication
        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(application: application,
              urlToOpen: urlToOpen,
              shortcutItemToHandle: shortcutItemToHandle,
              appDependencies: appDependencies)
    }

}

extension Suspending {

    mutating func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            urlToOpen = url
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
        }
    }

}
