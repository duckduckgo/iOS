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

    private struct Constants {
        static let cookieDomain = "duckduckgo.com"
    }

    private static var allDataTypes: Set<String> {
        return WKWebsiteDataStore.allWebsiteDataTypes()
    }

    private static var dataStore: WKWebsiteDataStore {
        return WKWebsiteDataStore.default()
    }

    public static func consumeCookies() {
        guard #available(iOS 11, *) else { return }

        let cookieStorage = CookieStorage()
        for cookie in cookieStorage.cookies {
            WebCacheManager.dataStore.httpCookieStore.setCookie(cookie)
        }
        cookieStorage.clear()
    }

    /**
     Clears the cache of all data, except duckduckgo cookies
     */
    public static func clear() {
        if #available(iOS 11, *) {
            extractAllowedCookiesThenClear(in: WebCacheManager.dataStore.httpCookieStore)
        } else {
            WebCacheManager.dataStore.removeData(ofTypes: allDataTypes, modifiedSince: Date.distantPast) { }
        }
    }

    @available(iOS 11, *)
    private static func extractAllowedCookiesThenClear(in cookieStore: WKHTTPCookieStore) {
        let cookieStorage = CookieStorage()
        cookieStore.getAllCookies { cookies in
            let cookies = cookies.filter({ $0.domain == Constants.cookieDomain })
            for cookie in cookies {
                cookieStorage.setCookie(cookie)

            }

            DispatchQueue.main.async {
                WebCacheManager.dataStore.removeData(ofTypes: self.allDataTypes, modifiedSince: Date.distantPast) {}
            }
        }
    }

}
