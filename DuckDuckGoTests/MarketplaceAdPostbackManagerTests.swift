//
//  MarketplaceAdPostbackManagerTests.swift
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
@testable import Core
import BrowserServicesKit
import Foundation

class MarketplaceAdPostbackManagerTests: XCTestCase {
    func testSendAppLaunchPostback_NewUser() {
        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: false)
        let mockUpdater = MockMarketplaceAdPostbackUpdater()
        let mockStorage = MockMarketplaceAdPostbackStorage(isReturningUser: false)
        let manager = MarketplaceAdPostbackManager(storage: mockStorage, updater: mockUpdater, returningUserMeasurement: mockReturnUserMeasurement)

        manager.sendAppLaunchPostback()

        XCTAssertEqual(mockUpdater.postbackSent, .installNewUser)
        XCTAssertEqual(mockUpdater.postbackSent?.coarseValue, .high)
        XCTAssertEqual(mockUpdater.lockPostbackSent, true)
    }

    func testSendAppLaunchPostback_ReturningUser() {
        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: true)
        let mockUpdater = MockMarketplaceAdPostbackUpdater()
        let mockStorage = MockMarketplaceAdPostbackStorage(isReturningUser: true)
        let manager = MarketplaceAdPostbackManager(storage: mockStorage, updater: mockUpdater, returningUserMeasurement: mockReturnUserMeasurement)

        manager.sendAppLaunchPostback()

        XCTAssertEqual(mockUpdater.postbackSent, .installReturningUser)
        XCTAssertEqual(mockUpdater.postbackSent?.coarseValue, .low)
        XCTAssertEqual(mockUpdater.lockPostbackSent, true)
    }

    func testSendAppLaunchPostback_AfterMeasurementChangesState() {
        /// Sets return user to true to mock the situation where the user is opening the app again
        /// If the storage is set to false, it should still be set as new user
        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: true)
        let mockUpdater = MockMarketplaceAdPostbackUpdater()
        let mockStorage = MockMarketplaceAdPostbackStorage(isReturningUser: false)
        let manager = MarketplaceAdPostbackManager(storage: mockStorage, updater: mockUpdater, returningUserMeasurement: mockReturnUserMeasurement)

        manager.sendAppLaunchPostback()

        XCTAssertEqual(mockUpdater.postbackSent, .installNewUser)
        XCTAssertEqual(mockUpdater.postbackSent?.coarseValue, .high)
        XCTAssertEqual(mockUpdater.lockPostbackSent, true)
    }
}

private final class MockReturnUserMeasurement: ReturnUserMeasurement {
    func installCompletedWithATB(_ atb: Atb) { }

    func updateStoredATB(_ atb: Atb) { }

    var isReturningUser: Bool

    init(isReturningUser: Bool) {
        self.isReturningUser = isReturningUser
    }
}

private final class MockMarketplaceAdPostbackUpdater: MarketplaceAdPostbackUpdating {
    var postbackSent: MarketplaceAdPostback?
    var lockPostbackSent: Bool?

    func updatePostback(_ postback: MarketplaceAdPostback, lockPostback: Bool) {
        postbackSent = postback
        lockPostbackSent = lockPostback
    }
}

private final class MockMarketplaceAdPostbackStorage: MarketplaceAdPostbackStorage {
    var isReturningUser: Bool?

    init(isReturningUser: Bool?) {
        self.isReturningUser = isReturningUser
    }

    func updateReturningUserValue(_ value: Bool) {
        isReturningUser = value
    }
}
