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
        CookieStorage().cookies = []
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

        let initialCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(0, initialCount)

        await defaultStore.httpCookieStore.setCookie(.make(domain: "twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "mobile.twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "fake.mobile.twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".fake.mobile.twitter.com"))

        let loadedCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(5, loadedCount)

        let cookieStore = CookieStorage()
        await WebCacheManager.shared.clear(cookieStorage: cookieStore, logins: logins, dataStoreIdManager: dataStoreIdManager)

        let cookies = await defaultStore.httpCookieStore.allCookies()
        XCTAssertEqual(cookies.count, 0)

        XCTAssertEqual(2, cookieStore.cookies.count)
        XCTAssertTrue(cookieStore.cookies.contains(where: { $0.domain == ".twitter.com" }))
        XCTAssertTrue(cookieStore.cookies.contains(where: { $0.domain == "mobile.twitter.com" }))
    }
    
    @MainActor
    func testWhenRemovingCookieForDomainThenItIsRemovedFromCookieStorage() async {
        let defaultStore = WKWebsiteDataStore.default()
        await defaultStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)

        let initialCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(0, initialCount)

        await defaultStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
        await defaultStore.httpCookieStore.setCookie(.make(domain: "www.example.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".example.com"))

        await WebCacheManager.shared.removeCookies(forDomains: ["www.example.com"], dataStore: WKWebsiteDataStore.current())
        let cookies = await defaultStore.httpCookieStore.allCookies()
        XCTAssertEqual(cookies.count, 0)
    }

    @MainActor
    func testWhenClearedThenCookiesWithParentDomainsAreRetained() async {
        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])

        let defaultStore = WKWebsiteDataStore.default()
        await defaultStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)

        let initialCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(0, initialCount)

        await defaultStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
        await defaultStore.httpCookieStore.setCookie(.make(domain: "example.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".example.com"))

        let cookieStorage = CookieStorage()
        
        await WebCacheManager.shared.clear(cookieStorage: cookieStorage,
                                           logins: logins,
                                           dataStoreIdManager: dataStoreIdManager)
        let cookies = await defaultStore.httpCookieStore.allCookies()

        XCTAssertEqual(cookies.count, 0)
        XCTAssertEqual(cookieStorage.cookies.count, 1)
        XCTAssertEqual(cookieStorage.cookies[0].domain, ".example.com")
    }

    func testWhenClearedThenDDGCookiesAreRetained() async {
        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])
        
        let cookieStore = CookieStorage()
        cookieStore.cookies = [
            .make(domain: "duckduckgo.com"),
            .make(domain: "subdomain.duckduckgo.com"),
        ]
        
        await WebCacheManager.shared.clear(cookieStorage: cookieStore, logins: logins, dataStoreIdManager: dataStoreIdManager)
        
        XCTAssertEqual(cookieStore.cookies.count, 2)
        XCTAssertTrue(cookieStore.cookies.contains(where: { $0.domain == "duckduckgo.com" }))
        XCTAssertTrue(cookieStore.cookies.contains(where: { $0.domain == "subdomain.duckduckgo.com" }))
    }
    
    @MainActor
    func testWhenClearedThenCookiesForLoginsAreRetained() async {
        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])

        let defaultStore = WKWebsiteDataStore.default()
        await defaultStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)

        let initialCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(0, initialCount)

        await defaultStore.httpCookieStore.setCookie(.make(domain: "www.example.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "facebook.com"))

        let loadedCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(2, loadedCount)

        let cookieStore = CookieStorage()
        
        await WebCacheManager.shared.clear(cookieStorage: cookieStore, logins: logins, dataStoreIdManager: dataStoreIdManager)

        let cookies = await defaultStore.httpCookieStore.allCookies()
        XCTAssertEqual(cookies.count, 0)
        
        XCTAssertEqual(1, cookieStore.cookies.count)
        XCTAssertEqual(cookieStore.cookies[0].domain, "www.example.com")
    }
 
    @MainActor
    func testWhenAccessingObservationsDbThenValidDatabasePoolIsReturned() {
        let pool = WebCacheManager.shared.getValidDatabasePool()
        XCTAssertNotNil(pool, "DatabasePool should not be nil")
    }
            
    // MARK: Mocks
    
    class MockPreservedLogins: PreserveLogins {
        
        let domains: [String]
        
        override var allowedDomains: [String] {
            return domains
        }
        
        init(domains: [String]) {
            self.domains = domains
        }
        
    }
    
}
