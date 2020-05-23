//
//  PreserveLoginsTests.swift
//  UnitTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class PreserveLoginsTests: XCTestCase {
    
    override func setUp() {
        UserDefaultsWrapper<Any>.clearAll()
    }
    
    func testWhenAllowedDomainsContainsFireproofedDomainThenReturnsTrue() {
        let logins = PreserveLogins()
        XCTAssertFalse(logins.isAllowed(fireproofDomain: "example.com"))
        logins.addToAllowed(domain: "example.com")
        XCTAssertTrue(logins.isAllowed(fireproofDomain: "example.com"))
    }

    func testWhenLegacyAllowedDomainsThenMigratedAndCleared() {
        UserDefaults.standard.set(["domain1.com"], forKey: UserDefaultsWrapper<Any>.Key.preserveLoginsLegacyAllowedDomains.rawValue)
        let logins = PreserveLogins()
        XCTAssertEqual(["domain1.com"], logins.legacyAllowedDomains)
        logins.clearLegacyAllowedDomains()
        XCTAssertNil(UserDefaults.standard.object(forKey: UserDefaultsWrapper<Any>.Key.preserveLoginsLegacyAllowedDomains.rawValue))
    }
    
    func testWhenNewThenAllowedDomainsIsEmpty() {
        let logins = PreserveLogins()
        XCTAssertTrue(logins.allowedDomains.isEmpty)
    }

}
