//
//  MigratableCookieStorage.swift
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
import os.log

/// This class was used to store cookies when moving between persistences containers, but now we are clearing the default container, this class is only used for storing cookies that existed previously and need to be migrated.
public class MigratableCookieStorage {

    struct Keys {
        static let allowedCookies = "com.duckduckgo.allowedCookies"
        static let consumed = "com.duckduckgo.consumedCookies"
    }

    private var userDefaults: UserDefaults

    var isConsumed: Bool {
        get {
            return userDefaults.bool(forKey: Keys.consumed, defaultValue: false)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.consumed)
        }
    }

    var cookies: [HTTPCookie] {
        var storedCookies = [HTTPCookie]()
        if let cookies = userDefaults.object(forKey: Keys.allowedCookies) as? [[String: Any?]] {
            for cookieData in cookies {
                var properties = [HTTPCookiePropertyKey: Any]()
                cookieData.forEach({
                    properties[HTTPCookiePropertyKey(rawValue: $0.key)] = $0.value
                })

                if let cookie = HTTPCookie(properties: properties) {
                    Logger.general.debug("read cookie \(cookie.domain) \(cookie.name) \(cookie.value)")
                    storedCookies.append(cookie)
                }
            }
        }

        return storedCookies
    }

    public init(userDefaults: UserDefaults = UserDefaults.app) {
        self.userDefaults = userDefaults
    }

    /// Called when migration is completed to clean up
    func migrationComplete() {
        userDefaults.removeObject(forKey: Keys.allowedCookies)
        userDefaults.removeObject(forKey: Keys.consumed)
    }

}
