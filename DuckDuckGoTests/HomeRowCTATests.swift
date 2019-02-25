//
//  HomeRowCTATests.swift
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

class HomeRowCTATests: XCTestCase {
    
    func testWhenContextualOnboardingFeatureEnabledAnd24HoursPassedSinceInstallThenShowCTA() {
        
        let statistics = MockStatisticsStore()
        statistics.installDate = Date(timeIntervalSinceNow: -24 * 60 * 60)
        
        var variantManager = MockVariantManager()
        variantManager.currentVariant = Variant(name: "x", weight: 0, features: [ .onboardingContextual ])
        
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, statistics: statistics)
        XCTAssertTrue(feature.shouldShow())
        
    }
    
    func testWhenContextualOnboardingFeatureEnabledAndNot24HoursPassedSinceInstallThenDontShowCTA() {
        
        let statistics = MockStatisticsStore()
        statistics.installDate = Date()
        
        var variantManager = MockVariantManager()
        variantManager.currentVariant = Variant(name: "x", weight: 0, features: [ .onboardingContextual ])
        
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, statistics: statistics)
        XCTAssertFalse(feature.shouldShow())
        
    }

    func testWhenDismissedThenDismissedStateStored() {
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: MockVariantManager())
        feature.dismissed()
        XCTAssertTrue(storage.dismissed)
    }

    func testWhenDismissedThenShouldNotShow() {
        let storage = MockHomeRowOnboardingStorage(dismissed: true)
        let feature = HomeRowCTA(storage: storage, variantManager: MockVariantManager())
        XCTAssertFalse(feature.shouldShow())
    }

    func testWhenNotDismissedThenShouldShow() {
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: MockVariantManager())
        XCTAssertTrue(feature.shouldShow())
    }
    
}

class MockHomeRowOnboardingStorage: HomeRowCTAStorage {

    var dismissed: Bool = false

    init(dismissed: Bool) {
        self.dismissed = dismissed
    }

}
