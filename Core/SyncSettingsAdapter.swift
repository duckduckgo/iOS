//
//  SyncSettingsAdapter.swift
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

import BrowserServicesKit
import Combine
import Common
import DDGSync
import Persistence
import SyncDataProviders

public final class SyncSettingsAdapter {

    public private(set) var provider: SettingsProvider?
    public private(set) var emailManager: EmailManager?
    public let syncDidCompletePublisher: AnyPublisher<Void, Never>
    private let syncErrorHandler: SyncErrorHandling

    public init(settingHandlers: [SettingSyncHandler], syncErrorHandler: SyncErrorHandling) {
        self.settingHandlers = settingHandlers
        syncDidCompletePublisher = syncDidCompleteSubject.eraseToAnyPublisher()
        self.syncErrorHandler = syncErrorHandler
    }

    public func updateDatabaseCleanupSchedule(shouldEnable: Bool) {
    }

    public func setUpProviderIfNeeded(
        metadataDatabase: CoreDataDatabase,
        metadataStore: SyncMetadataStore,
        metricsEventsHandler: EventMapping<MetricsEvent>? = nil
    ) {
        guard provider == nil else {
            return
        }

        let emailManager = EmailManager()
        let emailProtectionSyncHandler = EmailProtectionSyncHandler(emailManager: emailManager)

        let provider = SettingsProvider(
            metadataDatabase: metadataDatabase,
            metadataStore: metadataStore,
            settingsHandlers: settingHandlers + [emailProtectionSyncHandler],
            metricsEvents: metricsEventsHandler,
            syncDidUpdateData: { [weak self] in
                self?.syncDidCompleteSubject.send()
            }
        )

        syncErrorCancellable = provider.syncErrorPublisher
            .sink { [weak self] error in
                self?.syncErrorHandler.handleSettingsError(error)
            }

        self.provider = provider
        self.emailManager = emailManager
    }

    private let settingHandlers: [SettingSyncHandler]
    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
}
