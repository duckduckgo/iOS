//
//  UserDefaultsPropertyWrapper.swift
//  Core
//
//  Created by Christopher Brind on 19/02/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
