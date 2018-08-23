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
@testable import Core

class HTTPSUpgradeTests: XCTestCase {
    
    func testWhenBloomFilterIsNilThenNoUpgradeURLIsReturned() {
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: nil))
        testee.loadData()
        XCTAssertNil(testee.upgrade(url: URL(string: "http://example.com")!))
    }
    
    func testWhenURLIsHttpsNoUpgradeURLIsReturned() {
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        XCTAssertNil(testee.upgrade(url: URL(string: "https://example.com")!))
    }
    
    func testWhenURLIsHttpAndCanBeUpgradedUpgradeURLIsReturned() {
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        XCTAssertEqual("https://example.com", testee.upgrade(url: URL(string: "http://example.com")!)?.absoluteString)
    }
    
    func testWhenURLIsHttpAndCantBeUpgradedNoUpgradeURLIsReturned() {
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        XCTAssertNil(testee.upgrade(url: URL(string: "http://otherurl.com")!))
    }
    
    func testWhenURLIsInWhiteListThenNoUpgradeUrlIsReturned() {
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter(), hasWhitelistedDomain: true))
        testee.loadData()
        XCTAssertNil(testee.upgrade(url: URL(string: "http://example.com")!))
    }
    
    private func bloomFilter() -> BloomFilterWrapper {
        let filter = BloomFilterWrapper(totalItems: Int32(1000), errorRate: 0.0001)!
        filter.add("example.com")
        return filter
    }
}

private class MockHTTPSUpgradeStore: HTTPSUpgradeStore {
    
    private let httpsBloomFilter: BloomFilterWrapper?
    private let hasWhitelistedDomain: Bool
    
    init(bloomFilter: BloomFilterWrapper?, hasWhitelistedDomain: Bool = false) {
        self.httpsBloomFilter = bloomFilter
        self.hasWhitelistedDomain = hasWhitelistedDomain
    }
    
    func bloomFilter() -> BloomFilterWrapper? {
        return httpsBloomFilter
    }
    
    func bloomFilterSpecification() -> HTTPSTransientBloomFilterSpecification? {
        return nil
    }
    
    func persistBloomFilter(specification: HTTPSTransientBloomFilterSpecification, data: Data) -> Bool {
        return true
    }
    
    func hasWhitelistedDomain(_ domain: String) -> Bool {
        return hasWhitelistedDomain
    }
    
    func persistWhitelist(domains: [String]) {
    }
}
