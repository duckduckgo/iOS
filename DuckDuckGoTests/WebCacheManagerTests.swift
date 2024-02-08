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

        let initialCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(0, initialCount)

        await defaultStore.httpCookieStore.setCookie(.make(domain: "twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "mobile.twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: "fake.mobile.twitter.com"))
        await defaultStore.httpCookieStore.setCookie(.make(domain: ".fake.mobile.twitter.com"))

        let loadedCount = await defaultStore.httpCookieStore.allCookies().count
        XCTAssertEqual(5, loadedCount)

        await withCheckedContinuation { continuation in
            WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
                continuation.resume()
            }
        }

        let cookies = await defaultStore.httpCookieStore.allCookies()
        XCTAssertEqual(cookies.count, 2)
        XCTAssertTrue(cookies.contains(where: { $0.domain == ".twitter.com" }))
        XCTAssertTrue(cookies.contains(where: { $0.domain == "mobile.twitter.com" }))
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

        await withCheckedContinuation { continuation in
            WebCacheManager.shared.removeCookies(forDomains: ["www.example.com"], dataStore: WKWebsiteDataStore.current()) {
                continuation.resume()
            }
        }
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

        await withCheckedContinuation { continuation in
            WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
                continuation.resume()
            }
        }

        let cookies = await defaultStore.httpCookieStore.allCookies()

        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].domain, ".example.com")
    }

    func testWhenClearedThenDDGCookiesAreRetained() {
        let logins = MockPreservedLogins(domains: [
            "www.example.com"
        ])

        let dataStore = MockDataStore()
        let cookieStore = MockHTTPCookieStore(cookies: [
            .make(domain: "duckduckgo.com"),
            .make(domain: "subdomain.duckduckgo.com")
        ])

        dataStore.cookieStore = cookieStore
        
        let expect = expectation(description: #function)
        WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
        
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

        await withCheckedContinuation { continuation in
            WebCacheManager.shared.clear(logins: logins, dataStoreIdManager: dataStoreIdManager) {
                continuation.resume()
            }
        }

        let cookies = await defaultStore.httpCookieStore.allCookies()
        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies[0].domain, "www.example.com")
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
        
        func legacyClearingRemovingAllDataExceptCookies(completion: @escaping () -> Void) {
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
