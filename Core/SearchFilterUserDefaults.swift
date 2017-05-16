//
//  SearchFilterUserDefaults.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 15/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class SearchFilterUserDefaults: SearchFilterStore {
    
    private let groupName = "group.com.duckduckgo.searchfilters"
    
    private struct Keys {
        static let safeSearch = "com.duckduckgo.searchfilters.safeSearch"
        static let regionFilter = "com.duckduckgo.searchfilters.regionFilter"
        static let dateFilter = "com.duckduckgo.searchfilters.dateFilter"
    }
    
    public init() {}
    
    private func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
    
    public var safeSearchEnabled: Bool {
        get {
            guard let userDefaults = userDefaults() else { return true }
            return userDefaults.bool(forKey: Keys.safeSearch, defaultValue: true)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.safeSearch)
        }
    }
    
    public var regionFilter: String? {
        get {
            return userDefaults()?.string(forKey: Keys.regionFilter)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.regionFilter)
        }
    }
    
    public var dateFilter: String? {
        get {
            return userDefaults()?.string(forKey: Keys.dateFilter)
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.dateFilter)
        }
    }
}
