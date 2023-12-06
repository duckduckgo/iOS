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

    @UserDefaultsWrapper(key: .syncCredentialsPaused, defaultValue: false)
    static public var isSyncCredentialsPaused: Bool {
        didSet {
            NotificationCenter.default.post(name: syncCredentialsPausedStateChanged, object: nil)
        }
    }

    @UserDefaultsWrapper(key: .syncCredentialsPausedErrorDisplayed, defaultValue: false)
    static private var didShowCredentialsSyncPausedError: Bool

    public init(secureVaultFactory: AutofillVaultFactory = AutofillSecureVaultFactory, secureVaultErrorReporter: SecureVaultErrorReporting) {
        syncDidCompletePublisher = syncDidCompleteSubject.eraseToAnyPublisher()
        self.secureVaultErrorReporter = secureVaultErrorReporter
        databaseCleaner = CredentialsDatabaseCleaner(
            secureVaultFactory: secureVaultFactory,
            secureVaultErrorReporter: secureVaultErrorReporter,
            errorEvents: CredentialsCleanupErrorHandling(),
            log: .generalLog
        )
    }

    public func cleanUpDatabaseAndUpdateSchedule(shouldEnable: Bool) {
        databaseCleaner.cleanUpDatabaseNow()
        if shouldEnable {
            databaseCleaner.scheduleRegularCleaning()
        } else {
            databaseCleaner.cancelCleaningSchedule()
        }
    }

    public func setUpProviderIfNeeded(secureVaultFactory: AutofillVaultFactory, metadataStore: SyncMetadataStore) {
        guard provider == nil else {
            return
        }

        do {
            let provider = try CredentialsProvider(
                secureVaultFactory: secureVaultFactory,
                secureVaultErrorReporter: secureVaultErrorReporter,
                metadataStore: metadataStore,
                syncDidUpdateData: { [weak self] in
                    self?.syncDidCompleteSubject.send()
                    Self.isSyncCredentialsPaused = false
                    Self.didShowCredentialsSyncPausedError = false
                }
            )

            syncErrorCancellable = provider.syncErrorPublisher
                .sink { error in
                    switch error {
                    case let syncError as SyncError:
                        Pixel.fire(pixel: .syncCredentialsFailed, error: syncError)

                        switch syncError {
                        case .unexpectedStatusCode(409):
                            // If credentials count limit has been exceeded
                            Self.isSyncCredentialsPaused = true
                            DailyPixel.fire(pixel: .syncCredentialsCountLimitExceededDaily)
                            Self.notifyCredentialsSyncLimitReached()
                        case .unexpectedStatusCode(413):
                            // If credentials request size limit has been exceeded
                            Self.isSyncCredentialsPaused = true
                            DailyPixel.fire(pixel: .syncCredentialsRequestSizeLimitExceededDaily)
                            Self.notifyCredentialsSyncLimitReached()
                        default:
                            break
                        }
                    default:
                        let nsError = error as NSError
                        if nsError.domain != NSURLErrorDomain {
                            let processedErrors = CoreDataErrorsParser.parse(error: error as NSError)
                            let params = processedErrors.errorPixelParameters
                            Pixel.fire(pixel: .syncCredentialsFailed, error: error, withAdditionalParameters: params)
                        }
                    }
                    os_log(.error, log: OSLog.syncLog, "Credentials Sync error: %{public}s", String(reflecting: error))
                }

            self.provider = provider

        } catch let error as NSError {
            let processedErrors = CoreDataErrorsParser.parse(error: error)
            let params = processedErrors.errorPixelParameters
            Pixel.fire(pixel: .syncCredentialsProviderInitializationFailed, error: error, withAdditionalParameters: params)
       }
    }

    static private func notifyCredentialsSyncLimitReached() {
        if !Self.didShowCredentialsSyncPausedError {
            NotificationCenter.default.post(name: Self.credentialsSyncLimitReached, object: nil)
            Self.didShowCredentialsSyncPausedError = true
        }
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
    private let secureVaultErrorReporter: SecureVaultErrorReporting
}
