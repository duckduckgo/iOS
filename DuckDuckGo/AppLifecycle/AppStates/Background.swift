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

struct Background: AppState {

    private let lastBackgroundDate: Date = Date()
    private let application: UIApplication
    private var appDependencies: AppDependencies

    var urlToOpen: URL?
    var shortcutItemToHandle: UIApplicationShortcutItem?

    init(stateContext: Suspending.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen

        run()
    }

    init(stateContext: Launching.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies
        urlToOpen = stateContext.urlToOpen

        run()
    }

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
