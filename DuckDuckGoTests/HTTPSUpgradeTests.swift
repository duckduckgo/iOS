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
        XCTAssertEqual(URL(string: "https://www.example.com"), testee.upgrade(url: URL(string: "http://www.example.com")!))
    }

}

private class MockHTTPSUpgradePersistence: HTTPSUpgradePersistence {

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
