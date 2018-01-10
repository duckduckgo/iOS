//
//  CoreDataHTTPSUpgradePersistenceTests.swift
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

class CoreDataHTTPSUpgradePersistenceTests: XCTestCase {

    var testee: CoreDataHTTPSUpgradePersistence!

    override func setUp() {
        testee = CoreDataHTTPSUpgradePersistence()
        testee.reset()
    }
    
    func testWhenDomainIsMixedCaseDomainIsStillFound() {
        testee.persist(domains: [ "www.bbc.co.uk", "apple.com" ], wildcardDomains: [ "*.example.com", "*.cnn.com" ])
        XCTAssertTrue(testee.hasDomain("APPLE.com"))
        XCTAssertTrue(testee.hasDomain("EDITION.cnn.com"))
    }

    func testWhenSimpleAndWildcardDomainsPersistedDomainsAreFound() {
        testee.persist(domains: [ "www.bbc.co.uk", "apple.com" ], wildcardDomains: [ "*.example.com", "*.cnn.com" ])
        XCTAssertTrue(testee.hasDomain("www.bbc.co.uk"))
        XCTAssertTrue(testee.hasDomain("apple.com"))
        XCTAssertTrue(testee.hasDomain("example.com"))
        XCTAssertTrue(testee.hasDomain("www.example.com"))
        XCTAssertTrue(testee.hasDomain("cnn.com"))
        XCTAssertTrue(testee.hasDomain("edition.cnn.com"))
        XCTAssertFalse(testee.hasDomain("duckduckgo.com"))
    }

    func testWhenWildcardDomainPersistedPersistenceHasDomain() {
        testee.persist(domains: [], wildcardDomains: [ "*.example.com" ])
        XCTAssertTrue(testee.hasDomain("example.com"))
        XCTAssertTrue(testee.hasDomain("www.example.com"))
        XCTAssertTrue(testee.hasDomain("www.extra.example.com"))
    }

    func testWhenSimpleDomainPersistedPersistenceHasDomain() {
        testee.persist(domains: ["www.example.com" ], wildcardDomains: [])
        XCTAssertTrue(testee.hasDomain("www.example.com"))
        XCTAssertFalse(testee.hasDomain("bbc.co.uk"))
    }

    func testWhenNoDomainsPersistedPersistenceDoesNotHaveDomain() {
        testee.persist(domains: [], wildcardDomains: [])
        XCTAssertFalse(testee.hasDomain("www.example.com"))
    }

}
