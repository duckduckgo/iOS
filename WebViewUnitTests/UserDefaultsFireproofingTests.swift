//
//  UserDefaultsFireproofingTests.swift
//  UnitTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
@testable import Subscription

// TODO: More broad shared TestUtils
extension UserDefaultsWrapper {

    public static func clearAll() {
        Key.allCases.forEach { key in
            UserDefaults.app.removeObject(forKey: key.rawValue)
        }
    }
}

extension XCTestCase {

    func temporaryUserDefaultSuite(with filePath: String) -> String {
        guard let lastPathComponent = NSURL(fileURLWithPath: filePath).lastPathComponent else {
            fatalError("Path should have a last path component")
        }

        do {
            let temporaryDirectory = try FileManager.default.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: FileManager.default.temporaryDirectory,
                create: true
            )

            return "\(temporaryDirectory)\(lastPathComponent)"
        } catch {
            fatalError("temporary directory should always be created")
        }
    }

    func setupUserDefault(with path: String) {
        let tmpPath = temporaryUserDefaultSuite(with: path)
        UserDefaults.app.removePersistentDomain(forName: tmpPath)
        UserDefaults.app = UserDefaults(suiteName: tmpPath)!
    }
}

class UserDefaultsFireproofingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupUserDefault(with: #file)
        UserDefaultsWrapper<Any>.clearAll()
    }
    
    func testWhenAllowedDomainsContainsFireproofedDomainThenReturnsTrue() {
        let fireproofing = UserDefaultsFireproofing()
        XCTAssertFalse(fireproofing.isAllowed(fireproofDomain: "example.com"))
        fireproofing.addToAllowed(domain: "example.com")
        XCTAssertTrue(fireproofing.isAllowed(fireproofDomain: "example.com"))
    }

    func testAllowedCookieDomains() {
        let fireproofing = UserDefaultsFireproofing()
        XCTAssertFalse(fireproofing.isAllowed(fireproofDomain: "example.com"))
        fireproofing.addToAllowed(domain: "example.com")
        XCTAssertTrue(fireproofing.isAllowed(cookieDomain: ".example.com"))
        XCTAssertFalse(fireproofing.isAllowed(cookieDomain: "subdomain.example.com"))
        XCTAssertFalse(fireproofing.isAllowed(cookieDomain: ".subdomain.example.com"))
    }

    func testWhenNewThenAllowedDomainsIsEmpty() {
        let fireproofing = UserDefaultsFireproofing()
        XCTAssertTrue(fireproofing.allowedDomains.isEmpty)
    }

    func testDuckDuckGoIsFireproofed() {
        let fireproofing = UserDefaultsFireproofing()
        XCTAssertTrue(fireproofing.isAllowed(fireproofDomain: "duckduckgo.com"))
        XCTAssertTrue(fireproofing.isAllowed(cookieDomain: "duckduckgo.com"))
        XCTAssertTrue(fireproofing.isAllowed(cookieDomain: SubscriptionCookieManager.cookieDomain))
        XCTAssertFalse(fireproofing.isAllowed(cookieDomain: "test.duckduckgo.com"))
    }

}
