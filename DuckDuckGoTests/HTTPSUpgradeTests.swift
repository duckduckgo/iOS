//
//  HTTPSUpgradeTests.swift
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
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import Core

class HTTPSUpgradeTests: XCTestCase {
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        HTTPStubs.allStubs()
        super.tearDown()
    }

    func testWhenURLIsHttpsThenShouldUpgradeResultIsFalse() {
        let expect = expectation(description: "Https url should not be upgraded")
        let url = URL(string: "https://upgradable.url")!
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsExcludedThenShouldUpgradeResultIsFalse() {
        
        let expect = expectation(description: "Excluded http:// urls should not be upgraded")
        let url = URL(string: "http://excluded.url")!
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsHttpAndCanBeUpgradedThenShouldUpgradeIsTrue() {
        let expect = expectation(description: "Http url in list and should be upgraded")
        let url = URL(string: "http://upgradable.url")!

        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertTrue(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsHttpAndCannotBeUpgradedThenShouldUpgradeIsFalse() {
        let expect = expectation(description: "Http url not in list should not be upgraded")
        let url = URL(string: "http://unknown.url")!

        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    private func bloomFilter() -> BloomFilterWrapper {
        let filter = BloomFilterWrapper(totalItems: Int32(1000), errorRate: 0.0001)!
        filter.add("upgradable.url")
        filter.add("excluded.url")
        return filter
    }
}

private class MockHTTPSUpgradeStore: HTTPSUpgradeStore {
    
    private let httpsBloomFilter: BloomFilterWrapper?
    
    init(bloomFilter: BloomFilterWrapper?) {
        self.httpsBloomFilter = bloomFilter
    }
    
    func bloomFilter() -> BloomFilterWrapper? {
        return httpsBloomFilter
    }
    
    func bloomFilterSpecification() -> HTTPSBloomFilterSpecification? {
        return nil
    }
    
    func persistBloomFilter(specification: HTTPSBloomFilterSpecification, data: Data) -> Bool {
        return true
    }
    
    func shouldExcludeDomain(_ domain: String) -> Bool {
        return domain == "excluded.url"
    }
    
    func persistExcludedDomains(_ domains: [String]) -> Bool {
        return true
    }
}
