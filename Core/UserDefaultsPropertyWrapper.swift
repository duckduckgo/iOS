//
//  UserDefaultsPropertyWrapper.swift
//  Core
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

import Foundation

// Inspired by https://swiftsenpai.com/swift/create-the-perfect-userdefaults-wrapper-using-property-wrapper/

@propertyWrapper
public struct UserDefaultsWrapper<T: Codable> {

    public enum Key: String {

        case layout = "com.duckduckgo.ios.home.layout"
        case favorites = "com.duckduckgo.ios.home.favorites"
        case keyboardOnNewTab = "com.duckduckgo.ios.keyboard.newtab"
        case keyboardOnAppLaunch = "com.duckduckgo.ios.keyboard.applaunch"

    }

    private let key: Key
    private let defaultValue: T

    public init(key: Key, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
                return defaultValue
            }

            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key.rawValue)
        }
    }
}
