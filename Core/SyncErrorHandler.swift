//
//  SyncErrorHandler.swift
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

import Common
import DDGSync
import Combine
import Persistence
import Foundation
import SyncUI_iOS
import SyncDataProviders
import os.log

public enum AsyncErrorType: String {
    case bookmarksCountLimitExceeded
    case credentialsCountLimitExceeded
    case bookmarksRequestSizeLimitExceeded
    case credentialsRequestSizeLimitExceeded
    case invalidLoginCredentials
    case tooManyRequests
    case badRequestBookmarks
    case badRequestCredentials
}

public class SyncErrorHandler: EventMapping<SyncError> {
    @UserDefaultsWrapper(key: .syncBookmarksPaused, defaultValue: false)
    private(set) public var isSyncBookmarksPaused: Bool {
        didSet {
            isSyncPausedChangedPublisher.send()
        }
    }

    @UserDefaultsWrapper(key: .syncCredentialsPaused, defaultValue: false)
    private(set) public var isSyncCredentialsPaused: Bool {
        didSet {
            isSyncPausedChangedPublisher.send()
        }
    }

    @UserDefaultsWrapper(key: .syncIsPaused, defaultValue: false)
    private(set) public var isSyncPaused: Bool {
        didSet {
            isSyncPausedChangedPublisher.send()
        }
    }

    @UserDefaultsWrapper(key: .syncBookmarksPausedErrorDisplayed, defaultValue: false)
    var didShowBookmarksSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncCredentialsPausedErrorDisplayed, defaultValue: false)
    var didShowCredentialsSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncInvalidLoginPausedErrorDisplayed, defaultValue: false)
    var didShowInvalidLoginSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncLastErrorNotificationTime, defaultValue: nil)
    var lastErrorNotificationTime: Date?

    @UserDefaultsWrapper(key: .syncLastSuccesfullTime, defaultValue: nil)
    var lastSyncSuccessTime: Date?

    @UserDefaultsWrapper(key: .syncLastNonActionableErrorCount, defaultValue: 0)
    var nonActionableErrorCount: Int

    @UserDefaultsWrapper(key: .syncCurrentAllPausedError, defaultValue: nil)
    public var currentSyncAllPausedError: String?

    @UserDefaultsWrapper(key: .syncCurrentBookmarksPausedError, defaultValue: nil)
    public var currentSyncBookmarksPausedError: String?

    @UserDefaultsWrapper(key: .syncCurrentCredentialsPausedError, defaultValue: nil)
    public var currentSyncCredentialsPausedError: String?

    var isSyncPausedChangedPublisher = PassthroughSubject<Void, Never>()
    let dateProvider: CurrentDateProviding
    public weak var alertPresenter: SyncAlertsPresenting?

    public init(dateProvider: CurrentDateProviding = Date()) {
        self.dateProvider = dateProvider
        super.init { event, error, _, _ in
            switch event {
            case .failedToMigrate:
                Pixel.fire(pixel: .syncFailedToMigrate, error: error)
            case .failedToLoadAccount:
                Pixel.fire(pixel: .syncFailedToLoadAccount, error: error)
            case .failedToSetupEngine:
                Pixel.fire(pixel: .syncFailedToSetupEngine, error: error)
            case .failedToReadSecureStore:
                Pixel.fire(pixel: .syncSecureStorageReadError, error: error)
            case .failedToDecodeSecureStoreData(let error):
                Pixel.fire(pixel: .syncSecureStorageDecodingError, error: error)
            case .accountRemoved(let reason):
                Pixel.fire(pixel: .syncAccountRemoved(reason: reason.rawValue), error: error)
            default:
                // Should this be so generic?
                let domainEvent = Pixel.Event.syncSentUnauthenticatedRequest
                Pixel.fire(pixel: domainEvent, error: event)
            }
        }
    }

    override init(mapping: @escaping EventMapping<SyncError>.Mapping) {
        fatalError("Use init()")
    }
}

// MARK: - Private functions
extension SyncErrorHandler {
    private func resetBookmarksErrors() {
        isSyncBookmarksPaused = false
        didShowBookmarksSyncPausedError = false
        currentSyncBookmarksPausedError = nil
        resetGeneralErrors()
    }
    private func resetCredentialsErrors() {
        isSyncCredentialsPaused = false
        didShowCredentialsSyncPausedError = false
        currentSyncCredentialsPausedError = nil
        resetGeneralErrors()
    }
    private func resetGeneralErrors() {
        isSyncPaused = false
        didShowInvalidLoginSyncPausedError = false
        lastErrorNotificationTime = nil
        currentSyncAllPausedError = nil
        nonActionableErrorCount = 0
    }

