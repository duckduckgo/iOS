//
//  HTTPSBloomFilterSpecificationTest.swift
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

class HTTPSBloomFilterSpecificationTest: XCTestCase {
    
    let store = HTTPSUpgradePersistence()
    let testee = HTTPSBloomFilterSpecification(bitCount: 100,
                                               errorRate: 0.001,
                                               totalEntries: 100,
                                               sha256: "abc")
    
    func testInitSetsPropertiesCorrectly() {
        XCTAssertEqual(100, testee.totalEntries)
        XCTAssertEqual(0.001, testee.errorRate)
        XCTAssertEqual("abc", testee.sha256)
    }
    
    func testWhenComparedToMatchingSpecificationThenEqualsIsTrue() {
        let equalSpecification = HTTPSBloomFilterSpecification(bitCount: 100,
                                                               errorRate: 0.001,
                                                               totalEntries: 100,
                                                               sha256: "abc")
        XCTAssertTrue(testee == equalSpecification)
    }
    
    func testWhenComparedToDifferentSpecificationThenEqualsIsFalse() {
        let differentSpecification = HTTPSBloomFilterSpecification(bitCount: 100,
                                                                   errorRate: 0.001,
                                                                   totalEntries: 101,
                                                                   sha256: "abc")
        XCTAssertFalse(testee == differentSpecification)
    }
}
