//
//  ContentBlockerConfigurationUserDefaults.swift
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

public class ContentBlockerConfigurationUserDefaults: ContentBlockerConfigurationStore {
    
    private let groupName = "group.com.duckduckgo.contentblocker"
    
    private struct Keys {
        static let advertising = "com.duckduckgo.contentblocker.advertising"
        static let analytics = "com.duckduckgo.contentblocker.analytics"
        static let social = "com.duckduckgo.contentblocker.social"
    }
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }

    public init() {}
    
    public var blockAdvertisers: Bool {
        get {
            guard let userDefaults = userDefaults else { return true }
            return userDefaults.bool(forKey: Keys.advertising, defaultValue: true)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.advertising)
        }
    }
    
    public var blockAnalytics: Bool {
        get {
            guard let userDefaults = userDefaults else { return true }
            return userDefaults.bool(forKey: Keys.analytics, defaultValue: true)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.analytics)
        }
    }
    
    public var blockSocial: Bool {
        get {
            guard let userDefaults = userDefaults else { return true }
            return userDefaults.bool(forKey: Keys.social, defaultValue: true)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.social)
        }
    }
    
    public var blockingEnabled: Bool {
        return blockSocial || blockAdvertisers || blockAnalytics
    }
}