    private func shouldShowAlertForNonActionableError() -> Bool {
        let currentDate = dateProvider.currentDate
        nonActionableErrorCount += 1
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        var lastErrorNotificationWasMoreThan24hAgo: Bool
        if let lastErrorNotificationTime {
            lastErrorNotificationWasMoreThan24hAgo = lastErrorNotificationTime < oneDayAgo
        } else {
            lastErrorNotificationWasMoreThan24hAgo = true
        }
        let areThere10ConsecutiveError = nonActionableErrorCount >= 10
        if nonActionableErrorCount >= 10 {
            nonActionableErrorCount = 0
        }
        let twelveHoursAgo = Calendar.current.date(byAdding: .hour, value: -12, to: currentDate)!
        let noSuccessfulSyncInLast12h = nonActionableErrorCount > 1 && lastSyncSuccessTime ?? currentDate <= twelveHoursAgo

        return lastErrorNotificationWasMoreThan24hAgo &&
        (areThere10ConsecutiveError || noSuccessfulSyncInLast12h)
    }

    private func handleError(_ error: Error, modelType: ModelType) {
        switch error {
        case SyncError.patchPayloadCompressionFailed(let errorCode):
            Pixel.fire(pixel: modelType.patchPayloadCompressionFailedPixel, withAdditionalParameters: ["error": "\(errorCode)"])
        case let syncError as SyncError:
            handleSyncError(syncError, modelType: modelType)
            Pixel.fire(pixel: modelType.syncFailedPixel, error: syncError)
        case let settingsMetadataError as SettingsSyncMetadataSaveError:
            let underlyingError = settingsMetadataError.underlyingError
            let processedErrors = CoreDataErrorsParser.parse(error: underlyingError as NSError)
            let params = processedErrors.errorPixelParameters
            Pixel.fire(pixel: .syncSettingsMetadataUpdateFailed, error: underlyingError, withAdditionalParameters: params)
        default:
            let nsError = error as NSError
            if nsError.domain != NSURLErrorDomain {
                let processedErrors = CoreDataErrorsParser.parse(error: error as NSError)
                let params = processedErrors.errorPixelParameters
                Pixel.fire(pixel: modelType.syncFailedPixel, error: error, withAdditionalParameters: params)
            }
        }
        let modelTypeString = modelType.rawValue.capitalized
        Logger.sync.error("\(modelTypeString, privacy: .public) Sync error: \(error.localizedDescription, privacy: .public)")
    }

    private func handleSyncError(_ syncError: SyncError, modelType: ModelType) {
        switch syncError {
        case .unexpectedStatusCode(409):
            switch modelType {
            case .bookmarks:
                syncIsPaused(errorType: .bookmarksCountLimitExceeded)
            case .credentials:
                syncIsPaused(errorType: .credentialsCountLimitExceeded)
            case .settings:
                break
            }
        case .unexpectedStatusCode(413):
            switch modelType {
            case .bookmarks:
                syncIsPaused(errorType: .bookmarksRequestSizeLimitExceeded)
            case .credentials:
                syncIsPaused(errorType: .credentialsRequestSizeLimitExceeded)
            case .settings:
                break
            }
        case .unexpectedStatusCode(400):
            switch modelType {
            case .bookmarks:
                syncIsPaused(errorType: .badRequestBookmarks)
            case .credentials:
                syncIsPaused(errorType: .badRequestCredentials)
            case .settings:
                break
            }
            DailyPixel.fire(pixel: modelType.badRequestPixel)
        case .unexpectedStatusCode(401):
            syncIsPaused(errorType: .invalidLoginCredentials)
        case .unexpectedStatusCode(418), .unexpectedStatusCode(429):
            syncIsPaused(errorType: .tooManyRequests)
            DailyPixel.fire(pixel: modelType.tooManyRequestsPixel)
        default:
            break
        }
    }

