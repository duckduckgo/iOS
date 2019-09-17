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

@testable import Core

class HTTPSUpgradeTests: XCTestCase {
    
    let host = AppUrls().httpsLookupServiceUrl(forPartialHost: "").host!

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenURLIsHttpsThenShouldUpgradeResultIsFalse() {
        let expect = expectation(description: "Https url should not be upgraded")
        let url = URL(string: "https://locallyUpgradable.url")!
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsInWhiteListThenShouldUpgradeResultIsFalse() {
        
        let expect = expectation(description: "Http url in whitelist should not be upgraded")
        let url = URL(string: "http://whitelisted.url")!
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsHttpAndCanBeUpgradedLocallyThenShouldUpgradeIsTrue() {
        let expect = expectation(description: "Http url in local list should be upgraded")
        let url = URL(string: "http://locallyUpgradable.url")!

        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertTrue(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenURLIsHttpAndCannotBeUpgradedLocallyButCanBeUpgradedByServiceThenShouldUpgradeIsTrue() {
        let expect = expectation(description: "Http url not in local but in service list should be upgraded")
        let url = URL(string: "http://service.url")!
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.serviceResponseJson(), status: 200, headers: nil)
        }

        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertTrue(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsHttpAndCannotBeUpgradedLocallyAndCannotBeUpgradedByServiceThenShouldUpgradeIsFalse() {
        let expect = expectation(description: "Http url not in local or service list should not be upgraded")
        let url = URL(string: "http://unknown.url")!
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.serviceResponseJson(), status: 200, headers: nil)
        }

        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenURLIsHttpAndCannotBeUpgradedLocallyAndServiceRequestFailsThenShouldUpgradeIsFalse() {
        let expect = expectation(description: "When service request fails http url should not be upgraded")
        let url = URL(string: "http://service.url")!
        stub(condition: isHost(host)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.loadData()
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
        
    func testWhenBloomFilterIsNotLoadedAndUrlIsInServiceListThenShouldUpgradeIsTrue() {
        let expect = expectation(description: "Http url in service list should upgrade")
        let url = URL(string: "http://service.url")!
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.serviceResponseJson(), status: 200, headers: nil)
        }
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.isUgradeable(url: url) { result in
            XCTAssertTrue(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenBloomFilterIsNotLoadedAndUrlNotInServiceListThenShouldUpgradeIsFalse() {
        let expect = expectation(description: "Http url that cannot be checked locally and not in service list should not upgrade")
        let url = URL(string: "https://locallyUpgradable.url")!
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.serviceResponseJson(), status: 200, headers: nil)
        }
        
        let testee = HTTPSUpgrade(store: MockHTTPSUpgradeStore(bloomFilter: bloomFilter()))
        testee.isUgradeable(url: url) { result in
            XCTAssertFalse(result)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    private func bloomFilter() -> BloomFilterWrapper {
        let filter = BloomFilterWrapper(totalItems: Int32(1000), errorRate: 0.0001)!
        filter.add("locallyUpgradable.url")
        filter.add("whitelisted.url")
        return filter
    }
    
    func serviceResponseJson() -> String {
        return OHPathForFile("MockFiles/https_service.json", type(of: self))!
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
    
    func hasWhitelistedDomain(_ domain: String) -> Bool {
        return domain == "whitelisted.url"
    }
    
    func persistWhitelist(domains: [String]) -> Bool {
        return true
    }
}
