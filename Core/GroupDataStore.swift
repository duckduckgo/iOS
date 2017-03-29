//
//  GroupDataStore.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 06/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class GroupDataStore {
    
    private let groupName = "group.com.duckduckgo.extension"
    
    fileprivate struct Keys {
        static let quickLinksKey = "quickLinksKey"
        static let safeSearch = "safeSearch"
        static let regionFilter = "regionFilter"
        static let dateFilter = "dateFilter"
    }
    
    public init() {}
    
    fileprivate func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
}

extension GroupDataStore: BookmarkStore {
    public var quickLinks: [Link]? {
        get {
            if let data = userDefaults()?.data(forKey: Keys.quickLinksKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Link]
            }
            return nil
        }
        set(newQuickLinks) {
            if let newQuickLinks = newQuickLinks {
                let data = NSKeyedArchiver.archivedData(withRootObject: newQuickLinks)
                userDefaults()?.set(data, forKey: Keys.quickLinksKey)
            }
        }
    }
    
    public func addQuickLink(link: Link) {
        var links = quickLinks ?? [Link]()
        links.append(link)
        quickLinks = links
    }
}

extension GroupDataStore: SearchFilterStore {
    
    public var safeSearchEnabled: Bool {
        get {
            return userDefaults()?.bool(forKey: Keys.safeSearch) ?? true
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.safeSearch)
        }
    }
    
    public var regionFilter: String? {
        get {
            return userDefaults()?.string(forKey: Keys.regionFilter) ?? nil
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.regionFilter)
        }
    }
    
    public var dateFilter: String? {
        get {
            return userDefaults()?.string(forKey: Keys.dateFilter) ?? nil
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.dateFilter)
        }
    }
}
