//
//  SyncErrorHandlerSyncErrorsAlertsTests.swift
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
@testable import Core

final class SyncErrorHandlerSyncErrorsAlertsTests: XCTestCase {
    var handler: SyncErrorHandler!
    var alertPresenter: CapturingAlertPresenter!
    var dateProvider: MockDateProvider!

    override func setUp() {
        super.setUp()
        UserDefaultsWrapper<Any>.clearAll()
        dateProvider = MockDateProvider()
        alertPresenter = CapturingAlertPresenter()
        handler = SyncErrorHandler(dateProvider: dateProvider)
        handler.alertPresenter = alertPresenter
    }

    override func tearDown() {
        alertPresenter = nil
        dateProvider = nil
        handler = nil
        UserDefaultsWrapper<Any>.clearAll()
        super.tearDown()
    }

    func test_WhenHandleCredentialsError429ForTheFirstTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(429)

        handler.handleCredentialError(_:)(error)

        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookmarksError418ForTheFirstTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(418)

        handler.handleCredentialError(_:)(error)

        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookmarksError429ForTheFirstTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(429)

        handler.handleBookmarkError(_:)(error)

        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_When429ErrorFired9Times_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(429)

        for _ in 0...8 {
            handler.handleCredentialError(_:)(error)
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_When418ErrorFired10Times_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(418)

        for _ in 0...10 {
            handler.handleCredentialError(_:)(error)
        }

        let currentTime = Date()
        let actualTime = handler.lastErrorNotificationTime
        let timeDifference = currentTime.timeIntervalSince(actualTime ?? Date(timeIntervalSince1970: 0))
        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertTrue(abs(timeDifference) <= 5)
    }

    func test_When400ErrorFired10TimesTwice_ThenAlertShownOnce() async {
        let error = SyncError.unexpectedStatusCode(400)

        for _ in 0...20 {
            handler.handleCredentialError(_:)(error)
        }

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_whenSyncBookmarksSucced_ThenError401AlertCanBeShownAgain() async {
        let error = SyncError.unexpectedStatusCode(401)

        handler.handleBookmarkError(_:)(error)

        XCTAssertTrue(handler.isSyncPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        handler.syncBookmarksSucceded()

        handler.handleBookmarkError(_:)(error)

        XCTAssertTrue(handler.isSyncPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_whenSyncBookmarksSucced_ThenError409AlertCanBeShownAgain() async {
        let error = SyncError.unexpectedStatusCode(409)
        
        handler.handleBookmarkError(_:)(error)
        
        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        handler.syncBookmarksSucceded()
        
        handler.handleBookmarkError(_:)(error)

        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_whenSyncCredentialsSucced_ThenError413AlertCanBeShownAgain() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        handler.syncCredentialsSucceded()

        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_When400ErrorFiredAfter12HoursFromLastSuccessfulSync_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)
        let thirteenHoursAgo = Calendar.current.date(byAdding: .hour, value: -13, to: Date())!
        dateProvider.currentDate = thirteenHoursAgo
        handler.syncCredentialsSucceded()
        handler.handleCredentialError(_:)(error)

        dateProvider.currentDate = Date()
        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_When418ErrorFiredAfter12HoursFromLastSuccessfulSync_ButNoErrorRegisteredBefore_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(418)
        let thirteenHoursAgo = Calendar.current.date(byAdding: .hour, value: -13, to: Date())!
        dateProvider.currentDate = thirteenHoursAgo
        handler.syncBookmarksSucceded()

        dateProvider.currentDate = Date()
        handler.handleCredentialError(_:)(error)

        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_When429ErrorFired10Times_AndAfter24H_429ErrorFired10TimesAgain_ThenAlertShownTwice() async {
        let error = SyncError.unexpectedStatusCode(429)
        let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -25, to: Date())!
        dateProvider.currentDate = oneDayAgo

        for _ in 0...9 {
            handler.handleCredentialError(_:)(error)
        }
        
        XCTAssertTrue(alertPresenter.showAlertCalled)
        dateProvider.currentDate = Date()

        for _ in 0...9 {
            handler.handleCredentialError(_:)(error)
        }
        
        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }
}

class MockDateProvider: CurrentDateProviding {
    var currentDate: Date = Date()
}
