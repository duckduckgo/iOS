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
        static let enabled = "com.duckduckgo.contentblocker.enabled"
        static let whitelistedDomains = "com.duckduckgo.contentblocker.whitelist"
    }
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }

    public init() {}
    
    public var enabled: Bool {
        get {
            guard let userDefaults = userDefaults else { return true }
            return userDefaults.bool(forKey: Keys.enabled, defaultValue: true)
        }
        set(newValue) {
            userDefaults?.set(newValue, forKey: Keys.enabled)
        }
    }

    public var domainWhitelist: Set<String> {
        get {
            guard let data = userDefaults?.data(forKey: Keys.whitelistedDomains) else { return Set<String>() }
            guard let whitelist = NSKeyedUnarchiver.unarchiveObject(with: data) as? Set<String> else { return Set<String>() }
            return whitelist
        }
        set(newWhitelistedDomain) {
            let data = NSKeyedArchiver.archivedData(withRootObject: newWhitelistedDomain)
            userDefaults?.set(data, forKey: Keys.whitelistedDomains)
        }
    }
    
    public func whitelisted(domain: String) -> Bool {
        return domainWhitelist.contains(domain)
    }
    
    public func addToWhitelist(domain: String) {
        var whitelist = domainWhitelist
        whitelist.insert(domain)
        domainWhitelist = whitelist
    }
    
    public func removeFromWhitelist(domain: String) {
        var whitelist = domainWhitelist
        whitelist.remove(domain)
        domainWhitelist = whitelist
    }
}
