//
//  DisconnectMeStoreTests.swift
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

class DisconnectMeStoreTests: XCTestCase {

    var trackerData: Data!
    var cache: ContentBlockerStringCache!
    var testee: DisconnectMeStore!

    let defaultJsValue = "{\n\n}"

    override func setUp() {
        trackerData = JsonTestDataLoader().fromJsonFile("MockFiles/disconnect.json")
        cache = ContentBlockerStringCache()
        testee = DisconnectMeStore()
        clearAll()
    }

    override func tearDown() {
        clearAll()
    }

    func clearAll() {
        try? testee.persist(data: "".data(using: .utf8)!)
        try? FileManager.default.removeItem(at: DisconnectMeStore.persistenceLocation)
    }

    func testWhenItemsAreInAllowedListTheyAppearInAllowedJson() {
        try? testee.persist(data: trackerData)
        XCTAssertFalse(testee.allowedTrackersJson.contains("99anothersocialurl.com"))
        XCTAssertTrue(testee.allowedTrackersJson.contains("acontenturl.com"))
    }

    func testWhenItemsAreInBannedListTheyAppearInBannedJson() {
        try? testee.persist(data: trackerData)
        XCTAssertTrue(testee.bannedTrackersJson.contains("99anothersocialurl.com"))
        XCTAssertFalse(testee.bannedTrackersJson.contains("acontenturl.com"))
    }

    func testWhenTrackersNotPersistedThenHasDataIsFalse() {
        clearAll()
        XCTAssertFalse(testee.hasData)
    }

    func testWhenTrackersPersistedThenHasDataIsTrue() {
        try? testee.persist(data: trackerData)
        XCTAssertTrue(testee.hasData)
    }

    func testWhenNewDisconnectDataIsPersistedJsBannedCacheIsInvalidated() {
        cache.put(name: DisconnectMeStore.CacheKeys.disconnectJsonBanned, value: "someText")
        try? testee.persist(data: trackerData)
        XCTAssertNil(cache.get(named: DisconnectMeStore.CacheKeys.disconnectJsonBanned))
    }

    func testWhenNewDisconnectDataIsPersistedJsAllowedCacheIsInvalidated() {
        cache.put(name: DisconnectMeStore.CacheKeys.disconnectJsonAllowed, value: "someText")
        try? testee.persist(data: trackerData)
        XCTAssertNil(cache.get(named: DisconnectMeStore.CacheKeys.disconnectJsonAllowed))
    }

    func testWhenBannedJsDoesNotHaveACachedValueThenComputedValueIsReturned() {
        try? testee.persist(data: trackerData)
        let result = testee.bannedTrackersJson
        XCTAssertNotNil(result)
        XCTAssertNotEqual(defaultJsValue, result)
    }

    func testWhenAllowedJsDoesNotHaveACachedValueThenComputedValueIsReturned() {
        try? testee.persist(data: trackerData)
        let result = testee.allowedTrackersJson
        XCTAssertNotNil(result)
        XCTAssertNotEqual(defaultJsValue, result)
    }

    func testWhenBannedJsDoesNotHaveACachedValueAndThereIsNoDataForComputationThenDefaultValueIsReturned() {
        let result = testee.bannedTrackersJson
        XCTAssertEqual(defaultJsValue, result)
    }

    func testWhenAllowedJsDoesNotHaveACachedValueAndThereIsNoDataForComputationThenDefaultValueIsReturned() {
        let result = testee.allowedTrackersJson
        XCTAssertEqual( defaultJsValue, result)
    }

    func testWhenNetworkNameAndCategoryExistsForUppercasedDomainTheyAreReturned() {
        try? testee.persist(data: trackerData)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "99asocialurl.com".uppercased())
        XCTAssertEqual("asocialurl.com", nameAndCategory.networkName)
        XCTAssertEqual("Social", nameAndCategory.category)
    }
    
    func testWhenNetworkNameAndCategoryExistsForDomainTheyAreReturned() {
        try? testee.persist(data: trackerData)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "99asocialurl.com")
        XCTAssertEqual("asocialurl.com", nameAndCategory.networkName)
        XCTAssertEqual("Social", nameAndCategory.category)
    }
    
}
