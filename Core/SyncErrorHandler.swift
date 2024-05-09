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
import SyncUI

public class SyncErrorHandler: EventMapping<SyncError> {
    @UserDefaultsWrapper(key: .syncBookmarksPaused, defaultValue: false)
    private (set) public var isSyncBookmarksPaused: Bool {
        didSet {
            isSyncPausedChangedPublisher.send()
        }
    }

    @UserDefaultsWrapper(key: .syncCredentialsPaused, defaultValue: false)
    private (set) public var isSyncCredentialsPaused: Bool {
        didSet {
            isSyncPausedChangedPublisher.send()
        }
    }

    @UserDefaultsWrapper(key: .synclsPaused, defaultValue: false)
    private (set) public var isSyncPaused: Bool {
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
    private var currentSyncAllPausedError: String?

    @UserDefaultsWrapper(key: .syncCurrentBookmarksPausedError, defaultValue: nil)
    private var currentSyncBookmarksPausedError: String?

    @UserDefaultsWrapper(key: .syncCurrentCredentialsPausedError, defaultValue: nil)
    private var currentSyncCredentialsPausedError: String?

    var isSyncPausedChangedPublisher = PassthroughSubject<Void, Never>()
    let dateProvider: DateProviding
    public weak var alertPresenter: SyncAlertsPresenting?

    public init(dateProvider: DateProviding = Date()) {
        self.dateProvider = dateProvider
        super.init { event, error, _, _ in
            switch event {
            case .failedToMigrate:
                Pixel.fire(pixel: .syncFailedToMigrate, error: error)
            case .failedToLoadAccount:
                Pixel.fire(pixel: .syncFailedToLoadAccount, error: error)
            case .failedToSetupEngine:
                Pixel.fire(pixel: .syncFailedToSetupEngine, error: error)
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
        case let syncError as SyncError:
            handleSyncError(syncError, modelType: modelType)
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
    
    private func handleSyncError(_ syncError: SyncError, modelType: ModelType) {
        switch syncError {
        case .unexpectedStatusCode(409):
            switch modelType {
            case .bookmarks:
                syncIsPaused(errorType: .bookmarksCountLimitExceeded)
            case .credentials:
                syncIsPaused(errorType: .credentialsCountLimitExceeded)
            }
        case .unexpectedStatusCode(413):
            switch modelType {
            case .bookmarks:
                syncIsPaused(errorType: .bookmarksRequestSizeLimitExceeded)
            case .credentials:
                syncIsPaused(errorType: .credentialsRequestSizeLimitExceeded)
            }
        case .unexpectedStatusCode(400):
            switch modelType {
            case .bookmarks:
                syncIsPaused(errorType: .badRequestBookmarks)
            case .credentials:
                syncIsPaused(errorType: .badRequestCredentials)
            }
        case .unexpectedStatusCode(401):
            syncIsPaused(errorType: .invalidLoginCredentials)
        case .unexpectedStatusCode(418), .unexpectedStatusCode(429):
            syncIsPaused(errorType: .tooManyRequests)
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
            DailyPixel.fire(pixel: .syncBookmarksCountLimitExceededDaily)
        case .credentialsCountLimitExceeded:
            currentSyncCredentialsPausedError = errorType.rawValue
            self.isSyncCredentialsPaused = true
            DailyPixel.fire(pixel: .syncCredentialsCountLimitExceededDaily)
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
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncBookmarkPausedAlertTitle,
                informative: UserText.syncBookmarkPausedAlertDescription)
            didShowBookmarksSyncPausedError = true
        case .credentialsCountLimitExceeded, .credentialsRequestSizeLimitExceeded:
            guard !didShowCredentialsSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncCredentialsPausedAlertTitle,
                informative: UserText.syncCredentialsPausedAlertDescription)
            didShowCredentialsSyncPausedError = true
        case .badRequestBookmarks:
            guard !didShowBookmarksSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncBookmarkPausedAlertTitle,
                informative: UserText.syncBadRequestAlertDescription)
            didShowBookmarksSyncPausedError = true
        case .badRequestCredentials:
            guard !didShowCredentialsSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncBookmarkPausedAlertTitle,
                informative: UserText.syncBadRequestAlertDescription)
            didShowCredentialsSyncPausedError = true
        case .invalidLoginCredentials:
            guard !didShowInvalidLoginSyncPausedError else { return }
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncPausedAlertTitle,
                informative: UserText.syncInvalidLoginAlertDescription)
            didShowInvalidLoginSyncPausedError = true
        case .tooManyRequests:
            guard shouldShowAlertForNonActionableError() == true else { return }
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncErrorAlertTitle,
                informative: UserText.syncTooManyRequestsAlertDescription)
            lastErrorNotificationTime = dateProvider.currentDate
        }

    }
    private func getErrorType(from errorString: String?) -> AsyncErrorType? {
        guard let errorString = errorString else {
            return nil
        }
        return AsyncErrorType(rawValue: errorString)
    }
    private var syncPausedTitle: String? {
        guard let error = getErrorType(from: currentSyncAllPausedError) else { return nil }
        switch error {
        case .invalidLoginCredentials:
            return UserText.syncPausedTitle
        case .tooManyRequests:
            return UserText.syncErrorTitle
        default:
            assertionFailure("Sync Paused error should be one of those listed")
            return nil
        }
    }
    private var syncPausedMessage: String? {
        guard let error = getErrorType(from: currentSyncAllPausedError) else { return nil }
        switch error {
        case .invalidLoginCredentials:
            return UserText.invalidLoginCredentialErrorDescription
        case .tooManyRequests:
            return UserText.tooManyRequestsErrorDescription
        default:
            assertionFailure("Sync Paused error should be one of those listed")
            return nil
        }
    }
    private var syncBookmarksPausedMessage: String? {
        guard let error = getErrorType(from: currentSyncBookmarksPausedError) else { return nil }
        switch error {
        case .bookmarksCountLimitExceeded, .bookmarksRequestSizeLimitExceeded:
            return UserText.bookmarksLimitExceededDescription
        case .badRequestBookmarks:
            return UserText.badRequestErrorDescription
        default:
            assertionFailure("Sync Bookmarks Paused error should be one of those listed")
            return nil
        }
    }
    private var syncCredentialsPausedMessage: String? {
        guard let error = getErrorType(from: currentSyncCredentialsPausedError) else { return nil }
        switch error {
        case .credentialsCountLimitExceeded, .credentialsRequestSizeLimitExceeded:
            return UserText.credentialsLimitExceededDescription
        case .badRequestBookmarks:
            return UserText.badRequestErrorDescription
        default:
            assertionFailure("Sync Bookmarks Paused error should be one of those listed")
            return nil
        }
    }
    private enum ModelType {
        case bookmarks
        case credentials
    }
    private enum AsyncErrorType: String {
        case bookmarksCountLimitExceeded
        case credentialsCountLimitExceeded
        case bookmarksRequestSizeLimitExceeded
        case credentialsRequestSizeLimitExceeded
        case invalidLoginCredentials
        case tooManyRequests
        case badRequestBookmarks
        case badRequestCredentials
    }
}

