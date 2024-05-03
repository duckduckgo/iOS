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
    private var didShowBookmarksSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncCredentialsPausedErrorDisplayed, defaultValue: false)
    private var didShowCredentialsSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncInvalidLoginPausedErrorDisplayed, defaultValue: false)
    private var didShowInvalidLoginSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncLastErrorNotificationTime, defaultValue: nil)
    private var lastErrorNotificationTime: Date?

    @UserDefaultsWrapper(key: .syncLastSuccesfullTime, defaultValue: nil)
    private var lastSyncSuccessTime: Date?

    @UserDefaultsWrapper(key: .syncLastNonActionableErrorCount, defaultValue: 0)
    private var nonActionableErrorCount: Int

    var isSyncPausedChangedPublisher = PassthroughSubject<Void, Never>()

    private var currentSyncAllPausedError: AsyncErrorType?

    public weak var alertPresenter: AlertPresenter?

    public init() {
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
        resetGeneralErrors()
    }

    private func resetCredentialsErrors() {
        isSyncCredentialsPaused = false
        didShowCredentialsSyncPausedError = false
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
        nonActionableErrorCount += 1
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
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
        let twelveHoursAgo = Calendar.current.date(byAdding: .hour, value: -12, to: Date())!
        let noSuccessfulSyncInLast12h = nonActionableErrorCount > 1 && lastSyncSuccessTime ?? Date() <= twelveHoursAgo

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
        case .unexpectedStatusCode(401):
            syncIsPaused(errorType: .invalidLoginCredentials)
        case .unexpectedStatusCode(400):
            syncIsPaused(errorType: .badRequest)
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
            self.isSyncBookmarksPaused = true
            DailyPixel.fire(pixel: .syncBookmarksCountLimitExceededDaily)
        case .credentialsCountLimitExceeded:
            self.isSyncCredentialsPaused = true
            DailyPixel.fire(pixel: .syncCredentialsCountLimitExceededDaily)
        case .bookmarksRequestSizeLimitExceeded:
            self.isSyncBookmarksPaused = true
            DailyPixel.fire(pixel: .syncBookmarksRequestSizeLimitExceededDaily)
        case .credentialsRequestSizeLimitExceeded:
            self.isSyncCredentialsPaused = true
            DailyPixel.fire(pixel: .syncCredentialsRequestSizeLimitExceededDaily)
        case .invalidLoginCredentials:
            currentSyncAllPausedError = errorType
            self.isSyncPaused = true
        case .tooManyRequests, .badRequest:
            currentSyncAllPausedError = errorType
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
            lastErrorNotificationTime = Date()
        case .badRequest:
            guard shouldShowAlertForNonActionableError() == true else { return }
            alertPresenter?.showSyncPausedAlert(
                title: UserText.syncErrorAlertTitle,
                informative: UserText.syncBadRequestAlertDescription)
            lastErrorNotificationTime = Date()
        }

    }

    private var syncPausedTitle: String? {
        guard let error = currentSyncAllPausedError else { return nil }
        switch error {
        case .invalidLoginCredentials:
            return UserText.syncPausedTitle
        case .tooManyRequests, .badRequest:
            return UserText.syncErrorTitle
        default:
            assertionFailure("Sync Paused error should be one of those listes")
            return nil
        }
    }

    private var syncPausedMessage: String? {
        guard let error = currentSyncAllPausedError else { return nil }
        switch error {
        case .invalidLoginCredentials:
            return UserText.invalidLoginCredentialErrorDescription
        case .tooManyRequests:
            return UserText.tooManyRequestsErrorDescription
        case .badRequest:
            return UserText.badRequestErrorDescription
        default:
            assertionFailure("Sync Paused error should be one of those listes")
            return nil
        }
    }

    private enum ModelType {
        case bookmarks
        case credentials
    }

    private enum AsyncErrorType {
        case bookmarksCountLimitExceeded
        case credentialsCountLimitExceeded
        case bookmarksRequestSizeLimitExceeded
        case credentialsRequestSizeLimitExceeded
        case invalidLoginCredentials
        case tooManyRequests
        case badRequest
    }
}

// MARK: - SyncAdapterErrorHandler
extension SyncErrorHandler: SyncAdapterErrorHandler {
    public func handleBookmarkError(_ error: Error) {
        handleError(error, modelType: .bookmarks)
    }
    
    public func handleCredentialError(_ error: Error) {
        handleError(error, modelType: .credentials)
    }
    
    public func syncBookmarksSucceded() {
        lastSyncSuccessTime = Date()
        resetBookmarksErrors()
    }
    
    public func syncCredentialsSucceded() {
        lastSyncSuccessTime = Date()
        resetCredentialsErrors()
    }
}

// MARK: - SyncSettingsErrorHandler
extension SyncErrorHandler: SyncSettingsErrorHandler {
    public var syncPausedMetadata: SyncPausedErrorMetadata? {
        guard let syncPausedMessage else { return nil }
        guard let syncPausedTitle else { return nil }
        return SyncPausedErrorMetadata(syncPausedTitle: syncPausedTitle,
                                       syncPausedMessage: syncPausedMessage,
                                       syncPausedButtonTitle: "")
    }

    @MainActor
    public var syncBookmarksPausedMetadata: SyncPausedErrorMetadata {
        return SyncPausedErrorMetadata(syncPausedTitle: UserText.syncLimitExceededTitle,
                                       syncPausedMessage: UserText.bookmarksLimitExceededDescription,
                                       syncPausedButtonTitle: UserText.bookmarksLimitExceededAction)
    }

    @MainActor
    public var syncCredentialsPausedMetadata: SyncPausedErrorMetadata {
        return SyncPausedErrorMetadata(syncPausedTitle: UserText.syncLimitExceededTitle,
                                       syncPausedMessage: UserText.credentialsLimitExceededDescription,
                                       syncPausedButtonTitle: UserText.credentialsLimitExceededAction)
    }

    public var syncPausedChangedPublisher: AnyPublisher<Void, Never> {
        isSyncPausedChangedPublisher.eraseToAnyPublisher()
    }

    public func syncDidTurnOff() {
        resetBookmarksErrors()
        resetCredentialsErrors()
    }
}

public protocol SyncAdapterErrorHandler {
    func handleBookmarkError(_ error: Error)
    func handleCredentialError(_ error: Error)
    func syncBookmarksSucceded()
    func syncCredentialsSucceded()
}

public protocol AlertPresenter: AnyObject {
    func showSyncPausedAlert(title: String, informative: String)
}

public protocol SyncSettingsErrorHandler: ObservableObject {
    var isSyncPaused: Bool { get }
    var isSyncBookmarksPaused: Bool { get }
    var isSyncCredentialsPaused: Bool { get }
    var syncPausedChangedPublisher: AnyPublisher<Void, Never> { get }
    var syncPausedMetadata: SyncPausedErrorMetadata? { get }
    var syncBookmarksPausedMetadata: SyncPausedErrorMetadata { get }
    var syncCredentialsPausedMetadata: SyncPausedErrorMetadata { get }

    func syncDidTurnOff()
}

public struct SyncPausedErrorMetadata {
    public let syncPausedTitle: String
    public let syncPausedMessage: String
    public let syncPausedButtonTitle: String

    public init(syncPausedTitle: String, syncPausedMessage: String, syncPausedButtonTitle: String) {
        self.syncPausedTitle = syncPausedTitle
        self.syncPausedMessage = syncPausedMessage
        self.syncPausedButtonTitle = syncPausedButtonTitle
    }
}
