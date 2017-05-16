//
//  MiscSetttingsUserDefaults.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 06/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class MiscSettingsUserDefaults {
    
    fileprivate struct Keys {
        static let omniFireOpensNewTab = "com.duckduckgo.miscsettings.omniFireOpensNewTab"
    }
    
    public init() {}

    private func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    public var omniFireOpensNewTab: Bool {
        get {
            return userDefaults().bool(forKey: Keys.omniFireOpensNewTab, defaultValue: true)
        }
        set(newValue) {
            userDefaults().set(newValue, forKey: Keys.omniFireOpensNewTab)
        }
    }
}




