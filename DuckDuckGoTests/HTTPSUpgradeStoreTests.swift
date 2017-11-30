//
//  HTTPSUpgradeStoreTests.swift
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

class HTTPSUpgradeStoreTests: XCTestCase {

    func testWhenJSONIsUnexpectedNoDomainsLoaded() {
        let data = JsonTestDataLoader().unexpected()
        let mockPersistence = MockHTTPSUpgradePersistence()
        let testee = HTTPSUpgradeStore(persistence: mockPersistence)
        testee.persist(data: data)

        XCTAssertNil(mockPersistence.domains)
        XCTAssertNil(mockPersistence.wildcardDomains)
    }


    func testWhenJSONIsInvalidNoDomainsLoaded() {
        let data = JsonTestDataLoader().invalid()
        let mockPersistence = MockHTTPSUpgradePersistence()
        let testee = HTTPSUpgradeStore(persistence: mockPersistence)
        testee.persist(data: data)

        XCTAssertNil(mockPersistence.domains)
        XCTAssertNil(mockPersistence.wildcardDomains)
    }

    func testWhenLoadingValidJSONDomainsAndWildcardDomainsLoaded() {
        let data = JsonTestDataLoader().fromJsonFile("MockJson/httpsupgrade.json")
        let mockPersistence = MockHTTPSUpgradePersistence()
        let testee = HTTPSUpgradeStore(persistence: mockPersistence)
        testee.persist(data: data)

        XCTAssertNotNil(mockPersistence.domains)
        XCTAssertEqual(Set<String>([ "www.example.com", "apple.com", "developer.apple.com" ]), Set<String>(mockPersistence.domains!))

        XCTAssertNotNil(mockPersistence.wildcardDomains)
        XCTAssertEqual(Set<String>([ "*.bbc.co.uk", "*.example.com" ]), Set<String>(mockPersistence.wildcardDomains!))
    }

}

fileprivate class MockHTTPSUpgradePersistence: HTTPSUpgradePersistence {

    var domains: [String]?
    var wildcardDomains: [String]?

    func persist(domains: [String], wildcardDomains: [String]) {
        self.domains = domains
        self.wildcardDomains = wildcardDomains
    }

    func hasDomain(_ domain: String) -> Bool {
        return false
    }

}
