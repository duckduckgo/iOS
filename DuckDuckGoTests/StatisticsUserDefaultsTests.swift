//
//  StatisticsUserDefaultsTests.swift
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

import XCTest
@testable import Core

class StatisticsUserDefaultsTests: XCTestCase {

    struct Constants {
        static let userDefaultsSuit = "StatisticsUserDefaultsTestSuit"
        static let atb = "atb"
        static let appRetentionAtb = "appAtb"
        static let searchRetentionAtb = "searchAtb"
        static let variant = "testVariant"
    }

    var testee: StatisticsUserDefaults!

    override func setUp() {
        super.setUp()
        
        UserDefaults().removePersistentDomain(forName: Constants.userDefaultsSuit)
        testee = StatisticsUserDefaults(groupName: Constants.userDefaultsSuit)
    }

    func testWhenNoInstallDateSetThenReturnsNil() {
        XCTAssertNil(testee.installDate)
    }

    func testWhenAtbAndVariantThenAtbWithVariantReturnsAtbWithVariant() {
        testee.atb = Constants.atb
        testee.variant = Constants.variant
        XCTAssertEqual(testee.atbWithVariant, "\(Constants.atb)\(Constants.variant)")
    }

    func testWhenAtbAndNoVariantThenAtbWithVariantReturnsAtb() {
        testee.atb = Constants.atb
        testee.variant = nil
        XCTAssertEqual(testee.atbWithVariant, Constants.atb)
    }

    func testWhenVariantSetThenDefaultsIsUpdated() {
        testee.variant = Constants.variant
        XCTAssertEqual(testee.variant, Constants.variant)
    }

    func testWhenFirstInitialisedThenHasStatisticsIsFalseAndAtbNil() {
        XCTAssertNil(testee.atb)
        XCTAssertFalse(testee.hasInstallStatistics)
        XCTAssertNil(testee.variant)
    }

    func testWhenAtbValueSetThenHasStatisticsIsTrue() {
        testee.atb = Constants.atb
        XCTAssertTrue(testee.hasInstallStatistics)
    }

    func testWhenAtbNotSetThenHasStatisticsIsFalse() {
        XCTAssertFalse(testee.hasInstallStatistics)
    }
    
    func testWhenAtbValueSetThenDefaultsUpdated() {
        testee.atb = Constants.atb
        XCTAssertEqual(testee.atb, Constants.atb)
    }
    
    func testWhenAppRetentionAtbValueSetThenDefaultsUpdated() {
        testee.appRetentionAtb = Constants.appRetentionAtb
        XCTAssertEqual(testee.appRetentionAtb, Constants.appRetentionAtb)
    }
    
    func testWhenAppRetentionAtbNotSetThenAtbDefaultReturned() {
        testee.atb = Constants.atb
        XCTAssertEqual(testee.appRetentionAtb, Constants.atb)
    }
    
    func testWhenSearchRetentionAtbValueSetThenDefaultsUpdated() {
        testee.searchRetentionAtb = Constants.searchRetentionAtb
        XCTAssertEqual(testee.searchRetentionAtb, Constants.searchRetentionAtb)
    }
    
    func testWhenSearchRetentionAtbNotSetThenAtbDefaultIsReturned() {
        testee.atb = Constants.atb
        XCTAssertEqual(testee.searchRetentionAtb, Constants.atb)
    }

}
