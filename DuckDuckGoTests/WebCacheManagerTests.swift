//
//  WebCacheManagerTests.swift
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
import WebKit
import TestUtils

class WebCacheManagerTests: XCTestCase {

    let defaults = UserDefaults(suiteName: "Test")!
    let dataStoreIdStore = MockKeyValueStore()

    lazy var cookieStorage = MigratableCookieStorage(userDefaults: defaults)
    lazy var fireproofing = MockFireproofing()
    lazy var dataStoreIdManager = DataStoreIdManager(store: dataStoreIdStore)
    let dataStoreCleaner = MockDataStoreCleaner()

    override func setUp() {
        super.setUp()
        defaults.removePersistentDomain(forName: "Test")
    }

    func test_whenNewInstall_ThenUsesDefaultPersistence() async {
        let dataStore = await WKWebsiteDataStore.current()
        let defaultStore = await WKWebsiteDataStore.default()
        XCTAssertTrue(dataStore === defaultStore)
    }

    func test_whenClearingData_ThenCookiesAreRemoved() async {
        let dataStore = await WKWebsiteDataStore.default()
        await dataStore.httpCookieStore.setCookie(.make(name: "Test", value: "Value", domain: "example.com"))

        var cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(1, cookies.count)

        let webCacheManager = await makeWebCacheManager()
        await webCacheManager.clear(dataStore: dataStore)

        cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(0, cookies.count)
    }

    func test_WhenClearingDefaultPersistence_ThenLeaveFireproofedCookies() async {
        fireproofing = MockFireproofing(domains: ["example.com"])

        let dataStore = await WKWebsiteDataStore.default()
        await dataStore.httpCookieStore.setCookie(.make(name: "Test1", value: "Value", domain: "example.com"))
        await dataStore.httpCookieStore.setCookie(.make(name: "Test2", value: "Value", domain: ".example.com"))
        await dataStore.httpCookieStore.setCookie(.make(name: "Test3", value: "Value", domain: "facebook.com"))

        var cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(3, cookies.count)

        let webCacheManager = await makeWebCacheManager()
        await webCacheManager.clear(dataStore: dataStore)

        cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(2, cookies.count)
        XCTAssertTrue(cookies.contains(where: { $0.domain == "example.com" }))
        XCTAssertTrue(cookies.contains(where: { $0.domain == ".example.com" }))
    }

    @available(iOS 17, *)
    func test_WhenClearingDataAfterUsingContainer_ThenCookiesAreMigratedAndOldContainersAreRemoved() async {
        // Mock having a single container so we can validate cleaning it gets called
        dataStoreCleaner.countContainersReturnValue = 1

        // Mock a data store id to force migration to happen
        dataStoreIdStore.store = [DataStoreIdManager.Constants.currentWebContainerId.rawValue: UUID().uuidString]
        dataStoreIdManager = DataStoreIdManager(store: dataStoreIdStore)

        fireproofing = MockFireproofing(domains: ["example.com"])

        MigratableCookieStorage.addCookies([
            .make(name: "Test1", value: "Value", domain: "example.com"),
            .make(name: "Test2", value: "Value", domain: ".example.com"),
            .make(name: "Test3", value: "Value", domain: "facebook.com"),
        ], defaults)

        let dataStore = await WKWebsiteDataStore.default()
        var cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(0, cookies.count)

        let webCacheManager = await makeWebCacheManager()
        await webCacheManager.clear(dataStore: dataStore)

        cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(2, cookies.count)
        XCTAssertTrue(cookies.contains(where: { $0.domain == "example.com" }))
        XCTAssertTrue(cookies.contains(where: { $0.domain == ".example.com" }))

        XCTAssertEqual(1, dataStoreCleaner.removeAllContainersAfterDelayCalls.count)
        XCTAssertEqual(1, dataStoreCleaner.removeAllContainersAfterDelayCalls[0])
    }

    @available(iOS 17, *)
    func test_WhenClearingData_ThenOldContainersAreRemoved() async {
        // Mock existence of 5 containers so we can validate that cleaning it is called even without migrations
        dataStoreCleaner.countContainersReturnValue = 5
        await makeWebCacheManager().clear(dataStore: .default())
        XCTAssertEqual(1, dataStoreCleaner.removeAllContainersAfterDelayCalls.count)
        XCTAssertEqual(5, dataStoreCleaner.removeAllContainersAfterDelayCalls[0])
    }

    /// Temporarily disabled.
    @MainActor
    func x_testWhenAccessingObservationsDbThenValidDatabasePoolIsReturned() {
        let pool = makeWebCacheManager().getValidDatabasePool()
        XCTAssertNotNil(pool, "DatabasePool should not be nil")
    }

    @MainActor
    private func makeWebCacheManager() -> WebCacheManager {
        return WebCacheManager(
            cookieStorage: cookieStorage,
            fireproofing: fireproofing,
            dataStoreIdManager: dataStoreIdManager,
            dataStoreCleaner: dataStoreCleaner
        )
    }
}

class MockDataStoreCleaner: WebsiteDataStoreCleaning {

    var countContainersReturnValue = 0
    var removeAllContainersAfterDelayCalls: [Int] = []

    func countContainers() async -> Int {
        return countContainersReturnValue
    }
    
    func removeAllContainersAfterDelay(previousCount: Int) {
        removeAllContainersAfterDelayCalls.append(previousCount)
    }

}
