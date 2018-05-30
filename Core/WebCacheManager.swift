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

public class WebCacheManager {

    public static var instance = WebCacheManager()
    
    private struct Constants {
        static let cookieDomain = "duckduckgo.com"
    }
    
    private var allDataTypes: Set<String> {
        return WKWebsiteDataStore.allWebsiteDataTypes()
    }
    
    private var dataStore: WKWebsiteDataStore {
        return WKWebsiteDataStore.default()
    }
    
    private init() {
    }

    public func consumeCookies(intoDataStore dataStore: WKWebsiteDataStore) {
        if #available(iOS 11, *) {
            
            let storage = HTTPCookieStorage.shared
            for cookie in storage.cookies ?? [] {
                Logger.log(items: "consuming cookie", cookie.domain, cookie.name, cookie.value)
                dataStore.httpCookieStore.setCookie(cookie)
                storage.deleteCookie(cookie)
            }
            
        }
    }
    
    /**
     Clears the cache of all data, except duckduckgo cookies
     */
    public func clear() {
        if #available(iOS 11, *) {
            extractAllowedCookies(in: dataStore.httpCookieStore)
        }
        
        dataStore.removeData(ofTypes: allDataTypes, modifiedSince: Date.distantPast) {}
    }

    @available(iOS 11, *)
    func extractAllowedCookies(in cookieStore: WKHTTPCookieStore) {
        
        cookieStore.getAllCookies { cookies in
            let cookies = cookies.filter({ $0.domain == Constants.cookieDomain })
            let storage = HTTPCookieStorage.shared
            for cookie in cookies {
                Logger.log(items: "storing cookie", cookie.domain, cookie.name, cookie.value)
                storage.setCookie(cookie)
            }
        }
        
    }
    
}
