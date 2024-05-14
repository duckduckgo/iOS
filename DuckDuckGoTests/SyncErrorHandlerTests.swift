//
//  SyncErrorHandlerTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import XCTest
import DDGSync
import Combine
import DuckDuckGo
@testable import Core

final class SyncErrorHandlerTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var handler: SyncErrorHandler!
    var alertPresenter: CapturingAlertPresenter!
    let userDefaults = UserDefaults.app

    override func setUp() {
        super.setUp()
        UserDefaultsWrapper<Any>.clearAll()
        userDefaults.synchronize()
        cancellables = []
        alertPresenter = CapturingAlertPresenter()
        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter
    }

    override func tearDown() {
        UserDefaultsWrapper<Any>.clearAll()
        cancellables = nil
        alertPresenter = nil
        handler = nil
        super.tearDown()
    }

    func testInitialization_DefaultsNotSet() {
        let handler = SyncErrorHandler()
        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenIsSyncBookmarksPaused_ThenSyncPausedChangedPublisherIsTriggered() async {
        let expectation = XCTestExpectation(description: "syncPausedChangedPublisher")
        handler.syncPausedChangedPublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        handler.handleBookmarkError(SyncError.unexpectedStatusCode(409))

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(handler.isSyncBookmarksPaused)
    }

    func test_WhenIsSyncCredentialsPaused_ThenSyncPausedChangedPublisherIsTriggered() async {
        let expectation = XCTestExpectation(description: "syncPausedChangedPublisher")
        handler.syncPausedChangedPublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        handler.handleCredentialError(SyncError.unexpectedStatusCode(409))

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
    }

    func test_WhenIsSyncPaused_ThenSyncPausedChangedPublisherIsTriggered() async {
        let expectation = XCTestExpectation(description: "syncPausedChangedPublisher")

        handler.syncPausedChangedPublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        handler.handleBookmarkError(SyncError.unexpectedStatusCode(401))

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError409_ThenIsSyncBookmarksPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleBookmarkError(error)

        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialsError409_ThenIsSyncCredentialsPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleCredentialError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError413_ThenIsSyncBookmarksPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleBookmarkError(error)

        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialsError413_ThenIsSyncCredentialsPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleCredentialError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError401_ThenIsSyncPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(401)

        handler.handleBookmarkError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialsError401_ThenIsSyncIsPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(401)

        handler.handleCredentialError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError418_ThenIsSyncPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(418)

        handler.handleBookmarkError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialsError418_ThenIsSyncIsPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(418)

        handler.handleCredentialError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError429_ThenIsSyncPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(429)

        handler.handleBookmarkError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialsError429_ThenIsSyncIsPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(429)

        handler.handleCredentialError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError400_ThenIsSyncPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(400)

        handler.handleBookmarkError(error)

        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialsError400_ThenIsSyncIsPausedIsUpdatedToTrue() async {
        let error = SyncError.unexpectedStatusCode(400)

        handler.handleCredentialError(error)

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleBookmarksError409_AndHandlerIsReinitialised_ThenErrorIsStillPresent() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleBookmarkError(error)

        handler = SyncErrorHandler()

        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialError409_AndHandlerIsReinitialised_ThenErrorIsStillPresent() async {
        let error = SyncError.unexpectedStatusCode(409)
        
        handler.handleCredentialError(error)

        handler = SyncErrorHandler()

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)
    }

    func test_WhenHandleCredentialError429_AndHandlerIsReinitialised_ThenErrorIsStillPresent() async {
        let error = SyncError.unexpectedStatusCode(429)

        handler.handleCredentialError(error)

        handler = SyncErrorHandler()

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertTrue(handler.isSyncPaused)
    }

    func test_whenSyncBookmarksSucced_ThenDateSaved() async {
        handler.syncBookmarksSucceded()
        let actualTime =  handler.lastSyncSuccessTime
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(actualTime ?? Date(timeIntervalSince1970: 0))

        XCTAssertNotNil(actualTime)
        XCTAssertTrue(abs(timeDifference) <= 10)
    }

    func test_whenCredentialsSucced_ThenDateSaved() async {
        handler.syncCredentialsSucceded()
        let actualTime =  handler.lastSyncSuccessTime
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(actualTime ?? Date(timeIntervalSince1970: 0))

        XCTAssertNotNil(actualTime)
        XCTAssertTrue(abs(timeDifference) <= 10)
    }

    func test_whenSyncTurnedOff_errorsAreReset() async {
        handler.handleCredentialError(_:)(SyncError.unexpectedStatusCode(409))
        handler.handleBookmarkError(_:)(SyncError.unexpectedStatusCode(409))
        handler.handleBookmarkError(_:)(SyncError.unexpectedStatusCode(401))

        handler.syncDidTurnOff()

        XCTAssertFalse(handler.isSyncBookmarksPaused)
        XCTAssertFalse(handler.isSyncCredentialsPaused)
        XCTAssertFalse(handler.isSyncPaused)

        XCTAssertNil(handler.lastSyncSuccessTime)
        XCTAssertFalse(handler.didShowBookmarksSyncPausedError)
        XCTAssertFalse(handler.didShowCredentialsSyncPausedError)
        XCTAssertFalse(handler.didShowInvalidLoginSyncPausedError)
        XCTAssertNil(handler.lastErrorNotificationTime)
        XCTAssertEqual(handler.nonActionableErrorCount, 0)
    }
}
