//
//  FeatureManagerTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Foundation

import XCTest
import Core

class FeatureManagerTests: XCTestCase {

    var statistics: StatisticsStore!

    override func setUp() {
        super.setUp()
        statistics = MockStatisticsStore()
    }

    func testWhenVariantIsM3NoAtbThenHomeRowOnboardingAndReminderAreEnabled() {

        statistics.atb = nil
        let featureManager = DefaultFeatureManager(variantManager: MockVariantManager(currentVariant: "m3"), statistics: statistics)
        XCTAssertTrue(featureManager.feature(named: .homerow_onboarding).isEnabled)
        XCTAssertTrue(featureManager.feature(named: .homerow_reminder).isEnabled)

    }

    func testWhenVariantIsM3AndMatchingAtbThenHomeRowOnboardingAndReminderAreEnabled() {

        statistics.atb = "something_m3"
        let featureManager = DefaultFeatureManager(variantManager: MockVariantManager(currentVariant: "m3"), statistics: statistics)
        XCTAssertTrue(featureManager.feature(named: .homerow_onboarding).isEnabled)
        XCTAssertTrue(featureManager.feature(named: .homerow_reminder).isEnabled)
        
    }

    func testWhenVariantIsM2AndMatchingAtbThenHomeRowOnboardingIsEnabledAndReminderIsNotEnabled() {
        
        statistics.atb = "something_m2"
        let featureManager = DefaultFeatureManager(variantManager: MockVariantManager(currentVariant: "m2"), statistics: statistics)
        XCTAssertTrue(featureManager.feature(named: .homerow_onboarding).isEnabled)
        XCTAssertFalse(featureManager.feature(named: .homerow_reminder).isEnabled)
        
    }

    func testWhenVariantIsM1AndMatchingAtbThenHomeRowOnboardingAndReminderAreNotEnabled() {

        statistics.atb = "something_m1"
        let featureManager = DefaultFeatureManager(variantManager: MockVariantManager(currentVariant: "m1"), statistics: statistics)
        XCTAssertFalse(featureManager.feature(named: .homerow_onboarding).isEnabled)
        XCTAssertFalse(featureManager.feature(named: .homerow_reminder).isEnabled)

    }

}

struct MockVariantManager: VariantManager {
    
    var currentVariant: String
    
}
