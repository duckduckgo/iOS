//
//  HTTPSUpgradeStoreTests.swift
//  UnitTests
//
//  Created by Christopher Brind on 30/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

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
