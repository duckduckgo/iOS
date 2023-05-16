//
//  SyncBackgroundScheduler.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import DDGSync
import Foundation
import BackgroundTasks
import Core
import Persistence

final class SyncBackgroundScheduler {

    struct Constants {
        static let backgroundTaskName = "Sync Background Task"
        static let backgroundProcessingTaskIdentifier = "com.duckduckgo.app.sync"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 6
    }

    static func registerBackgroundRefreshTaskHandler(bookmarksDatabase: CoreDataDatabase, syncMetadataDatabase: CoreDataDatabase) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundProcessingTaskIdentifier, using: nil) { (task) in

            let syncMetadata = LocalSyncMetadataStore(database: syncMetadataDatabase)
            let syncBookmarksAdapter = SyncBookmarksAdapter(database: bookmarksDatabase, metadataStore: syncMetadata)
            let syncService = DDGSync(dataProviders: [syncBookmarksAdapter.provider], log: .syncLog)

            guard syncService.authState == .active else {
                task.setTaskCompleted(success: true)
                scheduleBackgroundRefreshTask()
                return
            }

            syncService.scheduler.requestSyncImmediately()
            let syncDidFinishCancellable = syncService.isInProgressPublisher
                .dropFirst()
                .filter { $0 }
                .prefix(1)
                .sink { _ in
                    task.setTaskCompleted(success: true)
                }

            task.expirationHandler = {
                syncDidFinishCancellable.cancel()
            }
        }
    }

    static func scheduleBackgroundRefreshTask() {
        let task = BGProcessingTaskRequest(identifier: Constants.backgroundProcessingTaskIdentifier)
        task.requiresNetworkConnectivity = true
        task.earliestBeginDate = Date(timeIntervalSinceNow: Constants.minimumConfigurationRefreshInterval)

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.sync"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.sync"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
        } catch {
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
        #endif
    }
}
