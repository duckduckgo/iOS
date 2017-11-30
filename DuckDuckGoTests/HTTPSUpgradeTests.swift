//
//  HTTPSUpgradeTests.swift
//  UnitTests
//
//  Created by Christopher Brind on 30/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class HTTPSUpgradeTests: XCTestCase {

    func testWhenURLIsHttpsNoUpgradeURLIsReturned() {
        let testee = HTTPSUpgrade(persistence: MockHTTPSUpgradePersistence(hasDomain: false))
        XCTAssertNil(testee.upgrade(url: URL(string: "https://www.example.com")!))
    }

    func testWhenURLIsHttpAndCantBeUpgradedNoUpgradeURLIsReturned() {
        let testee = HTTPSUpgrade(persistence: MockHTTPSUpgradePersistence(hasDomain: false))
        XCTAssertNil(testee.upgrade(url: URL(string: "http://www.example.com")!))
    }

    func testWhenURLIsHttpAndCanBeUpgradedReturnsUpgradedURL() {
        let testee = HTTPSUpgrade(persistence: MockHTTPSUpgradePersistence(hasDomain: true))
        XCTAssertEqual(URL(string:"https://www.example.com"), testee.upgrade(url: URL(string:"http://www.example.com")!))
    }

}

fileprivate class MockHTTPSUpgradePersistence: HTTPSUpgradePersistence {

    private let hasDomain: Bool

    init(hasDomain: Bool) {
        self.hasDomain = hasDomain
    }

    func persist(domains: [String], wildcardDomains: [String]) {
    }

    func hasDomain(_ domain: String) -> Bool {
        return hasDomain
    }

}
