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
        static let retentionAtb = "retentionAtb"
    }
    
    var testee: StatisticsUserDefaults!
    
    override func setUp() {
        UserDefaults().removePersistentDomain(forName: Constants.userDefaultsSuit)
        testee = StatisticsUserDefaults(groupName: Constants.userDefaultsSuit)
    }

    func testWhenFirstInitialisedThenHasStatisticsIsFalseAndAtbValuesNil() {
        XCTAssertNil(testee.atb)
        XCTAssertNil(testee.retentionAtb)
        XCTAssertFalse(testee.hasInstallStatistics)
    }

    func testWhenAtbValuesBothSetThenHasStatisticsIsTrue() {
        testee.atb = Constants.atb
        testee.retentionAtb = Constants.retentionAtb
        XCTAssertTrue(testee.hasInstallStatistics)
    }
    
    func testWhenAtbNotSetThenHasStatisticsIsFalse() {
        testee.atb = Constants.atb
        XCTAssertFalse(testee.hasInstallStatistics)
    }
    
    func testWhenRetentionAtbNotSetThenHasStatisticsIsFalse() {
        testee.retentionAtb = Constants.retentionAtb
        XCTAssertFalse(testee.hasInstallStatistics)
    }
    
    func testWhenAtbValuesSetThenDefaultsUpdated() {
        testee.atb = Constants.atb
        testee.retentionAtb = Constants.retentionAtb
        XCTAssertEqual(testee.atb, Constants.atb)
        XCTAssertEqual(testee.retentionAtb, Constants.retentionAtb)
    }

}
