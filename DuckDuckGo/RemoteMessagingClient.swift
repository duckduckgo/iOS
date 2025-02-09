//
//  RemoteMessagingClient.swift
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

import Common
import Configuration
import Foundation
import Core
import BackgroundTasks
import BrowserServicesKit
import Persistence
import Bookmarks
import RemoteMessaging
import os.log

final class RemoteMessagingClient: RemoteMessagingProcessing {

    struct Constants {
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.remoteMessageRefresh"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 4
        static let endpoint: URL = {
#if DEBUG
            URL(string: "https://raw.githubusercontent.com/duckduckgo/remote-messaging-config/main/samples/ios/sample1.json")!
#else
            URL(string: "https://staticcdn.duckduckgo.com/remotemessaging/config/v1/ios-config.json")!
#endif
        }()
    }

    let endpoint: URL = Constants.endpoint
    let configFetcher: RemoteMessagingConfigFetching
    let configMatcherProvider: RemoteMessagingConfigMatcherProviding
    let store: RemoteMessagingStoring
    let remoteMessagingAvailabilityProvider: RemoteMessagingAvailabilityProviding

    convenience init(
        bookmarksDatabase: CoreDataDatabase,
        appSettings: AppSettings,
        internalUserDecider: InternalUserDecider,
        configurationStore: ConfigurationStoring,
        database: CoreDataDatabase,
        notificationCenter: NotificationCenter = .default,
        errorEvents: EventMapping<RemoteMessagingStoreError>?,
        remoteMessagingAvailabilityProvider: RemoteMessagingAvailabilityProviding,
        duckPlayerStorage: DuckPlayerStorage
    ) {
        let provider = RemoteMessagingConfigMatcherProvider(
            bookmarksDatabase: bookmarksDatabase,
            appSettings: appSettings,
            internalUserDecider: internalUserDecider,
            duckPlayerStorage: duckPlayerStorage
        )
        let configFetcher = RemoteMessagingConfigFetcher(
            configurationFetcher: ConfigurationFetcher(store: configurationStore, urlSession: .session(), eventMapping: nil),
            configurationStore: configurationStore
        )
        let remoteMessagingStore = RemoteMessagingStore(
            database: database,
            notificationCenter: notificationCenter,
            errorEvents: errorEvents,
            remoteMessagingAvailabilityProvider: remoteMessagingAvailabilityProvider
        )
        self.init(
            configMatcherProvider: provider,
            configFetcher: configFetcher,
            store: remoteMessagingStore,
            remoteMessagingAvailabilityProvider: remoteMessagingAvailabilityProvider
        )
    }

    init(
        configMatcherProvider: RemoteMessagingConfigMatcherProviding,
        configFetcher: RemoteMessagingConfigFetching,
        store: RemoteMessagingStoring,
        remoteMessagingAvailabilityProvider: RemoteMessagingAvailabilityProviding
    ) {
        self.configMatcherProvider = configMatcherProvider
        self.configFetcher = configFetcher
        self.store = store
        self.remoteMessagingAvailabilityProvider = remoteMessagingAvailabilityProvider
    }

    @UserDefaultsWrapper(key: .lastRemoteMessagingRefreshDate, defaultValue: .distantPast)
    static private var lastRemoteMessagingRefreshDate: Date
}

// MARK: - Background Refresh

extension RemoteMessagingClient {

    static private var shouldRefresh: Bool {
        Date().timeIntervalSince(Self.lastRemoteMessagingRefreshDate) > Constants.minimumConfigurationRefreshInterval
    }

    func registerBackgroundRefreshTaskHandler() {
        let provider = configMatcherProvider
        let fetcher = configFetcher
        let remoteMessagingAvailabilityProvider = remoteMessagingAvailabilityProvider
        let store = store

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            guard Self.shouldRefresh else {
                task.setTaskCompleted(success: true)
                Self.scheduleBackgroundRefreshTask()
                return
            }
            let client = RemoteMessagingClient(
                configMatcherProvider: provider,
                configFetcher: fetcher,
                store: store,
                remoteMessagingAvailabilityProvider: remoteMessagingAvailabilityProvider
            )
            Self.backgroundRefreshTaskHandler(bgTask: task, client: client)
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
            Logger.remoteMessaging.error("Failed to schedule background task: \(error.localizedDescription, privacy: .public)")
        }
        #endif
    }

    static func backgroundRefreshTaskHandler(bgTask: BGTask, client: RemoteMessagingClient) {
        let fetchAndProcessTask = Task {
            do {
                if client.remoteMessagingAvailabilityProvider.isRemoteMessagingAvailable {
                    try await client.fetchAndProcess(using: client.store)
                    Self.lastRemoteMessagingRefreshDate = Date()
                }
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
}
