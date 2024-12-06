//
//  HomeRowReminderTests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class HomeRowReminderTests: XCTestCase {

    var storage: MockHomeRowReminderStorage!

    override func setUp() {
        super.setUp()
        
        storage = MockHomeRowReminderStorage()
    }

    func testWhenFeatureFirstAccessedThenDateIsStored() {

        let feature = HomeRowReminder(storage: storage)
        _ = feature.showNow()
        XCTAssertNotNil(storage.firstAccessDate)

    }

    func testWhenTimeHasElapseAndAlreadyShownThenDontShow() {
        setReminderTimeElapsed()

        let feature = HomeRowReminder(storage: storage)
        feature.setShown()

        XCTAssertFalse(feature.showNow())
    }

    func testWhenIsNewAndTimeHasElapsedThenShow() {
        setReminderTimeElapsed()

        let feature = HomeRowReminder(storage: storage)
        XCTAssertTrue(feature.showNow())
    }

    func testWhenIsNewAndTimeNotElapsedThenDontShow() {
        let feature = HomeRowReminder(storage: storage)
        XCTAssertFalse(feature.showNow())
    }

    // MARK: - Add To Dock - Onboarding

    func testWhenAddToDockHasShownInOboardingIntroThenDoNotShowAddToDockReminder() {
        // GIVEN
        var variantManager = MockVariantManager()
        variantManager.isSupportedBlock = { feature in
            feature == .addToDockIntro
        }
        let sut = HomeRowReminder(storage: storage, variantManager: variantManager)

        // WHEN
        let result = sut.showNow()

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenAddToDockHasShownInContextualOboardingThenDoNotShowAddToDockReminder() {
        // GIVEN
        var variantManager = MockVariantManager()
        variantManager.isSupportedBlock = { feature in
            feature == .addToDockContextual
        }
        let sut = HomeRowReminder(storage: storage, variantManager: variantManager)

        // WHEN
        let result = sut.showNow()

        // THEN
        XCTAssertFalse(result)
    }

    // MARK: - Helper functions

    private func setReminderTimeElapsed() {
        let threeAndABitDaysAgo = -(60 * 60 * 24 * HomeRowReminder.Constants.reminderTimeInDays * 1.1)
        storage.firstAccessDate = Date(timeIntervalSinceNow: threeAndABitDaysAgo)
    }

}

// MARK: - Mocks

class MockHomeRowReminderStorage: HomeRowReminderStorage {

    var firstAccessDate: Date?
    var shown: Bool = false

}