// MARK: - SyncErrorHandler
extension SyncErrorHandler: SyncErrorHandling {
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
    public var syncPausedMessageData: SyncPausedMessageData? {
        guard let syncPausedMessage else { return nil }
        guard let syncPausedTitle else { return nil }
        return SyncPausedMessageData(title: syncPausedTitle,
                                       message: syncPausedMessage,
                                       buttonTitle: "")
    }

    @MainActor
    public var syncBookmarksPausedMessageData: SyncPausedMessageData? {
        guard let syncBookmarksPausedMessage else { return nil }
        return SyncPausedMessageData(title: UserText.syncLimitExceededTitle,
                                     message: syncBookmarksPausedMessage,
                                     buttonTitle: UserText.bookmarksLimitExceededAction)
    }

    @MainActor
    public var syncCredentialsPausedMessageData: SyncPausedMessageData? {
        guard let syncCredentialsPausedMessage else { return nil }
        return SyncPausedMessageData(title: UserText.syncLimitExceededTitle,
                                     message: syncCredentialsPausedMessage,
                                     buttonTitle: UserText.credentialsLimitExceededAction)
    }

    public var syncPausedChangedPublisher: AnyPublisher<Void, Never> {
        isSyncPausedChangedPublisher.eraseToAnyPublisher()
    }

    public func syncDidTurnOff() {
        resetBookmarksErrors()
        resetCredentialsErrors()
    }
}
