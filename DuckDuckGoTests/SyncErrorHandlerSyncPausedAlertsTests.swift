//
//  SyncErrorHandlerSyncPausedAlertsTests.swift
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

final class SyncErrorHandlerSyncPausedAlertsTests: XCTestCase {

    var handler: SyncErrorHandler!
    var alertPresenter: CapturingAlertPresenter!

    override func setUp() {
        super.setUp()
        UserDefaultsWrapper<Any>.clearAll()
        alertPresenter = CapturingAlertPresenter()
        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter
    }

    override func tearDown() {
        UserDefaultsWrapper<Any>.clearAll()
        alertPresenter = nil
        handler = nil
        super.tearDown()
    }

    func test_WhenHandleBookmarksError409ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleBookmarkError(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.capturedError, .bookmarksCountLimitExceeded)
    }

    func test_WhenHandleBookmarksError409ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleBookmarkError(error)


        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleBookmarkError(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        XCTAssertEqual(alertPresenter.capturedError, .bookmarksCountLimitExceeded)
    }

    func test_WhenHandleCredentialsError409ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.capturedError, .credentialsCountLimitExceeded)
    }

    func test_WhenHandleCredentialsError409ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        handler.handleCredentialError(error)

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleCredentialError(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        XCTAssertEqual(alertPresenter.capturedError, .credentialsCountLimitExceeded)
    }

    func test_WhenHandleBookmarksError413ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleBookmarkError(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.capturedError, .bookmarksRequestSizeLimitExceeded)
    }

    func test_WhenHandleBookmarksError413ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleBookmarkError(error)

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleBookmarkError(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        XCTAssertEqual(alertPresenter.capturedError, .bookmarksRequestSizeLimitExceeded)
    }

    func test_WhenHandleCredentialsError413ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.capturedError, .credentialsRequestSizeLimitExceeded)
    }

    func test_WhenHandleCredentialsError413ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleCredentialError(error)

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleCredentialError(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        XCTAssertEqual(alertPresenter.capturedError, .credentialsRequestSizeLimitExceeded)
    }

    func test_WhenHandleCredentialsError413_AndThenHandleBookmarksError413_ThenAlertShownTwice() async {
        let error = SyncError.unexpectedStatusCode(413)

        handler.handleCredentialError(error)

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleBookmarkError(_:)(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 2)
        XCTAssertEqual(alertPresenter.capturedError, .bookmarksRequestSizeLimitExceeded)
    }

    func test_WhenHandleCredentialsError401ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(401)

        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.capturedError, .invalidLoginCredentials)
    }

    func test_WhenHandleBookmarksError401ForTheSecondTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(401)

        handler.handleBookmarkError(_:)(error)

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleBookmarkError(_:)(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        XCTAssertEqual(alertPresenter.capturedError, .invalidLoginCredentials)
    }

    func test_WhenHandleCredentialsError400ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)

        handler.handleCredentialError(_:)(error)

        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.capturedError, .badRequestCredentials)
    }

    func test_WhenHandleBookmarksError400ForTheSecondTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)

        handler.handleBookmarkError(_:)(error)

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        handler.handleBookmarkError(_:)(error)

        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        XCTAssertEqual(alertPresenter.capturedError, .badRequestBookmarks)
    }
}
