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

import Foundation
import WebKit
import os.log

public class CookieStorage {

    struct Constants {
        static let key = "com.duckduckgo.allowedCookies"
        static let container = "com.duckduckgo.containerCookies"
    }

    private var userDefaults: UserDefaults
    private var containerName: String?

    var cookies: [HTTPCookie] {

        var storedCookies = [HTTPCookie]()
        
        var defaultsKey = Constants.key
        if let containerName = containerName {
            defaultsKey = Constants.container + ".\(containerName)"
        }
        
        if let cookies = userDefaults.object(forKey: defaultsKey) as? [[String: Any?]] {
            for cookieData in cookies {
                var properties = [HTTPCookiePropertyKey: Any]()
                cookieData.forEach({
                    properties[HTTPCookiePropertyKey(rawValue: $0.key)] = $0.value
                })

                if let cookie = HTTPCookie(properties: properties) {
                    os_log("read cookie %s %s %s", log: generalLog, type: .debug, cookie.domain, cookie.name, cookie.value)
                    storedCookies.append(cookie)
                }
            }
        }

        return storedCookies
    }

    public init(userDefaults: UserDefaults = UserDefaults.standard,
                containerName: String? = nil) {
        self.userDefaults = userDefaults
        self.containerName = containerName
    }

    func clear() {
        userDefaults.removeObject(forKey: Constants.key)
        os_log("cleared cookies", log: generalLog, type: .debug)
    }
    
    func storeCookies(forStore store: WKWebsiteDataStore, containerName: String, completion: (() -> Void)?) {
        guard let cookieStore = store.cookieStore else { return }
        cookieStore.getAllCookies { cookies in
            var storedCookies = [[String: Any]]()
            for cookie in cookies {
                var properties = [String: Any]()
                cookie.properties?.forEach {
                    properties[$0.key.rawValue] = $0.value
                }
                storedCookies.append(properties)
            }
            
            UserDefaults.standard.set(storedCookies, forKey: Constants.container + ".\(containerName)")
            
            completion?()
        }
    }

}
