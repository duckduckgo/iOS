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
    
    func testWhenBloomFilterSpecificationIsNotPersistedThenSpecificationIsNil() {
        XCTAssertNil(testee.bloomFilterSpecification())
    }

    func testWhenBloomFilterMatchesShaInSpecThenSpecAndDataPersisted() {
        let data = "Hello World!".data(using: .utf8)!
        let sha = "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069"
        let specification = HTTPSTransientBloomFilterSpecification(totalEntries: 100, errorRate: 0.01, sha256: sha)        
        XCTAssertTrue(testee.persistBloomFilter(specification: specification, data: data))
    }
    
    func testWhenBloomFilterDoesNotMatchShaInSpecThenSpecAndDataNotPersisted() {
        let data = "Hello World!".data(using: .utf8)!
        let sha = "wrong sha"
        let speciifcation = HTTPSTransientBloomFilterSpecification(totalEntries: 100, errorRate: 0.01, sha256: sha)
        testee.persistBloomFilter(specification: speciifcation, data: data)
        XCTAssertNil(testee.bloomFilterSpecification())
        XCTAssertNil(testee.bloomFilter())
    }

    func testWhenBloomFilterSpecificationIsPersistedThenSpecificationIsRetrieved() {
        let speciifcation = HTTPSTransientBloomFilterSpecification(totalEntries: 100, errorRate: 0.01, sha256: "abc")
        testee.persistBloomFilterSpecification(speciifcation)
        XCTAssertTrue(speciifcation.matches(storedSpecification: testee.bloomFilterSpecification()))
    }
    
    func testWhenBloomFilterSpecificationIsPersistedThenOldSpecificationIsReplaced() {
        let originalSpeciifcation = HTTPSTransientBloomFilterSpecification(totalEntries: 100, errorRate: 0.01, sha256: "abc")
        testee.persistBloomFilterSpecification(originalSpeciifcation)

        let newSpeciifcation = HTTPSTransientBloomFilterSpecification(totalEntries: 101, errorRate: 0.01, sha256: "abc")
        testee.persistBloomFilterSpecification(newSpeciifcation)

        let storedSpecification = testee.bloomFilterSpecification()
        XCTAssertTrue(newSpeciifcation.matches(storedSpecification: storedSpecification))
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
    
    func testWhenWhitelistDomainsPersistedThenOldDomainsAreDeleted() {
        testee.persistWhitelist(domains: [ "www.old.com", "otherold.com" ])
        testee.persistWhitelist(domains: [ "www.new.com", "othernew.com" ])
        XCTAssertFalse(testee.hasWhitelistedDomain("www.old.com"))
        XCTAssertFalse(testee.hasWhitelistedDomain("otherold.com"))
        XCTAssertTrue(testee.hasWhitelistedDomain("www.new.com"))
        XCTAssertTrue(testee.hasWhitelistedDomain("othernew.com"))
    }
}
