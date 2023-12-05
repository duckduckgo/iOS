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

class WebCacheManagerTests: XCTestCase {
    
    let dataStoreIdManager = DataStoreIdManager()

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: UserDefaultsWrapper<Any>.Key.webContainerId.rawValue)
        if #available(iOS 17, *) {
            WKWebsiteDataStore.fetchAllDataStoreIdentifiers { uuids in
                uuids.forEach {
                    WKWebsiteDataStore.remove(forIdentifier: $0, completionHandler: { _ in })
                }
            }
        }
    }

    @available(iOS 17, *)
    @MainActor
    func testWhenCookiesHaveSubDomainsOnSubDomainsAndWidlcardsThenOnlyMatchingCookiesRetained() async throws {
        let logins = MockPreservedLogins(domains: [
            "mobile.twitter.com"
        ])

        let defaultStore = WKWebsiteDataStore.default()
        await defaultStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
        await defaultStore.httpCookieStore.setCookie(.make(domain: "twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "mobile.twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "fake.mobile.twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".fake.mobile.twitter.com"))

        let cookieCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(5, cookieCount)

        await withCheckedContinuation { continuation in
            WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
                continuation.resume()
            }
        }

        let remainingCookieCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(2, remainingCookieCount)

        try await Task.sleep(interval: 1)

        if let id = self.dataStoreIdManager.id {
            let store = WKWebsiteDataStore(forIdentifier: id)
            let cookies = await store.httpCookieStore.allCookies()
            XCTAssertEqual(cookies.count, 2)
            XCTAssertEqual(cookies[0].domain, ".twitter.com")
            XCTAssertEqual(cookies[1].domain, "mobile.twitter.com")
        } else {
            XCTFail("No container id")
        }
    }
    
    func testWhenRemovingCookieForDomainThenItIsRemovedFromCookieStorage() {

        let dataStore = MockDataStore()
        let cookieStore = MockHTTPCookieStore(cookies: [
            .make(domain: "www.example.com"),
            .make(domain: ".example.com")
        ])
        dataStore.cookieStore = cookieStore
        let expect = expectation(description: #function)
        WebCacheManager.shared.removeCookies(forDomains: ["www.example.com"], dataStore: dataStore) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10.0)
        
        XCTAssertEqual(cookieStore.cookies.count, 0)
    }

    func testWhenClearedThenCookiesWithParentDomainsAreRetained() {

        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])

        let dataStore = MockDataStore()
        let cookieStore = MockHTTPCookieStore(cookies: [
            .make(domain: ".example.com"),
            .make(domain: "facebook.com")
        ])

        dataStore.cookieStore = cookieStore

        let expect = expectation(description: #function)
        WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10.0)

        XCTAssertEqual(cookieStore.cookies.count, 1)
        XCTAssertEqual(cookieStore.cookies[0].domain, ".example.com")
        
    }

    func testWhenClearedThenDDGCookiesAreRetained() {
        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])

        let dataStore = MockDataStore()
        let cookieStore = MockHTTPCookieStore(cookies: [
            .make(domain: "duckduckgo.com")
        ])

        dataStore.cookieStore = cookieStore
        
        let expect = expectation(description: #function)
        WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
        
        XCTAssertEqual(cookieStore.cookies.count, 1)
        XCTAssertEqual(cookieStore.cookies[0].domain, "duckduckgo.com")
    }
    
    func testWhenClearedThenCookiesForLoginsAreRetained() {
        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])

        let dataStore = MockDataStore()
        let cookieStore = MockHTTPCookieStore(cookies: [
            .make(domain: "www.example.com"),
            .make(domain: "facebook.com")
        ])

        dataStore.cookieStore = cookieStore
        
        let expect = expectation(description: #function)
        WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10.0)
        
        XCTAssertEqual(cookieStore.cookies.count, 1)
        XCTAssertEqual(cookieStore.cookies[0].domain, "www.example.com")

    }
    
    func testWhenClearIsCalledThenCompletionIsCalled() {
        let dataStore = MockDataStore()
        let logins = MockPreservedLogins(domains: [])
        
        let expect = expectation(description: #function)
        WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
        
        XCTAssertEqual(dataStore.removeAllDataCalledCount, 1)
    }

    func testWhenAccessingObservationsDbThenValidDatabasePoolIsReturned() {
        let pool = WebCacheManager.shared.getValidDatabasePool()
        XCTAssertNotNil(pool, "DatabasePool should not be nil")
    }
            
    // MARK: Mocks
    
    class MockDataStore: WebCacheManagerDataStore {

        func preservedCookies(_ preservedLogins: Core.PreserveLogins) async -> [HTTPCookie] {
            []
        }

        var removeAllDataCalledCount = 0
        
        var cookieStore: WebCacheManagerCookieStore?
        
        func removeAllDataExceptCookies(completion: @escaping () -> Void) {
            removeAllDataCalledCount += 1
            completion()
        }
        
    }
    
    class MockPreservedLogins: PreserveLogins {
        
        let domains: [String]
        
        override var allowedDomains: [String] {
            return domains
        }
        
        init(domains: [String]) {
            self.domains = domains
        }
        
    }
    
    class MockHTTPCookieStore: WebCacheManagerCookieStore {

        var cookies: [HTTPCookie]
        
        init(cookies: [HTTPCookie] = []) {
            self.cookies = cookies
        }
        
        func getAllCookies(_ completionHandler: @escaping ([HTTPCookie]) -> Void) {
            completionHandler(cookies)
        }
        
        func setCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)?) {
            cookies.append(cookie)
            completionHandler?()
        }
        
        func delete(_ cookie: HTTPCookie, completionHandler: (() -> Void)?) {
            cookies.removeAll { $0 == cookie }
            completionHandler?()
        }
                
    }

}
