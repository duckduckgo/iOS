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
import PersistenceTestingUtils

extension HTTPCookie {

    static func make(name: String = "name",
                     value: String = "value",
                     domain: String = "example.com",
                     path: String = "/",
                     policy: HTTPCookieStringPolicy? = nil) -> HTTPCookie {

        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: name,
            .value: value,
            .domain: domain,
            .path: path
        ]

        if policy != nil {
            properties[HTTPCookiePropertyKey.sameSitePolicy] = policy
        }

        return HTTPCookie(properties: properties)!    }

}

class WebCacheManagerTests: XCTestCase {

    let keyValueStore = MockKeyValueStore()

    lazy var cookieStorage = MigratableCookieStorage(store: keyValueStore)
    lazy var fireproofing = MockFireproofing()
    lazy var dataStoreIDManager = DataStoreIDManager(store: keyValueStore)
    let dataStoreCleaner = MockDataStoreCleaner()
    let observationsCleaner = MockObservationsCleaner()

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

    func test_WhenClearingDataAfterUsingContainer_ThenCookiesAreMigratedAndOldContainersAreRemoved() async {
        // Mock having a single container so we can validate cleaning it gets called
        dataStoreCleaner.countContainersReturnValue = 1

        // Mock a data store id to force migration to happen
        keyValueStore.store = [DataStoreIDManager.Constants.currentWebContainerID.rawValue: UUID().uuidString]
        dataStoreIDManager = DataStoreIDManager(store: keyValueStore)

        fireproofing = MockFireproofing(domains: ["example.com"])

        MigratableCookieStorage.addCookies([
            .make(name: "Test1", value: "Value", domain: "example.com"),
            .make(name: "Test2", value: "Value", domain: ".example.com"),
            .make(name: "Test3", value: "Value", domain: "facebook.com"),
        ], keyValueStore)

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

    func test_WhenClearingData_ThenOldContainersAreRemoved() async {
        // Mock existence of 5 containers so we can validate that cleaning it is called even without migrations
        dataStoreCleaner.countContainersReturnValue = 5
        await makeWebCacheManager().clear(dataStore: .default())
        XCTAssertEqual(1, dataStoreCleaner.removeAllContainersAfterDelayCalls.count)
        XCTAssertEqual(5, dataStoreCleaner.removeAllContainersAfterDelayCalls[0])
    }

    func test_WhenClearingData_ThenObservationsDatabaseIsCleared() async {
        XCTAssertEqual(0, observationsCleaner.removeObservationsDataCallCount)
        await makeWebCacheManager().clear(dataStore: .default())
        XCTAssertEqual(1, observationsCleaner.removeObservationsDataCallCount)
    }

    func test_WhenCookiesAreFromPreviousAppWithContainers_ThenTheyAreConsumed() async {

        MigratableCookieStorage.addCookies([
            .make(name: "Test1", value: "Value", domain: "example.com"),
            .make(name: "Test2", value: "Value", domain: ".example.com"),
            .make(name: "Test3", value: "Value", domain: "facebook.com"),
        ], keyValueStore)

        keyValueStore.set(false, forKey: MigratableCookieStorage.Keys.consumed)

        cookieStorage = MigratableCookieStorage(store: keyValueStore)

        let dataStore = await WKWebsiteDataStore.default()
        let httpCookieStore = await dataStore.httpCookieStore
        await makeWebCacheManager().consumeCookies(into: httpCookieStore)

        XCTAssertTrue(self.cookieStorage.isConsumed)
        XCTAssertTrue(self.cookieStorage.cookies.isEmpty)

        let cookies = await httpCookieStore.allCookies()
        XCTAssertEqual(3, cookies.count)
    }

    func test_WhenRemoveCookiesForDomains_ThenUnaffectedLeftBehind() async {
        let dataStore = await WKWebsiteDataStore.default()
        await dataStore.httpCookieStore.setCookie(.make(name: "Test1", value: "Value", domain: "example.com"))
        await dataStore.httpCookieStore.setCookie(.make(name: "Test4", value: "Value", domain: "sample.com"))
        await dataStore.httpCookieStore.setCookie(.make(name: "Test2", value: "Value", domain: ".example.com"))
        await dataStore.httpCookieStore.setCookie(.make(name: "Test3", value: "Value", domain: "facebook.com"))

        var cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(4, cookies.count)

        let webCacheManager = await makeWebCacheManager()
        await webCacheManager.removeCookies(forDomains: ["example.com", "sample.com"], fromDataStore: dataStore)

        cookies = await dataStore.httpCookieStore.allCookies()
        XCTAssertEqual(1, cookies.count)
        XCTAssertTrue(cookies.contains(where: { $0.domain == "facebook.com" }))
    }

    @MainActor
    private func makeWebCacheManager() -> WebCacheManager {
        return WebCacheManager(
            cookieStorage: cookieStorage,
            fireproofing: fireproofing,
            dataStoreIDManager: dataStoreIDManager,
            dataStoreCleaner: dataStoreCleaner,
            observationsCleaner: observationsCleaner
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

class MockObservationsCleaner: ObservationsDataCleaning {

    var removeObservationsDataCallCount = 0

    func removeObservationsData() async {
        removeObservationsDataCallCount += 1
    }

}
