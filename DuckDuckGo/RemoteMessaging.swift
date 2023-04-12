//
//  RemoteMessaging.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Core
import BackgroundTasks
import BrowserServicesKit
import os.log
import Persistence
import Bookmarks

struct RemoteMessaging {

    struct Notifications {
        static let remoteMessagesDidChange = Notification.Name("com.duckduckgo.app.RemoteMessagesDidChange")
    }

    @UserDefaultsWrapper(key: .lastRemoteMessagingRefreshDate, defaultValue: .distantPast)
    static private var lastRemoteMessagingRefreshDate: Date

    struct Constants {
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.remoteMessageRefresh"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 4
    }

    static private var shouldRefresh: Bool {
        return Date().timeIntervalSince(Self.lastRemoteMessagingRefreshDate) > Constants.minimumConfigurationRefreshInterval
    }

    static func registerBackgroundRefreshTaskHandler(bookmarksDatabase: CoreDataDatabase) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            guard shouldRefresh else {
                task.setTaskCompleted(success: true)
                scheduleBackgroundRefreshTask()
                return
            }
            backgroundRefreshTaskHandler(bgTask: task, bookmarksDatabase: bookmarksDatabase)
        }
    }

    static func scheduleBackgroundRefreshTask() {
        let task = BGProcessingTaskRequest(identifier: Constants.backgroundRefreshTaskIdentifier)
        task.earliestBeginDate = Date(timeIntervalSinceNow: Constants.minimumConfigurationRefreshInterval)
        task.requiresNetworkConnectivity = true

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.remoteMessageRefresh"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.remoteMessageRefresh"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
        } catch {
            os_log("Failed to schedule background task: %@", log: OSLog.remoteMessaging, type: .error, error.localizedDescription)
        }
        #endif
    }

    static func backgroundRefreshTaskHandler(bgTask: BGTask, bookmarksDatabase: CoreDataDatabase) {
        let fetchAndProcessTask = Task {
            do {
                try await Self.fetchAndProcess(bookmarksDatabase: bookmarksDatabase)
                Self.lastRemoteMessagingRefreshDate = Date()
                scheduleBackgroundRefreshTask()
                bgTask.setTaskCompleted(success: true)
            } catch {
                scheduleBackgroundRefreshTask()
                bgTask.setTaskCompleted(success: false)
            }
        }

        bgTask.expirationHandler = {
            fetchAndProcessTask.cancel()
            bgTask.setTaskCompleted(success: false)
        }
    }

    /// Convenience function
    static func fetchAndProcess(bookmarksDatabase: CoreDataDatabase) async throws {
        
        var bookmarksCount = 0
        var favoritesCount = 0
        let context = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
        context.performAndWait {
            let bookmarksCountRequest = BookmarkEntity.fetchRequest()
            bookmarksCountRequest.predicate = NSPredicate(format: "%K == false AND %K == false",
                                                 #keyPath(BookmarkEntity.isFavorite),
                                                 #keyPath(BookmarkEntity.isFolder))
            bookmarksCount = (try? context.count(for: bookmarksCountRequest)) ?? 0
            
            let favoritesCountRequest = BookmarkEntity.fetchRequest()
            bookmarksCountRequest.predicate = NSPredicate(format: "%K == true AND %K == false",
                                                 #keyPath(BookmarkEntity.isFavorite),
                                                 #keyPath(BookmarkEntity.isFolder))
            favoritesCount = (try? context.count(for: favoritesCountRequest)) ?? 0
        }
        
        let isWidgetInstalled = await AppDependencyProvider.shared.appSettings.isWidgetInstalled()

        try await Self.fetchAndProcess(bookmarksCount: bookmarksCount,
                                       favoritesCount: favoritesCount,
                                       isWidgetInstalled: isWidgetInstalled)
    }

    static private func fetchAndProcess(bookmarksCount: Int,
                                        favoritesCount: Int,
                                        remoteMessagingStore: RemoteMessagingStore = AppDependencyProvider.shared.remoteMessagingStore,
                                        statisticsStore: StatisticsStore = StatisticsUserDefaults(),
                                        variantManager: VariantManager = DefaultVariantManager(),
                                        isWidgetInstalled: Bool) async throws {

        let result = await Self.fetchRemoteMessages(remoteMessageRequest: RemoteMessageRequest())

        switch result {
        case .success(let statusResponse):
            os_log("Successfully fetched remote messages", log: .remoteMessaging, type: .debug)

            let remoteMessagingConfigMatcher = RemoteMessagingConfigMatcher(
                    appAttributeMatcher: AppAttributeMatcher(statisticsStore: statisticsStore,
                                                             variantManager: variantManager,
                                                             isInternalUser: AppDependencyProvider.shared.internalUserDecider.isInternalUser),
                    userAttributeMatcher: UserAttributeMatcher(statisticsStore: statisticsStore,
                                                               variantManager: variantManager,
                                                               bookmarksCount: bookmarksCount,
                                                               favoritesCount: favoritesCount,
                                                               appTheme: AppUserDefaults().currentThemeName.rawValue,
                                                               isWidgetInstalled: isWidgetInstalled),
                    dismissedMessageIds: remoteMessagingStore.fetchDismissedRemoteMessageIds()
            )

            let processor = RemoteMessagingConfigProcessor(remoteMessagingConfigMatcher: remoteMessagingConfigMatcher)
            let config = remoteMessagingStore.fetchRemoteMessagingConfig()

            if let processorResult = processor.process(jsonRemoteMessagingConfig: statusResponse,
                                                       currentConfig: config) {
                remoteMessagingStore.saveProcessedResult(processorResult)
            }
        case .failure(let error):
            os_log("Failed to fetch remote messages", log: .remoteMessaging, type: .error)
            throw error
        }
    }

    static func fetchRemoteMessages(remoteMessageRequest: RemoteMessageRequest) async -> Result<RemoteMessageResponse.JsonRemoteMessagingConfig, RemoteMessageResponse.StatusError> {
        return await withCheckedContinuation { continuation in
            remoteMessageRequest.getRemoteMessage(completionHandler: { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: .success(response))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            })
        }
    }
}