    private func syncIsPaused(errorType: AsyncErrorType) {
        showSyncPausedAlertIfNeeded(for: errorType)
        switch errorType {
        case .bookmarksCountLimitExceeded:
            currentSyncBookmarksPausedError = errorType.rawValue
            self.isSyncBookmarksPaused = true
            DailyPixel.fire(pixel: .syncBookmarksObjectLimitExceededDaily)
        case .credentialsCountLimitExceeded:
            currentSyncCredentialsPausedError = errorType.rawValue
            self.isSyncCredentialsPaused = true
            DailyPixel.fire(pixel: .syncCredentialsObjectLimitExceededDaily)
        case .bookmarksRequestSizeLimitExceeded:
            currentSyncBookmarksPausedError = errorType.rawValue
            self.isSyncBookmarksPaused = true
            DailyPixel.fire(pixel: .syncBookmarksRequestSizeLimitExceededDaily)
        case .credentialsRequestSizeLimitExceeded:
            currentSyncCredentialsPausedError = errorType.rawValue
            self.isSyncCredentialsPaused = true
            DailyPixel.fire(pixel: .syncCredentialsRequestSizeLimitExceededDaily)
        case .badRequestBookmarks:
            currentSyncBookmarksPausedError = errorType.rawValue
            self.isSyncBookmarksPaused = true
        case .badRequestCredentials:
            currentSyncCredentialsPausedError = errorType.rawValue
            self.isSyncCredentialsPaused = true
        case .invalidLoginCredentials:
            currentSyncAllPausedError = errorType.rawValue
            self.isSyncPaused = true
        case .tooManyRequests:
            currentSyncAllPausedError = errorType.rawValue
            self.isSyncPaused = true
        }
    }
    private func showSyncPausedAlertIfNeeded(for errorType: AsyncErrorType) {
        switch errorType {
        case .bookmarksCountLimitExceeded, .bookmarksRequestSizeLimitExceeded:
            guard !didShowBookmarksSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(for: errorType)
            didShowBookmarksSyncPausedError = true
        case .credentialsCountLimitExceeded, .credentialsRequestSizeLimitExceeded:
            guard !didShowCredentialsSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(for: errorType)
            didShowCredentialsSyncPausedError = true
        case .badRequestBookmarks:
            guard !didShowBookmarksSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(for: errorType)
            didShowBookmarksSyncPausedError = true
        case .badRequestCredentials:
            guard !didShowCredentialsSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(for: errorType)
            didShowCredentialsSyncPausedError = true
        case .invalidLoginCredentials:
            guard !didShowInvalidLoginSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(for: errorType)
            didShowInvalidLoginSyncPausedError = true
        case .tooManyRequests:
            guard shouldShowAlertForNonActionableError() == true else { return }
            alertPresenter?.showSyncPausedAlert(for: errorType)
            lastErrorNotificationTime = dateProvider.currentDate
        }

    }
    private enum ModelType: String {
        case bookmarks
        case credentials
        case settings

        var syncFailedPixel: Pixel.Event {
            switch self {
            case .bookmarks:
                    .syncBookmarksFailed
            case .credentials:
                    .syncCredentialsFailed
            case .settings:
                    .syncSettingsFailed
            }
        }

        var patchPayloadCompressionFailedPixel: Pixel.Event {
            switch self {
            case .bookmarks:
                    .syncBookmarksPatchCompressionFailed
            case .credentials:
                    .syncCredentialsPatchCompressionFailed
            case .settings:
                    .syncSettingsPatchCompressionFailed
            }
        }

        var tooManyRequestsPixel: Pixel.Event {
            switch self {
            case .bookmarks:
                    .syncBookmarksTooManyRequestsDaily
            case .credentials:
                    .syncCredentialsTooManyRequestsDaily
            case .settings:
                    .syncSettingsTooManyRequestsDaily
            }
        }

        var badRequestPixel: Pixel.Event {
            switch self {
            case .bookmarks:
                    .syncBookmarksValidationErrorDaily
            case .credentials:
                    .syncCredentialsValidationErrorDaily
            case .settings:
                    .syncSettingsValidationErrorDaily
            }
        }
    }
}

// MARK: - SyncErrorHandler
extension SyncErrorHandler: SyncErrorHandling {
    public func handleSettingsError(_ error: Error) {
        handleError(error, modelType: .settings)
    }
    
    public func handleBookmarkError(_ error: Error) {
        handleError(error, modelType: .bookmarks)
    }
    
    public func handleCredentialError(_ error: Error) {
        handleError(error, modelType: .credentials)
    }
    
    public func syncBookmarksSucceded() {
        lastSyncSuccessTime = dateProvider.currentDate
        resetBookmarksErrors()
    }
    
    public func syncCredentialsSucceded() {
        lastSyncSuccessTime = dateProvider.currentDate
        resetCredentialsErrors()
    }
}

// MARK: - syncPausedStateManager
extension SyncErrorHandler: SyncPausedStateManaging {
    public var syncPausedChangedPublisher: AnyPublisher<Void, Never> {
        isSyncPausedChangedPublisher.eraseToAnyPublisher()
    }

    public func syncDidTurnOff() {
        resetBookmarksErrors()
        resetCredentialsErrors()
    }
}
