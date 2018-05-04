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
    var enabledVariantManager = MockVariantManager(currentVariant: Variant(name: "anything", percent: 100, features: [ .homeRowReminder ]))
    var disabledVariantManager = MockVariantManager(currentVariant: Variant(name: "anything", percent: 100, features: [ ]))
    
    override func setUp() {
        storage = MockHomeRowReminderStorage()
    }

    func testWhenFeatureIsEnabledAndFirstAccessedThenDateIsStored() {

        let feature = HomeRowReminder(variantManager: enabledVariantManager, storage: storage)
        _ = feature.showNow()
        XCTAssertNotNil(storage.firstAccessDate)
        
    }
    
    func testWhenFeatureEnabledAndTimeHasElapseAndAlreadyShownThenDontShow() {
        setReminderTimeElapsed()
        
        let feature = HomeRowReminder(variantManager: enabledVariantManager, storage: storage)
        feature.setShown()
        
        XCTAssertFalse(feature.showNow())
    }
    
    func testWhenFeatureEnabledAndIsNewAndTimeHasElapsedThenShow() {
        setReminderTimeElapsed()
        
        let feature = HomeRowReminder(variantManager: enabledVariantManager, storage: storage)
        XCTAssertTrue(feature.showNow())
    }

    func testWhenFeatureEnabledAndIsNewAndTimeNotElapsedThenDontShow() {
        let feature = HomeRowReminder(variantManager: enabledVariantManager, storage: storage)
        XCTAssertFalse(feature.showNow())
    }

    func testWhenFeatureNotEnabledAndTimeElapsedThenDontShow() {
        setReminderTimeElapsed()
        let feature = HomeRowReminder(variantManager: disabledVariantManager, storage: storage)
        XCTAssertFalse(feature.showNow())
    }
    
    private func setReminderTimeElapsed() {
        let threeAndABitDaysAgo = -(60 * 60 * 24 * HomeRowReminder.Constants.reminderTimeInDays * 1.1)
        storage.firstAccessDate = Date(timeIntervalSinceNow: threeAndABitDaysAgo)
    }

}

class MockHomeRowReminderStorage: HomeRowReminderStorage {

    var firstAccessDate: Date?
    var shown: Bool = false
        
}
