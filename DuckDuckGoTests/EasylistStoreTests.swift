//
//  EasylistStoreTests.swift
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

class EasylistStoreTests: XCTestCase {

    override func tearDown() {

        EasylistStore().persistEasylist(data: "".data(using: .utf8)!)
        EasylistStore().persistEasylistPrivacy(data: "".data(using: .utf8)!)

    }

    func testWhenEasylistPrivacyPersistedCacheIsInvalidated() {

        ContentBlockerStringCache().put(name: EasylistStore.CacheNames.easylistPrivacy, value: "hello")

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylistPrivacy(data: value.data(using: .utf8)!)

        XCTAssertNil(ContentBlockerStringCache().get(named: EasylistStore.CacheNames.easylistPrivacy))

    }

    func testWhenEasylistPersistedCacheIsInvalidated() {

        ContentBlockerStringCache().put(name: EasylistStore.CacheNames.easylist, value: "hello")

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylist(data: value.data(using: .utf8)!)

        XCTAssertNil(ContentBlockerStringCache().get(named: EasylistStore.CacheNames.easylist))

    }

    func testWhenEasylistPrivacyPersistedBackslashesAreEscaped() {

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylistPrivacy(data: "\(value)\\".data(using: .utf8)!)
        XCTAssertEqual("\(value)\\\\", store.easylistPrivacy)

    }

    func testWhenEasylistPersistedBackslashesAreEscaped() {

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylist(data: "\(value)\\".data(using: .utf8)!)
        XCTAssertEqual("\(value)\\\\", store.easylist)

    }

    func testWhenEasylistPrivacyPersistedBackticksAreEscaped() {

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylistPrivacy(data: "\(value)`".data(using: .utf8)!)
        XCTAssertEqual("\(value)\\`", store.easylistPrivacy)

    }

    func testWhenEasylistPersistedBackticksAreEscaped() {

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylist(data: "\(value)`".data(using: .utf8)!)
        XCTAssertEqual("\(value)\\`", store.easylist)

    }

    func testWhenEasylistPrivacyPersistedValueIsAvailable() {

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylistPrivacy(data: value.data(using: .utf8)!)
        XCTAssertEqual(value, store.easylistPrivacy)

    }

    func testWhenEasylistPersistedValueIsAvailable() {

        let value = UUID.init().uuidString
        let store = EasylistStore()
        store.persistEasylist(data: value.data(using: .utf8)!)
        XCTAssertEqual(value, store.easylist)

    }

}
