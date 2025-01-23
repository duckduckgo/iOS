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

final class RemoteMessagingService {

    let remoteMessagingClient: RemoteMessagingClient

    init(persistenceService: PersistenceService,
         appSettings: AppSettings,
         internalUserDecider: InternalUserDecider,
         configurationStore: ConfigurationStore,
         privacyConfigurationManager: PrivacyConfigurationManaging) {
        remoteMessagingClient = RemoteMessagingClient(
            bookmarksDatabase: persistenceService.bookmarksDatabase,
            appSettings: appSettings,
            internalUserDecider: internalUserDecider,
            configurationStore: configurationStore,
            database: persistenceService.database,
            errorEvents: RemoteMessagingStoreErrorHandling(),
            remoteMessagingAvailabilityProvider: PrivacyConfigurationRemoteMessagingAvailabilityProvider(
                privacyConfigurationManager: privacyConfigurationManager
            ),
            duckPlayerStorage: DefaultDuckPlayerStorage()
        )
        remoteMessagingClient.registerBackgroundRefreshTaskHandler()
    }

    func onForeground() {
        refreshRemoteMessages()
    }

    // TODO:  It's public in order to allow refreshing on demand via Debug menu. Otherwise it shouldn't be called from outside.
    func refreshRemoteMessages() {
        Task {
            try? await remoteMessagingClient.fetchAndProcess(using: remoteMessagingClient.store)
        }
    }

}
