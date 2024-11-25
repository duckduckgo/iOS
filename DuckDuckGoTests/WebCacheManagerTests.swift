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

// TODO DataStoreIDManager assert new install has nil id for container

class WebCacheManagerTests: XCTestCase {

    let defaults = UserDefaults(suiteName: "Test")!
    let dataStoreIdStore = MockKeyValueStore()

    lazy var cookieStorage = MigratableCookieStorage(userDefaults: defaults)
    lazy var fireproofing = MockFireproofing()
    lazy var dataStoreIdManager = DataStoreIdManager(store: dataStoreIdStore)

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

    // TODO create an abstraction for WKWebsiteDataStore management and pass it into the webcache manager
    @MainActor
    @available(iOS 17, *)
    func test_WhenClearingDataAfterUsingContainer_ThenCookiesAreMigratedAndOldContainersAreRemoved() async {
        fireproofing = MockFireproofing(domains: ["example.com"])

        MigratableCookieStorage.addCookies([
            .make(name: "Test1", value: "Value", domain: "example.com"),
            .make(name: "Test2", value: "Value", domain: ".example.com"),
            .make(name: "Test3", value: "Value", domain: "facebook.com"),
        ], defaults)

        // Setup a new container and add something to it just to make it real
        let uuid = await createContainer()

        var dataStoreIds = await WKWebsiteDataStore.allDataStoreIdentifiers
        XCTAssertEqual(1, dataStoreIds.count)

        // Use the UUID we just created for the store id
        dataStoreIdStore.store = [DataStoreIdManager.Constants.currentWebContainerId.rawValue: uuid.uuidString]
        dataStoreIdManager = DataStoreIdManager(store: dataStoreIdStore)

        let dataStore = WKWebsiteDataStore.default()
        var cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(0, cookies.count)

        let webCacheManager = makeWebCacheManager()
        await webCacheManager.clear(dataStore: dataStore)

        try? await Task.sleep(interval: 0.3)

        cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(2, cookies.count)
        XCTAssertTrue(cookies.contains(where: { $0.domain == "example.com" }))
        XCTAssertTrue(cookies.contains(where: { $0.domain == ".example.com" }))

        dataStoreIds = await WKWebsiteDataStore.allDataStoreIdentifiers
        XCTAssertTrue(dataStoreIds.isEmpty)
    }

    @MainActor
    @available(iOS 17, *)
    func test_WhenClearingData_ThenOldContainersAreRemoved() async {
        _ = await createContainer()
        _ = await createContainer()
        _ = await createContainer()
        _ = await createContainer()
        _ = await createContainer()

        try? await Task.sleep(interval: 0.3)

        var dataStoreIds = await WKWebsiteDataStore.allDataStoreIdentifiers
        XCTAssertEqual(5, dataStoreIds.count)

        await makeWebCacheManager().clear(dataStore: .default())

        try? await Task.sleep(interval: 0.3)

        dataStoreIds = await WKWebsiteDataStore.allDataStoreIdentifiers
        XCTAssertEqual(0, dataStoreIds.count)
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
            dataStoreClearingDelay: 0.01
        )
    }

    @available(iOS 17, *)
    @MainActor private func createContainer() async -> UUID {
        let uuid = UUID()
        let containerStore = WKWebsiteDataStore(forIdentifier: uuid)
        await containerStore.httpCookieStore.setCookie(.make(name: "Not", value: "Used"))
        let cookies = await containerStore.httpCookieStore.allCookies()
        XCTAssertEqual(1, cookies.count)
        return uuid
    }

}
