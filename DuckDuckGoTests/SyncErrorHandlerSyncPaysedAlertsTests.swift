//
//  SyncErrorHandlerSyncPaysedAlertsTests.swift
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

final class SyncErrorHandlerSyncPaysedAlertsTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var handler: SyncErrorHandler!
    var alertPresenter: CapturingAlertPresenter!
    var expectation: XCTestExpectation!
    var expectation2: XCTestExpectation!
    let userDefaults = UserDefaults.standard

    override func setUpWithError() throws {
        expectation = XCTestExpectation(description: "Error handled")
        expectation2 = XCTestExpectation(description: "Secons Error handled")
        UserDefaultsWrapper<Any>.clearAll()
        cancellables = []
        alertPresenter = CapturingAlertPresenter()
        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter
    }

    override func tearDownWithError() throws {
        cancellables = nil
        alertPresenter = nil
        handler = nil
    }

    func test_WhenHandleBookmarksError409ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        Task {
            handler.handleBookmarkError(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookmarksError409ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        Task {
            handler.handleBookmarkError(error)
            expectation.fulfill()
        }

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        Task {
            handler.handleBookmarkError(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_WhenHandleCredentialsError409ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleCredentialsError409ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(409)

        Task {
            handler.handleCredentialError(error)
            expectation.fulfill()
        }

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        Task {
            handler.handleCredentialError(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_WhenHandleBookmarksError413ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        Task {
            handler.handleBookmarkError(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookmarksError413ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        Task {
            handler.handleBookmarkError(error)
            expectation.fulfill()
        }

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        Task {
            handler.handleBookmarkError(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_WhenHandleCredentialsError413ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleCredentialsError413ForTheSecondTime_ThenAlertNotShown() async {
        let error = SyncError.unexpectedStatusCode(413)

        Task {
            handler.handleCredentialError(error)
            expectation.fulfill()
        }

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        Task {
            handler.handleCredentialError(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_WhenHandleCredentialsError413_AndThenHandleBookmarksError413_ThenAlertShownTwice() async {
        let error = SyncError.unexpectedStatusCode(413)

        Task {
            handler.handleCredentialError(error)
            expectation.fulfill()
        }

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_WhenHandleCredentialsError401ForTheFirstTime_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(401)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookmarksError401ForTheSecondTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(401)

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation.fulfill()
        }

        handler = SyncErrorHandler()
        handler.alertPresenter = alertPresenter

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

}
