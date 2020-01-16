//
//  WebCacheManagerTests.swift
//  UnitTests
//
//  Created by Chris Brind on 15/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class WebCacheManagerTests: XCTestCase {

    func testWhenConsumeIsCalledThenCompletionIsCalled() {
        let cookieStorage = MockCookieStorage()
        cookieStorage.setCookie(HTTPCookie.make())
        
        let httpCookieStore = MockHTTPCookieStore()
        
        let expect = expectation(description: #function)
        WebCacheManager.shared.consumeCookies(cookieStorage: cookieStorage, httpCookieStore: httpCookieStore) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
        
        XCTAssertTrue(cookieStorage.cookies.isEmpty)
        XCTAssertEqual(httpCookieStore.cookies.count, 1)
    }
    
    func testWhenClearIsCalledThenCompletionIsCalled() {
        let dataStore = MockDataStore()
        let storedLogins = MockStoredLogins()
        
        let expect = expectation(description: #function)
        WebCacheManager.shared.clear(dataStore: dataStore, storedLogins: storedLogins) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
        
        XCTAssertEqual(dataStore.removeAllDataCalledCount, 1)
    }
            
    // MARK: Mocks
    
    class MockDataStore: WebCacheManagerDataStore {
        
        var removeAllDataCalledCount = 0
        
        var cookieStore: WebCacheManagerCookieStore?
        
        func removeAllData(completion: @escaping () -> Void) {
            removeAllDataCalledCount += 1
            completion()
        }
        
    }
    
    class MockStoredLogins: StoredLogins {
        
    }
    
    class MockHTTPCookieStore: WebCacheManagerCookieStore {
        
        var cookies = [HTTPCookie]()
        
        func getAllCookies(_ completionHandler: @escaping ([HTTPCookie]) -> Void) {
            completionHandler(cookies)
        }
        
        func setCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)?) {
            cookies.append(cookie)
            completionHandler?()
        }
                
    }
    
    class MockCookieStorage: CookieStorage {
        
        convenience init() {
            let userDefaults = UserDefaults(suiteName: "test")!
            userDefaults.removePersistentDomain(forName: "test")
            self.init(userDefaults: userDefaults)
        }
        
    }

}
