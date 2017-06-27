//
//  SearchFilterUserDefaults.swift
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


import Foundation

public class SearchFilterUserDefaults: SearchFilterStore {
    
    private let groupName = "group.com.duckduckgo.searchfilters"
    
    private struct Keys {
        static let safeSearch = "com.duckduckgo.searchfilters.safeSearch"
        static let regionFilter = "com.duckduckgo.searchfilters.regionFilter"
        static let dateFilter = "com.duckduckgo.searchfilters.dateFilter"
    }
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
    
    public init() {}
    
    public var safeSearchEnabled: Bool {
        get {
            guard let userDefaults = userDefaults else { return true }
            return userDefaults.bool(forKey: Keys.safeSearch, defaultValue: true)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.safeSearch)
        }
    }
    
    public var regionFilter: String? {
        get {
            return userDefaults?.string(forKey: Keys.regionFilter)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.regionFilter)
        }
    }
    
    public var dateFilter: String? {
        get {
            return userDefaults?.string(forKey: Keys.dateFilter)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.dateFilter)
        }
    }
}
