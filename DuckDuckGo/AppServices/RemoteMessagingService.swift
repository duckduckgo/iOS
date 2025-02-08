//
//  RemoteMessagingService.swift
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

import Foundation
import BrowserServicesKit
import Configuration
import RemoteMessaging
import Core
import Persistence
import BackgroundTasks

final class RemoteMessagingService {

    let remoteMessagingClient: RemoteMessagingClient

    init(bookmarksDatabase: CoreDataDatabase,
         database: CoreDataDatabase,
         appSettings: AppSettings,
         internalUserDecider: InternalUserDecider,
         configurationStore: ConfigurationStore,
         privacyConfigurationManager: PrivacyConfigurationManaging) {
        remoteMessagingClient = RemoteMessagingClient(
            bookmarksDatabase: bookmarksDatabase,
            appSettings: appSettings,
            internalUserDecider: internalUserDecider,
            configurationStore: configurationStore,
            database: database,
            errorEvents: RemoteMessagingStoreErrorHandling(),
            remoteMessagingAvailabilityProvider: PrivacyConfigurationRemoteMessagingAvailabilityProvider(
                privacyConfigurationManager: privacyConfigurationManager
            ),
            duckPlayerStorage: DefaultDuckPlayerStorage()
        )
        remoteMessagingClient.registerBackgroundRefreshTaskHandler()
    }

    func onForeground() {
        scheduleBackgroundTask()
        refreshRemoteMessages()
    }

    private func scheduleBackgroundTask() {
        guard UIApplication.shared.backgroundRefreshStatus == .available else {
            return
        }

        // BackgroundTasks will automatically replace an existing task in the queue if one with the same identifier is queued, so we should only
        // schedule a task if there are none pending in order to avoid the config task getting perpetually replaced.
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            let hasRemoteMessageFetchTask = tasks.contains { $0.identifier == RemoteMessagingClient.Constants.backgroundRefreshTaskIdentifier }
            if !hasRemoteMessageFetchTask {
                RemoteMessagingClient.scheduleBackgroundRefreshTask()
            }
        }
    }

    func refreshRemoteMessages() {
        Task {
            try? await remoteMessagingClient.fetchAndProcess(using: remoteMessagingClient.store)
        }
    }

}
