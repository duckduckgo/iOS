//
//  BookmarkUserDefaults.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 15/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class BookmarkUserDefaults: BookmarkStore {
    
    private let groupName = "group.com.duckduckgo.bookmarks"
    
    private struct Keys {
        static let bookmarkKey = "com.duckduckgo.bookmarks.bookmarkKey"
    }
    
    public init() {}
    
    private func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
    
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
