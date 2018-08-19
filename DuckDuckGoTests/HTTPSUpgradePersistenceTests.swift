//
//  HTTPSUpgradePersistenceTests.swift
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

class HTTPSUpgradePersistenceTests: XCTestCase {

    var testee: HTTPSUpgradePersistence!

    override func setUp() {
        testee = HTTPSUpgradePersistence()
        testee.reset()
    }
    
    override func tearDown() {
        testee.reset()
    }
    
    func testWhenWhitelistDomainsPersistedThenHasDomainIsTrue() {
        testee.persistWhitelist(domains: [ "www.example.com", "apple.com" ])
        XCTAssertTrue(testee.hasWhitelistedDomain("www.example.com"))
        XCTAssertTrue(testee.hasWhitelistedDomain("apple.com"))
    }
    
    func testWhenNoWhitelistDomainsPersistedThenHasDomainIsFalse() {
        XCTAssertFalse(testee.hasWhitelistedDomain("www.example.com"))
        XCTAssertFalse(testee.hasWhitelistedDomain("apple.com"))
    }
}
