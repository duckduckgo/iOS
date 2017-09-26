//
//  StringCacheTests.swift
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

class StringCacheTests: XCTestCase {

    func testWhenItemRemovedGetReturnsNil() {
        let cache = StringCache()
        cache.put(name: "value", value: "some value")
        cache.remove(named: "value")
        XCTAssertNil(cache.get(named: "value"))
    }

    func testWhenAddItemGetReturnsIt() {
        let expected = UUID.init().uuidString
        let cache = StringCache()
        cache.put(name: "uuid", value: expected)
        XCTAssertEqual(expected, cache.get(named: "uuid"))
    }

    func testWhenGetUnknownItemReturnsNil() {
        XCTAssertNil(StringCache().get(named: "nonesense"))
    }

}
