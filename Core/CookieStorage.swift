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

    struct Constants {
        static let key = "com.duckduckgo.allowedCookies"
    }

    private var userDefaults: UserDefaults

    var cookies: [HTTPCookie] {

        var storedCookies = [HTTPCookie]()
        if let cookies = userDefaults.object(forKey: Constants.key) as? [[String: Any?]] {
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

    public init(userDefaults: UserDefaults = UserDefaults.app) {
        self.userDefaults = userDefaults
    }

    func clear() {
        userDefaults.removeObject(forKey: Constants.key)
        os_log("cleared cookies", log: .generalLog, type: .debug)
    }

}
