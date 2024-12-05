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
import Persistence

/// This class was used to store cookies when moving between persistences containers, but now we are clearing the default container, this class is only used for storing cookies that existed previously and need to be migrated.
public class MigratableCookieStorage {

    struct Keys {
        static let allowedCookies = "com.duckduckgo.allowedCookies"
        static let consumed = "com.duckduckgo.consumedCookies"
    }

    private var keyValueStore: KeyValueStoring

    var isConsumed: Bool {
        // The default is now true because if this key does not exist then there are no
        //  cookies to consume as they have been migrated.
        // Nothing sets this to false explicitly now.  If the stored value is false then there
        //  are cookies from a previous version of the app which still need to be migrated. This
        //  could happen if the user hit the fire button and then an update happened
        //  before they browsed again.
        return (keyValueStore.object(forKey: Keys.consumed) as? Bool) ?? true
    }

    var cookies: [HTTPCookie] {
        var storedCookies = [HTTPCookie]()
        if let cookies = keyValueStore.object(forKey: Keys.allowedCookies) as? [[String: Any?]] {
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

    public init(store: KeyValueStoring = UserDefaults.app) {
        self.keyValueStore = store
    }

    /// Called after consuming cookies but migration has not happened.
    /// This can happen in the following flow
    /// * User presses fire button on container based app and then backgrounds it/switches to another app
    /// * Installs update to this version of the app without using the browser
    /// * Starts browsing
    func setConsumed() {
        resetStore()
    }

    /// Called when migration is completed to clean up
    func migrationComplete() {
        resetStore()
    }

    private func resetStore() {
        keyValueStore.removeObject(forKey: Keys.allowedCookies)
        keyValueStore.removeObject(forKey: Keys.consumed)
    }

}
