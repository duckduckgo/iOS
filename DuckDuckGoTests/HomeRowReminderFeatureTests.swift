//
//  HomeRowReminderFeatureTests.swift
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

class HomeRowReminderFeatureTests: XCTestCase {

    var storage: MockHomeRowReminderFeatureStorage!
    
    override func setUp() {
        storage = MockHomeRowReminderFeatureStorage()
    }

    func testWhenFeatureIsEnabledAndFirstAccessedThenDateIsStored() {

        let feature = HomeRowReminderFeature(featureManager: MockFeatureManager(enabled: true), storage: storage)
        _ = feature.showNow()
        XCTAssertNotNil(storage.firstAccessDate)
        
    }
    
    func testWhenFeatureEnabledAndTimeHasElapseAndAlreadyShownThenDontShow() {
        setReminderTimeElapsed()

        let feature = HomeRowReminderFeature(featureManager: MockFeatureManager(enabled: true), storage: storage)
        feature.setShown()
        
        XCTAssertFalse(feature.showNow())
    }
    
    func testWhenFeatureEnabledAndIsNewAndTimeHasElapsedThenShow() {
        setReminderTimeElapsed()
        
        let feature = HomeRowReminderFeature(featureManager: MockFeatureManager(enabled: true), storage: storage)
        XCTAssertTrue(feature.showNow())
    }

    func testWhenFeatureEnabledAndIsNewAndTimeNotElapsedThenDontShow() {
        let feature = HomeRowReminderFeature(featureManager: MockFeatureManager(enabled: true), storage: storage)
        XCTAssertFalse(feature.showNow())
    }

    func testWhenFeatureNotEnabledAndTimeElapsedThenDontShow() {
        setReminderTimeElapsed()
        let feature = HomeRowReminderFeature(featureManager: MockFeatureManager(enabled: false), storage: storage)
        XCTAssertFalse(feature.showNow())
    }
    
    private func setReminderTimeElapsed() {
        storage.firstAccessDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * HomeRowReminderFeature.Constants.reminderTimeInDays * 1.1) // 3.1 days ago
    }

}

struct MockFeatureManager: FeatureManager {
    
    let enabled: Bool
    
    func feature(named: FeatureName) -> Feature {
        return Feature(name: named.rawValue, isEnabled: enabled)
    }
    
}

class MockHomeRowReminderFeatureStorage: HomeRowReminderFeatureStorage {

    var firstAccessDate: Date?
    var shown: Bool = false
        
}
