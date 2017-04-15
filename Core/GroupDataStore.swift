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
        static let bookmarkKey = "bookmarkKey"
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
    public var bookmarks: [Link]? {
        get {
            if let data = userDefaults()?.data(forKey: Keys.bookmarkKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Link]
            }
            return nil
        }
        set(newBookmarks) {
            if let newBookmarks = newBookmarks {
                let data = NSKeyedArchiver.archivedData(withRootObject: newBookmarks)
                userDefaults()?.set(data, forKey: Keys.bookmarkKey)
            }
        }
    }
    
    public func addBookmark(_ bookmark: Link) {
        var newBookmarks = bookmarks ?? [Link]()
        newBookmarks.append(bookmark)
        bookmarks = newBookmarks
    }
}

extension GroupDataStore: SearchFilterStore {
    
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
