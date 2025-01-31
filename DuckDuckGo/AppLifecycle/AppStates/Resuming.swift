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
import Combine

/// Represents the transient state where the app is resuming after being backgrounded, preparing to return to the foreground.
/// - Usage:
///   - This state is typically associated with the `applicationWillEnterForeground(_:)` method.
///   - The app transitions to this state when the system sends the `willEnterForeground` event,
///     indicating that the app is about to become active again.
/// - Transitions:
///   - `Foreground`: The app transitions to the `Foreground` state when the app is fully active and visible to the user after resuming.
///   - `Background`: The app can transition to the `Background` state if,
///     e.g. the app is protected by a FaceID lock mechanism (introduced in iOS 18.0) and the user does not authenticate and then leaves.
@MainActor
struct Resuming: AppState {

    private let application: UIApplication
    private var appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?
    private let lastBackgroundDate: Date

    private let didAuthenticateSubject = PassthroughSubject<Void, Never>()
    private let didDataClearSubject = PassthroughSubject<Void, Never>()

    init(stateContext: Background.StateContext) { // TODO: this method needs documentation
        application = stateContext.application
        appDependencies = stateContext.appDependencies
        lastBackgroundDate = stateContext.lastBackgroundDate

        ThemeManager.shared.updateUserInterfaceStyle()

        didAuthenticateSubject.combineLatest(didDataClearSubject)
            .prefix(1) // Trigger only on the first time both have emitted //todo is it needed?
            .sink { [self] _ in self.onReady() }
            .store(in: &appDependencies.cancellables)

        let authenticationService = appDependencies.authenticationService
        let syncService = appDependencies.syncService
        let autoClearService = appDependencies.autoClearService

        authenticationService.beginAuthentication(onAuthenticated: onAuthenticated)
        syncService.onResuming()
        autoClearService.onResuming()
        autoClearService.registerForAutoClear(onDataCleared)
    }

    private func onAuthenticated() { // TODO: this method needs documentation
        didAuthenticateSubject.send()
    }

    private func onDataCleared() { // TODO: this method needs documentation
        didDataClearSubject.send()
    }

    private func onReady() { // TODO: this method needs documentation // TODO: check if this is called, should we store cancellables in appdependencies?
        let keyboardService = appDependencies.keyboardService
        keyboardService.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
        keyboardService.showKeyboardIfSettingOn = true
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
