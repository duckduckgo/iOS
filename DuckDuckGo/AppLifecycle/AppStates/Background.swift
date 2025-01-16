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

import Foundation
import Combine
import DDGSync
import UIKit
import Core

/// Represents the state where the app is fully in the background and not visible to the user.
/// - Usage:
///   - This state is typically associated with the `applicationDidEnterBackground(_:)` method.
///   - The app transitions to this state when it is no longer in the foreground, either due to the user
///     minimizing the app, switching to another app, or locking the device.
/// - Transitions:
///   - `Resuming`: The app transitions to the `Resuming` state when the user brings the app back to the foreground.
/// - Notes:
///   - This is one of the app's two long-lived states, alongside `Foreground`.
///   - Background tasks, such as saving data or refreshing content, should be handled in this state.
///   - Use this state to ensure that the app's current state is saved and any necessary cleanup is performed
///     to release resources or prepare for a potential termination.
struct Background: AppState {

    private let lastBackgroundDate: Date = Date()
    private let application: UIApplication
    private var appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    // MARK: Handle logic when transitioning from Launching to Background
    // This transition can occur if the app is protected by FaceID (e.g., the app is launched, but the user doesn't authenticate).
    // Note: In this case, the Foreground state was never shown to the user, so you may want to avoid ending sessions that were never started, etc.
    init(stateContext: Launching.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen

        run()
    }

    // MARK: Handle logic when transitioning from Suspending to Background
    // This transition occurs when the app moves from foreground to the background.
    init(stateContext: Suspending.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen

        run()
    }

    // MARK: Handle logic when transitioning from Resuming to Background
    // This transition can occur when the app returns to the background after being in the background (e.g., user doesn't authenticate on a locked app).
    init(stateContext: Resuming.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen

        run()
    }

    mutating func run() {
        let autoClear = appDependencies.autoClear
        let privacyStore = appDependencies.privacyStore
        let privacyProDataReporter = appDependencies.privacyProDataReporter
        let voiceSearchHelper = appDependencies.voiceSearchHelper
        let appSettings = appDependencies.appSettings
        let autofillLoginSession = appDependencies.autofillLoginSession
        let syncService = appDependencies.syncService
        let syncDataProviders = appDependencies.syncDataProviders
        let uiService = appDependencies.uiService

        if autoClear.isClearingEnabled || privacyStore.authenticationEnabled {
            uiService.displayBlankSnapshotWindow(voiceSearchHelper: voiceSearchHelper,
                                                 addressBarPosition: appSettings.currentAddressBarPosition)
        }
        autoClear.startClearingTimer()
        autofillLoginSession.endSession()

        suspendSync(syncService: syncService)
        syncDataProviders.bookmarksAdapter.cancelFaviconsFetching(application)
        privacyProDataReporter.saveApplicationLastSessionEnded()

        resetAppStartTime()
    }

    private mutating func suspendSync(syncService: DDGSync) {
        if syncService.isSyncInProgress {
            Logger.sync.debug("Sync is in progress. Starting background task to allow it to gracefully complete.")

            var taskID: UIBackgroundTaskIdentifier!
            taskID = UIApplication.shared.beginBackgroundTask(withName: "Cancelled Sync Completion Task") {
                Logger.sync.debug("Forcing background task completion")
                UIApplication.shared.endBackgroundTask(taskID)
            }
            appDependencies.syncDidFinishCancellable?.cancel()
            appDependencies.syncDidFinishCancellable = syncService.isSyncInProgressPublisher.filter { !$0 }
                .prefix(1)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    Logger.sync.debug("Ending background task")
                    UIApplication.shared.endBackgroundTask(taskID)
                }
        }

        syncService.scheduler.cancelSyncAndSuspendSyncQueue()
    }

    private func resetAppStartTime() {
        appDependencies.mainViewController.appDidFinishLaunchingStartTime = nil
    }

}

extension Background {

    struct StateContext {

        let application: UIApplication
        let lastBackgroundDate: Date
        let urlToOpen: URL?
        let shortcutItemToHandle: UIApplicationShortcutItem?

        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(application: application,
              lastBackgroundDate: lastBackgroundDate,
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
