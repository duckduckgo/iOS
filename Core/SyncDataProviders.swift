//
//  SyncDataProviders.swift
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
import SecureStorage
import SyncDataProviders

public class SyncDataProviders: DataProvidersSource {
    public let bookmarksAdapter: SyncBookmarksAdapter
    public let credentialsAdapter: SyncCredentialsAdapter

    public func makeDataProviders() -> [DataProviding] {
        initializeMetadataDatabaseIfNeeded()
        guard let syncMetadata else {
            assertionFailure("Sync Metadata not initialized")
            return []
        }

        bookmarksAdapter.setUpProviderIfNeeded(database: bookmarksDatabase, metadataStore: syncMetadata)
        credentialsAdapter.setUpProviderIfNeeded(secureVaultFactory: secureVaultFactory, metadataStore: syncMetadata)

        let providers: [Any] = [
            bookmarksAdapter.provider as Any,
            credentialsAdapter.provider as Any
        ]

        return providers.compactMap { $0 as? DataProviding }
    }

    public func setUpDatabaseCleaners(syncService: DDGSync) {
        bookmarksAdapter.databaseCleaner.isSyncActive = { [weak syncService] in
            syncService?.authState == .active
        }
        credentialsAdapter.databaseCleaner.isSyncActive = { [weak syncService] in
            syncService?.authState == .active
        }

        let syncAuthStateDidChangePublisher = syncService.authStatePublisher
            .dropFirst()
            .map { $0 == .inactive }
            .removeDuplicates()

        syncAuthStateDidChangeCancellable = syncAuthStateDidChangePublisher
            .sink { [weak self] isSyncDisabled in
                self?.credentialsAdapter.updateDatabaseCleanupSchedule(shouldEnable: isSyncDisabled)
                self?.bookmarksAdapter.updateDatabaseCleanupSchedule(shouldEnable: isSyncDisabled)
            }

        if syncService.authState == .inactive {
            bookmarksAdapter.databaseCleaner.cleanUpDatabaseNow()
            bookmarksAdapter.databaseCleaner.scheduleRegularCleaning()
            credentialsAdapter.databaseCleaner.cleanUpDatabaseNow()
            credentialsAdapter.databaseCleaner.scheduleRegularCleaning()
        }
    }

    public init(
        bookmarksDatabase: CoreDataDatabase,
        secureVaultFactory: AutofillVaultFactory = AutofillSecureVaultFactory,
        secureVaultErrorReporter: SecureVaultErrorReporting
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.secureVaultFactory = secureVaultFactory
        self.secureVaultErrorReporter = secureVaultErrorReporter
        bookmarksAdapter = SyncBookmarksAdapter(database: bookmarksDatabase)
        credentialsAdapter = SyncCredentialsAdapter(secureVaultFactory: secureVaultFactory, secureVaultErrorReporter: secureVaultErrorReporter)
    }

    private func initializeMetadataDatabaseIfNeeded() {
        guard !isSyncMetadaDatabaseLoaded else {
            return
        }

        syncMetadataDatabase.loadStore { context, error in
            guard context != nil else {
                if let error = error {
                    Pixel.fire(pixel: .syncMetadataCouldNotLoadDatabase, error: error)
                } else {
                    Pixel.fire(pixel: .syncMetadataCouldNotLoadDatabase)
                }

                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not create Sync Metadata database stack: \(error?.localizedDescription ?? "err")")
            }
        }
        syncMetadata = LocalSyncMetadataStore(database: syncMetadataDatabase)
        isSyncMetadaDatabaseLoaded = true
    }

    private var isSyncMetadaDatabaseLoaded: Bool = false
    private var syncMetadata: SyncMetadataStore?
    private var syncAuthStateDidChangeCancellable: AnyCancellable?

    private let syncMetadataDatabase: CoreDataDatabase = SyncMetadataDatabase.make()
    private let bookmarksDatabase: CoreDataDatabase
    private let secureVaultFactory: AutofillVaultFactory
    private let secureVaultErrorReporter: SecureVaultErrorReporting
}
