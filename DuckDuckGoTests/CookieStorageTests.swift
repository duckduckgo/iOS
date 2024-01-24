//
//  CookieStorageTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import WebKit

public class CookieStorageTests: XCTestCase {
    
    var storage: CookieStorage!
    
    // This is updated by the `make` function which preserves any cookies added as part of this test
    let logins = PreserveLogins.shared
    
    static let userDefaultsSuiteName = "test"
    
    public override func setUp() {
        super.setUp()
        let defaults = UserDefaults(suiteName: Self.userDefaultsSuiteName)!
        defaults.removePersistentDomain(forName: Self.userDefaultsSuiteName)
        storage = CookieStorage(userDefaults: defaults)
        logins.clearAll()
    }

    func testWhenUpdatedThenDuckDuckGoCookiesAreNotRemoved() {
        storage.updateCookies([
            make("duckduckgo.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(1, storage.cookies.count)

        storage.updateCookies([
            make("test.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(2, storage.cookies.count)

    }
    
    func testWhenUpdatedThenCookiesWithFutureExpirationAreNotRemoved() {
        storage.updateCookies([
            make("test.com", name: "x", value: "1", expires: .distantFuture),
        ], keepingPreservedLogins: logins)

        storage.updateCookies([
            make("example.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(2, storage.cookies.count)
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "test.com" }))
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "example.com" }))

    }
    
    func testWhenUpdatingThenExistingExpiredCookiesAreRemoved() {
        storage.cookies = [
            make("test.com", name: "x", value: "1", expires: Date(timeIntervalSinceNow: -100)),
        ]
        XCTAssertEqual(1, storage.cookies.count)

        storage.updateCookies([
            make("example.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(1, storage.cookies.count)
        XCTAssertFalse(storage.cookies.contains(where: { $0.domain == "test.com" }))
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "example.com" }))

    }
    
    func testWhenExpiredCookieIsAddedThenItIsNotPersisted() {

        storage.updateCookies([
            make("example.com", name: "x", value: "1", expires: Date(timeIntervalSinceNow: -100)),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(0, storage.cookies.count)

    }
    
    func testWhenUpdatedThenNoLongerPreservedDomainsAreCleared() {
        storage.updateCookies([
            make("test.com", name: "x", value: "1"),
            make("example.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)

        logins.remove(domain: "test.com")
        
        storage.updateCookies([
            make("example.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)
        
        XCTAssertEqual(1, storage.cookies.count)
        XCTAssertFalse(storage.cookies.contains(where: { $0.domain == "test.com" }))
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "example.com" }))
    }
    
    func testWhenStorageInitialiedThenItIsEmptyAndConsumedIsFalse() {
        XCTAssertEqual(0, storage.cookies.count)
        XCTAssertEqual(false, storage.isConsumed)
    }
    
    func testWhenStorageIsUpdatedThenConsumedIsResetToFalse() {
        storage.isConsumed = true
        XCTAssertTrue(storage.isConsumed)
        storage.updateCookies([
            make("test.com", name: "x", value: "1")
        ], keepingPreservedLogins: logins)
        XCTAssertFalse(storage.isConsumed)
    }
    
    func testWhenStorageIsReinstanciatedThenUsesStoredData() {
        storage.updateCookies([
            make("test.com", name: "x", value: "1")
        ], keepingPreservedLogins: logins)
        storage.isConsumed = true

        let otherStorage = CookieStorage(userDefaults: UserDefaults(suiteName: Self.userDefaultsSuiteName)!)
        XCTAssertEqual(1, otherStorage.cookies.count)
        XCTAssertTrue(otherStorage.isConsumed)
    }
     
    func testWhenStorageIsUpdatedThenUpdatingAddsNewCookies() {
        storage.updateCookies([
            make("test.com", name: "x", value: "1")
        ], keepingPreservedLogins: logins)
        XCTAssertEqual(1, storage.cookies.count)
    }

    func testWhenStorageIsUpdatedThenExistingCookiesAreUnaffected() {
        storage.updateCookies([
            make("test.com", name: "x", value: "1"),
            make("example.com", name: "x", value: "1"),
        ], keepingPreservedLogins: logins)
        
        storage.updateCookies([
            make("example.com", name: "x", value: "2"),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(2, storage.cookies.count)
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "test.com" && $0.name == "x" && $0.value == "1" }))
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "example.com" && $0.name == "x" && $0.value == "2" }))
    }

    func testWhenStorageHasMatchingDOmainThenUpdatingReplacesCookies() {
        storage.updateCookies([
            make("test.com", name: "x", value: "1")
        ], keepingPreservedLogins: logins)

        storage.updateCookies([
            make("test.com", name: "x", value: "2"),
            make("test.com", name: "y", value: "3"),
        ], keepingPreservedLogins: logins)

        XCTAssertEqual(2, storage.cookies.count)
        XCTAssertFalse(storage.cookies.contains(where: { $0.domain == "test.com" && $0.name == "x" && $0.value == "1" }))
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "test.com" && $0.name == "x" && $0.value == "2" }))
        XCTAssertTrue(storage.cookies.contains(where: { $0.domain == "test.com" && $0.name == "y" && $0.value == "3" }))
    }
    
    func make(_ domain: String, name: String, value: String, expires: Date? = nil) -> HTTPCookie {
        logins.addToAllowed(domain: domain)
        return HTTPCookie(properties: [
            .domain: domain,
            .name: name,
            .value: value,
            .path: "/",
            .expires: expires as Any
        ])!
    }
    
}
