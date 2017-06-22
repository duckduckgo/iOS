//
//  ContentBlockerConfigurationUserDefaults.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
