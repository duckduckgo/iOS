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
import Foundation

class MarketplaceAdPostbackManagerTests: XCTestCase {
    func testSendAppLaunchPostback_NewUser() {
        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: false)
        let mockUpdater = MockMarketplaceAdPostbackUpdater()
        let manager = MarketplaceAdPostbackManager(returningUserMeasurement: mockReturnUserMeasurement, updater: mockUpdater)

        manager.sendAppLaunchPostback()

        XCTAssertEqual(mockUpdater.postbackSent, .installNewUser)
        XCTAssertEqual(mockUpdater.postbackSent?.coarseValue, .high)
        XCTAssertEqual(mockUpdater.lockPostbackSent, true)
    }

    func testSendAppLaunchPostback_ReturningUser() {
        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: true)
        let mockUpdater = MockMarketplaceAdPostbackUpdater()
        let manager = MarketplaceAdPostbackManager(returningUserMeasurement: mockReturnUserMeasurement, updater: mockUpdater)

        manager.sendAppLaunchPostback()

        XCTAssertEqual(mockUpdater.postbackSent, .installReturningUser)
        XCTAssertEqual(mockUpdater.postbackSent?.coarseValue, .low)
        XCTAssertEqual(mockUpdater.lockPostbackSent, true)
    }
}

private final class MockReturnUserMeasurement: ReturnUserMeasurement {
    func installCompletedWithATB(_ atb: Core.Atb) { }

    func updateStoredATB(_ atb: Core.Atb) { }

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
