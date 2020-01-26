//
//  WebCacheManager.swift
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

import WebKit

public protocol WebCacheManagerCookieStore {
    
    func getAllCookies(_ completionHandler: @escaping ([HTTPCookie]) -> Void)
    
    func setCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)?)

}

public protocol WebCacheManagerDataStore {
    
    var cookieStore: WebCacheManagerCookieStore? { get }
    
    func removeAllData(completion: @escaping () -> Void)
    
}

public class WebCacheManager {

    private struct Constants {
        static let cookieDomain = "duckduckgo.com"
    }
    
    public static var shared = WebCacheManager()
    
    private init() { }

    public func consumeCookies(cookieStorage: CookieStorage = CookieStorage(),
                               httpCookieStore: WebCacheManagerCookieStore? = WKWebsiteDataStore.default().cookieStore,
                               completion: @escaping () -> Void) {
        
        guard let httpCookieStore = httpCookieStore else {
            completion()
            return
        }

        let cookies = cookieStorage.cookies
        
        guard !cookies.isEmpty else {
            completion()
            return
        }
        
        let group = DispatchGroup()
                        
        for cookie in cookies {
            group.enter()
            httpCookieStore.setCookie(cookie) {
                group.leave()
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            group.wait()
            
            DispatchQueue.main.async {
                cookieStorage.clear()
                completion()
            }
        }
    }

    public func clear(dataStore: WebCacheManagerDataStore = WKWebsiteDataStore.default(),
                      appCookieStorage: CookieStorage = CookieStorage(),
                      logins: PreserveLogins = PreserveLogins.shared,
                      completion: @escaping () -> Void) {
        extractAllowedCookies(from: dataStore.cookieStore, cookieStorage: appCookieStorage, logins: logins) {
            self.clearAllData(dataStore: dataStore, completion: completion)
        }
    }

    private func clearAllData(dataStore: WebCacheManagerDataStore, completion: @escaping () -> Void) {
        dataStore.removeAllData(completion: completion)
    }
    
    private func extractAllowedCookies(from cookieStore: WebCacheManagerCookieStore?,
                                       cookieStorage: CookieStorage,
                                       logins: PreserveLogins,
                                       completion: @escaping () -> Void) {
        
        guard let cookieStore = cookieStore else {
            completion()
            return
        }
        
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.domain == Constants.cookieDomain || logins.isAllowed(cookieDomain: cookie.domain) {
                    cookieStorage.setCookie(cookie)
                }
            }
            completion()
        }

    }

}

@available(iOS 11, *)
extension WKHTTPCookieStore: WebCacheManagerCookieStore {

}

extension WKWebsiteDataStore: WebCacheManagerDataStore {

    public var cookieStore: WebCacheManagerCookieStore? {
        guard #available(iOS 11, *) else { return nil }
        return self.httpCookieStore
    }

    public func removeAllData(completion: @escaping () -> Void) {
        removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                   modifiedSince: Date.distantPast,
                   completionHandler: completion)
    }

}
