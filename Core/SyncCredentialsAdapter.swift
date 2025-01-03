//
//  SyncCredentialsAdapter.swift
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

public final class SyncCredentialsAdapter {

    public private(set) var provider: CredentialsProvider?
    public let databaseCleaner: CredentialsDatabaseCleaner
    public let syncDidCompletePublisher: AnyPublisher<Void, Never>
    public static let syncCredentialsPausedStateChanged = SyncBookmarksAdapter.syncBookmarksPausedStateChanged
    public static let credentialsSyncLimitReached = Notification.Name("com.duckduckgo.app.SyncCredentialsLimitReached")
    let syncErrorHandler: SyncErrorHandling
    let credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging

    public init(secureVaultFactory: AutofillVaultFactory = AutofillSecureVaultFactory,
                secureVaultErrorReporter: SecureVaultReporting,
                syncErrorHandler: SyncErrorHandling,
                tld: TLD) {
        syncDidCompletePublisher = syncDidCompleteSubject.eraseToAnyPublisher()
        self.secureVaultErrorReporter = secureVaultErrorReporter
        self.syncErrorHandler = syncErrorHandler
        databaseCleaner = CredentialsDatabaseCleaner(
            secureVaultFactory: secureVaultFactory,
            secureVaultErrorReporter: secureVaultErrorReporter,
            errorEvents: CredentialsCleanupErrorHandling()
        )
        credentialIdentityStoreManager = AutofillCredentialIdentityStoreManager(reporter: secureVaultErrorReporter, tld: tld)
    }

    public func cleanUpDatabaseAndUpdateSchedule(shouldEnable: Bool) {
        databaseCleaner.cleanUpDatabaseNow()
        if shouldEnable {
            databaseCleaner.scheduleRegularCleaning()
        } else {
            databaseCleaner.cancelCleaningSchedule()
        }
    }

    public func setUpProviderIfNeeded(
        secureVaultFactory: AutofillVaultFactory,
        metadataStore: SyncMetadataStore,
        metricsEventsHandler: EventMapping<MetricsEvent>? = nil
    ) {
        guard provider == nil else {
            return
        }

        do {
            let provider = try CredentialsProvider(
                secureVaultFactory: secureVaultFactory,
                secureVaultErrorReporter: secureVaultErrorReporter,
                metadataStore: metadataStore,
                metricsEvents: metricsEventsHandler,
                syncDidUpdateData: { [weak self] in
                    self?.syncDidCompleteSubject.send()
                    self?.syncErrorHandler.syncCredentialsSucceded()
                },
                syncDidFinish: { [weak self] credentialsInput in
                    if let credentialsInput, !credentialsInput.modifiedAccounts.isEmpty || !credentialsInput.deletedAccounts.isEmpty {
                        Task {
                            await self?.credentialIdentityStoreManager.updateCredentialStoreWith(updatedAccounts: credentialsInput.modifiedAccounts, deletedAccounts: credentialsInput.deletedAccounts)
                        }
                    }
                }
            )
            syncErrorCancellable = provider.syncErrorPublisher
                .sink { [weak self] error in
                    self?.syncErrorHandler.handleCredentialError(error)
                }

            self.provider = provider

        } catch let error as NSError {
            let processedErrors = CoreDataErrorsParser.parse(error: error)
            let params = processedErrors.errorPixelParameters
            Pixel.fire(pixel: .syncCredentialsProviderInitializationFailed, error: error, withAdditionalParameters: params)
       }
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
    private let secureVaultErrorReporter: SecureVaultReporting
}
