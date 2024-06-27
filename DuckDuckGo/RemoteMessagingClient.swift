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

final class RemoteMessagingClient: RemoteMessagingProcessing {

    struct Constants {
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.remoteMessageRefresh"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 4
        static let endpoint: URL = {
#if DEBUG
            URL(string: "https://staticcdn.kapusta.cc/macos-desktop-browser/remote-messaging-config.json")!
#else
            URL(string: "https://staticcdn.duckduckgo.com/remotemessaging/config/v1/ios-config.json")!
#endif
        }()
    }

    let configurationFetcher: RemoteMessagingConfigFetching
    let configMatcherProvider: RemoteMessagingConfigMatcherProviding

    let endpoint: URL = Constants.endpoint

    convenience init(
        bookmarksDatabase: CoreDataDatabase,
        appSettings: AppSettings,
        internalUserDecider: InternalUserDecider,
        configurationStore: ConfigurationStoring
    ) {
        let provider = RemoteMessagingConfigMatcherProvider(
            bookmarksDatabase: bookmarksDatabase,
            appSettings: appSettings,
            internalUserDecider: internalUserDecider
        )
        let configurationFetcher = RemoteMessagingConfigFetcher(
            configurationFetcher: ConfigurationFetcher(store: configurationStore, urlSession: .session(), log: .remoteMessaging, eventMapping: nil),
            configurationStore: ConfigurationStore.shared
        )
        self.init(configMatcherProvider: provider, configurationFetcher: configurationFetcher)
    }

    init(configMatcherProvider: RemoteMessagingConfigMatcherProviding, configurationFetcher: RemoteMessagingConfigFetching) {
        self.configMatcherProvider = configMatcherProvider
        self.configurationFetcher = configurationFetcher
    }

    @UserDefaultsWrapper(key: .lastRemoteMessagingRefreshDate, defaultValue: .distantPast)
    static private var lastRemoteMessagingRefreshDate: Date
}

// MARK: - Background Refresh

extension RemoteMessagingClient {

    static private var shouldRefresh: Bool {
        return Date().timeIntervalSince(Self.lastRemoteMessagingRefreshDate) > Constants.minimumConfigurationRefreshInterval
    }

    func registerBackgroundRefreshTaskHandler(with store: RemoteMessagingStoring) {
        let provider = configMatcherProvider
        let fetcher = configurationFetcher

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            guard Self.shouldRefresh else {
                task.setTaskCompleted(success: true)
                Self.scheduleBackgroundRefreshTask()
                return
            }
            let client = RemoteMessagingClient(configMatcherProvider: provider, configurationFetcher: fetcher)
            Self.backgroundRefreshTaskHandler(bgTask: task, client: client, store: store)
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

    static func backgroundRefreshTaskHandler(bgTask: BGTask, client: RemoteMessagingClient, store: RemoteMessagingStoring) {
        let fetchAndProcessTask = Task {
            do {
                try await client.fetchAndProcess(using: store)
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
}
