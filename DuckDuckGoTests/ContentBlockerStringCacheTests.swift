//
//  ContentBlockerStringCacheTests.swift
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

class ContentBlockerStringCacheTests: XCTestCase {

    private var testee: ContentBlockerStringCache!
    private var userDefaults: UserDefaults!

    override func setUp() {
        userDefaults = UserDefaults(suiteName: "test")
        userDefaults.removePersistentDomain(forName: "test")
        testee = ContentBlockerStringCache(userDefaults: userDefaults)
    }

    func testWhenItemsAddedAndCacheClearedItemIsNotReturned() {
        testee.put(name: "item", value: "value")
        userDefaults.removePersistentDomain(forName: "test")
        XCTAssertNil(ContentBlockerStringCache(userDefaults: userDefaults).get(named: "item"))
    }

    func testWhenItemAddedDifferentInstanceReturnsIt() {
        let expected = UUID.init().uuidString
        testee.put(name: "uuid", value: expected)
        XCTAssertEqual(expected, ContentBlockerStringCache(userDefaults: userDefaults).get(named: "uuid"))
    }

    func testWhenItemRemovedGetReturnsNil() {
        testee.put(name: "value", value: "some value")
        testee.remove(named: "value")
        XCTAssertNil(testee.get(named: "value"))
    }

    func testWhenAddItemGetReturnsIt() {
        let expected = UUID.init().uuidString
        testee.put(name: "uuid", value: expected)
        XCTAssertEqual(expected, testee.get(named: "uuid"))
    }

    func testWhenGetUnknownItemReturnsNil() {
        XCTAssertNil(testee.get(named: "nonesense"))
    }

}
