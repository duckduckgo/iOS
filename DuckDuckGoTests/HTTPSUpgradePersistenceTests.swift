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

    /// This may fail after embedded data is updated, fix accordingly
    func testWhenBloomNotPersistedThenEmbeddedSpecificationReturned() {
        let sha = "d72a358afca8f70fd1447009efd9e5e42aa7a4e6a01f593da226dbabef0a0052"
        let specification = HTTPSBloomFilterSpecification(bitCount: 12153347, errorRate: 0.000001, totalEntries: 422649, sha256: sha)
        XCTAssertEqual(specification, testee.bloomFilterSpecification())
    }
    
    /// This may fail after embedded data is updated, fix accordingly
    func testWhenBloomNotPersistedThenEmbeddedBloomUsedAndBloomContainsKnownUpgradableSite() {
        XCTAssertNotNil(testee.bloomFilter())
        XCTAssertTrue(testee.bloomFilter()!.contains("facebook.com"))
    }
    
    /// This may fail after embedded data is updated, fix accordingly
    func testWhenBloomNotPersistedThenEmbeddedBloomUsedAndBloomDoesNotContainAnUnknownSite() {
        XCTAssertNotNil(testee.bloomFilter())
        XCTAssertFalse(testee.bloomFilter()!.contains("anUnkonwnSiteThatIsNotInOurUpgradeList.com"))
    }
    
    /// This may fail after embedded data is updated, fix accordingly
    func testWhenBloomNotPersistedThenEmbeddedBloomUsedAndEmbeddedExcludedDomainIsTrue() {
        XCTAssertNotNil(testee.bloomFilter())
        XCTAssertTrue(testee.shouldExcludeDomain("www.dppps.sc.gov"))
    }
        
    func testWhenNewBloomFilterMatchesShaInSpecThenSpecAndDataPersisted() {
        let data = "Hello World!".data(using: .utf8)!
        let sha = "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069"
        let specification = HTTPSBloomFilterSpecification(bitCount: 100, errorRate: 0.01, totalEntries: 100, sha256: sha)
        XCTAssertTrue(testee.persistBloomFilter(specification: specification, data: data))
        XCTAssertEqual(specification, testee.bloomFilterSpecification())
    }
    
    func testWhenNewBloomFilterDoesNotMatchShaInSpecThenSpecAndDataNotPersisted() {
        let data = "Hello World!".data(using: .utf8)!
        let sha = "wrong sha"
        let specification = HTTPSBloomFilterSpecification(bitCount: 100, errorRate: 0.01, totalEntries: 100, sha256: sha)
        XCTAssertFalse(testee.persistBloomFilter(specification: specification, data: data))
        XCTAssertNotEqual(specification, testee.bloomFilterSpecification())
    }

    func testWhenBloomFilterSpecificationIsPersistedThenSpecificationIsRetrieved() {
        let specification = HTTPSBloomFilterSpecification(bitCount: 100, errorRate: 0.01, totalEntries: 100, sha256: "abc")
        testee.persistBloomFilterSpecification(specification)
        XCTAssertEqual(specification, testee.bloomFilterSpecification())
    }
    
    func testWhenBloomFilterSpecificationIsPersistedThenOldSpecificationIsReplaced() {
        let originalSpecification =  HTTPSBloomFilterSpecification(bitCount: 100, errorRate: 0.01, totalEntries: 100, sha256: "abc")
        testee.persistBloomFilterSpecification(originalSpecification)

        let newSpecification = HTTPSBloomFilterSpecification(bitCount: 101, errorRate: 0.01, totalEntries: 101, sha256: "abc")
        testee.persistBloomFilterSpecification(newSpecification)

        let storedSpecification = testee.bloomFilterSpecification()
        XCTAssertEqual(newSpecification, storedSpecification)
    }

    func testWhenExcludedDomainsPersistedThenExcludedDomainIsTrue() {
        testee.persistExcludedDomains([ "www.example.com", "apple.com" ])
        XCTAssertTrue(testee.shouldExcludeDomain("www.example.com"))
        XCTAssertTrue(testee.shouldExcludeDomain("apple.com"))
    }
    
    func testWhenNoExcludedDomainsPersistedThenExcludedDomainIsFalse() {
        XCTAssertFalse(testee.shouldExcludeDomain("www.example.com"))
        XCTAssertFalse(testee.shouldExcludeDomain("apple.com"))
    }
    
    func testWhenExcludedDomainsPersistedThenOldDomainsAreDeleted() {
        testee.persistExcludedDomains([ "www.old.com", "otherold.com" ])
        testee.persistExcludedDomains([ "www.new.com", "othernew.com" ])
        XCTAssertFalse(testee.shouldExcludeDomain("www.old.com"))
        XCTAssertFalse(testee.shouldExcludeDomain("otherold.com"))
        XCTAssertTrue(testee.shouldExcludeDomain("www.new.com"))
        XCTAssertTrue(testee.shouldExcludeDomain("othernew.com"))
    }

}
