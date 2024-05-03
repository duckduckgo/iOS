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

    func test_WhenHandleCredentialsError400ForTheFirstTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookarksError418ForTheFirstTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(418)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_WhenHandleBookarksError429ForTheFirstTime_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(429)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_When400ErrorFired9Times_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)

        Task {
            for _ in 0...8 {
                handler.handleCredentialError(_:)(error)
            }
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 8.0)
        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_When400ErrorFired10Times_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)

        Task {
            for _ in 0...9 {
                handler.handleCredentialError(_:)(error)
            }
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 8.0)
        let currentTime = Date()
        let actualTime = userDefaults.value(forKey: UserDefaultsWrapper<Date>.Key.syncLastErrorNotificationTime.rawValue) as? Date
        let timeDifference = currentTime.timeIntervalSince(actualTime ?? Date(timeIntervalSince1970: 0))
        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertTrue(abs(timeDifference) <= 5)
    }

    func test_When400ErrorFired10TimesTwice_ThenAlertShownOnce() async {
        let error = SyncError.unexpectedStatusCode(400)

        Task {
            for _ in 0...20 {
                handler.handleCredentialError(_:)(error)
            }
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 8.0)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_whenSyncBookmarksSucced_ThenError401AlertCanBeShownAgain() async {
        let error = SyncError.unexpectedStatusCode(401)

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(handler.isSyncPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        handler.syncBookmarksSucceded()

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation2], timeout: 4.0)
        XCTAssertTrue(handler.isSyncPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_whenSyncBookmarksSucced_ThenError409AlertCanBeShownAgain() async {
        let error = SyncError.unexpectedStatusCode(409)

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        handler.syncBookmarksSucceded()

        Task {
            handler.handleBookmarkError(_:)(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation2], timeout: 4.0)
        XCTAssertTrue(handler.isSyncBookmarksPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_whenSyncCredentialsSucced_ThenError413AlertCanBeShownAgain() async {
        let error = SyncError.unexpectedStatusCode(413)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
        handler.syncCredentialsSucceded()

        Task {
            handler.handleCredentialError(_:)(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation2], timeout: 4.0)
        XCTAssertTrue(handler.isSyncCredentialsPaused)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }

    func test_When400ErrorFiredAfter12HoursFromLastSuccessfulSync_ThenAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)
        let thirteenHoursAgo = Calendar.current.date(byAdding: .hour, value: -13, to: Date())!
        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        userDefaults.set(thirteenHoursAgo, forKey: UserDefaultsWrapper<Date>.Key.syncLastSuccesfullTime.rawValue)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation, expectation2], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.showAlertCount, 1)
    }

    func test_When400ErrorFiredAfter12HoursFromLastSuccessfulSync_ButNoErrorRegisteredBefore_ThenNoAlertShown() async {
        let error = SyncError.unexpectedStatusCode(400)
        let thirteenHoursAgo = Calendar.current.date(byAdding: .hour, value: -13, to: Date())!
        userDefaults.set(thirteenHoursAgo, forKey: UserDefaultsWrapper<Date>.Key.syncLastSuccesfullTime.rawValue)

        Task {
            handler.handleCredentialError(_:)(error)
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertFalse(alertPresenter.showAlertCalled)
    }

    func test_When400ErrorFired10Times_AndAfter24H_400ErrorFired10TimesAgain_ThenAlertShownTwice() async {
        let error = SyncError.unexpectedStatusCode(400)

        Task {
            for _ in 0...9 {
                handler.handleCredentialError(_:)(error)
            }
            expectation.fulfill()
        }

        await self.fulfillment(of: [expectation], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
        let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -25, to: Date())!
        userDefaults.set(oneDayAgo, forKey: UserDefaultsWrapper<Date>.Key.syncLastErrorNotificationTime.rawValue)

        Task {
            for _ in 0...9 {
                handler.handleCredentialError(_:)(error)
            }
            expectation2.fulfill()
        }

        await self.fulfillment(of: [expectation2], timeout: 4.0)
        XCTAssertTrue(alertPresenter.showAlertCalled)
        XCTAssertEqual(alertPresenter.showAlertCount, 2)
    }
}
