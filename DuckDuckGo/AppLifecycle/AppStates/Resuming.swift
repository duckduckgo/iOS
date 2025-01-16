//
//  Resuming.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

/// Represents the transient state where the app is resuming after being backgrounded, preparing to return to the foreground.
/// - Usage:
///   - This state is typically associated with the `applicationWillEnterForeground(_:)` method.
///   - The app transitions to this state when the system sends the `willEnterForeground` event,
///     indicating that the app is about to become active again.
/// - Transitions:
///   - `Foreground`: The app transitions to the `Foreground` state when the app is fully active and visible to the user after resuming.
///   - `Background`: The app can transition to the `Background` state if,
///     e.g. the app is protected by a FaceID lock mechanism (introduced in iOS 18.0) and the user does not authenticate and then leaves.
struct Resuming: AppState {

    private let application: UIApplication
    private let appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    init(stateContext: Background.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        ThemeManager.shared.updateUserInterfaceStyle()

        let uiService = appDependencies.uiService
        let syncService = appDependencies.syncService
        let autoClear = appDependencies.autoClear
        Task { @MainActor [self] in
            await beginAuthentication(lastBackgroundDate: stateContext.lastBackgroundDate)
            await autoClear.clearDataIfEnabledAndTimeExpired(applicationState: .active)
            uiService.showKeyboardIfSettingOn = true
            syncService.scheduler.resumeSyncQueue()
        }

    }

    // duplicated from Foreground just for now

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

    private var mainViewController: MainViewController {
        appDependencies.mainViewController
    }

}

extension Resuming {

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

extension Resuming {

    mutating func handle(action: AppAction) {
        switch action {
        case .openURL(let url):
            urlToOpen = url
        case .handleShortcutItem(let shortcutItem):
            shortcutItemToHandle = shortcutItem
        }
    }

}
