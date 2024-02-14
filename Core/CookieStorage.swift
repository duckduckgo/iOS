//
//  CookieStorage.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import Common
import Foundation

public class CookieStorage {

    struct Keys {
        static let allowedCookies = "com.duckduckgo.allowedCookies"
        static let consumed = "com.duckduckgo.consumedCookies"
    }

    private var userDefaults: UserDefaults
    
    var isConsumed: Bool {
        get {
            userDefaults.bool(forKey: Keys.consumed, defaultValue: false)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.consumed)
        }
    }
    
    /// Use the `updateCookies` function rather than the setter which is only visible for testing.
    var cookies: [HTTPCookie] {
        get {
            var storedCookies = [HTTPCookie]()
            if let cookies = userDefaults.object(forKey: Keys.allowedCookies) as? [[String: Any?]] {
                for cookieData in cookies {
                    var properties = [HTTPCookiePropertyKey: Any]()
                    cookieData.forEach({
                        properties[HTTPCookiePropertyKey(rawValue: $0.key)] = $0.value
                    })
                    
                    if let cookie = HTTPCookie(properties: properties) {
                        os_log("read cookie %s %s %s", log: .generalLog, type: .debug, cookie.domain, cookie.name, cookie.value)
                        storedCookies.append(cookie)
                    }
                }
            }
            
            return storedCookies
        }
        
        set {
            var cookies = [[String: Any?]]()
            newValue.forEach { cookie in
                var mappedCookie = [String: Any?]()
                cookie.properties?.forEach {
                    mappedCookie[$0.key.rawValue] = $0.value
                }
                cookies.append(mappedCookie)
            }
            userDefaults.setValue(cookies, forKey: Keys.allowedCookies)
        }

    }

    public init(userDefaults: UserDefaults = UserDefaults.app) {
        self.userDefaults = userDefaults
    }

    enum CookieDomainsOnUpdate {
        case empty
        case match
        case missing
        case different
    }
    
    @discardableResult
    func updateCookies(_ cookies: [HTTPCookie], keepingPreservedLogins preservedLogins: PreserveLogins) -> CookieDomainsOnUpdate {
        isConsumed = false
        
        let persisted = self.cookies
        
        func cookiesByDomain(_ cookies: [HTTPCookie]) -> [String: [HTTPCookie]] {
            var byDomain = [String: [HTTPCookie]]()
            cookies.forEach { cookie in
                var cookies = byDomain[cookie.domain, default: []]
                cookies.append(cookie)
                byDomain[cookie.domain] = cookies
            }
            return byDomain
        }
        
        let updatedCookiesByDomain = cookiesByDomain(cookies)
        var persistedCookiesByDomain = cookiesByDomain(persisted)

        // Do the diagnostics before the dicts get changed.
        let diagnosticResult = evaluateDomains(
            updatedDomains: updatedCookiesByDomain.keys.sorted(),
            persistedDomains: persistedCookiesByDomain.keys.sorted()
        )
        
        updatedCookiesByDomain.keys.forEach {
            persistedCookiesByDomain[$0] = updatedCookiesByDomain[$0]
        }
        
        persistedCookiesByDomain.keys.forEach {
            guard !URL.isDuckDuckGo(domain: $0) else { return } // DDG cookies are for SERP settings only
            
            if !preservedLogins.isAllowed(cookieDomain: $0) {
                persistedCookiesByDomain.removeValue(forKey: $0)
            }
        }

        let now = Date()
        self.cookies = persistedCookiesByDomain.map { $0.value }.joined().compactMap { $0 }
            .filter { $0.expiresDate == nil || $0.expiresDate! > now }
        
        return diagnosticResult
    }
    
    private func evaluateDomains(updatedDomains: [String], persistedDomains: [String]) -> CookieDomainsOnUpdate {
        if persistedDomains.isEmpty {
            return .empty
        } else if updatedDomains.count < persistedDomains.count {
            return .missing
        } else if updatedDomains == persistedDomains {
            return .match
        } else {
            return .different
        }
    }
     
}
