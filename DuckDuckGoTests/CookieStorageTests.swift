//
//  CookieStorageTests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import WebKit
import XCTest
@testable import Core

class CookieStorageTests: XCTestCase {

    var testee: CookieStorage!
    let testGroupName = "test"
    
    var userDefaults: UserDefaults {
        return UserDefaults(suiteName: testGroupName)!
    }
    
    override func setUp() {
        userDefaults.removePersistentDomain(forName: testGroupName)
        testee = CookieStorage(userDefaults: userDefaults)
    }

    func testWhenMultipleCookiesAreSetThenClearCookiesOnNewInstanceClearsAll() {
        testee.setCookie(cookie("name", "value"))
        testee.setCookie(cookie("name2", "value2"))
        testee = CookieStorage(userDefaults: userDefaults)
        testee.clear()
        XCTAssertTrue(testee.cookies.isEmpty)
    }

    func testWhenMultipleCookiesAreSetBetweenInstancesThenCookiesCountMatches() {
        testee.setCookie(cookie("name", "value"))
        testee = CookieStorage(userDefaults: userDefaults)
        testee.setCookie(cookie("name2", "value2"))
        XCTAssertEqual(testee.cookies.count, 2)
    }

    func testWhenMultipleCookieIsSetThenClearRemovesIt() {
        testee.setCookie(cookie("name", "value"))
        testee.clear()
        XCTAssertTrue(testee.cookies.isEmpty)
    }

    func testWhenMultipleCookiesAreSetThenCookiesCountMatches() {
        testee.setCookie(cookie("name", "value"))
        testee.setCookie(cookie("name2", "value2"))
        XCTAssertEqual(testee.cookies.count, 2)
    }
    
    func testWhenCookieIsSetThenCookiesContainsIt() {
        testee.setCookie(cookie("name", "value"))
        
        XCTAssertEqual(testee.cookies.count, 1)
        XCTAssertEqual(testee.cookies[0].name, "name")
        XCTAssertEqual(testee.cookies[0].value, "value")

    }
    
    func testWhenNewThenCookiesIsEmpty() {
        XCTAssertTrue(testee.cookies.isEmpty)
    }
    
    private func cookie(_ name: String, _ value: String) -> HTTPCookie {
        return HTTPCookie(properties: [.name: name, .value: value, .path: "/", .domain: "example.com"])!
    }
    
}
