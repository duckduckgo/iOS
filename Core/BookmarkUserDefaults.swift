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
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
    
    public init() {}
    
    public var bookmarks: [Link]? {
        get {
            if let data = userDefaults?.data(forKey: Keys.bookmarkKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Link]
            }
            return nil
        }
        set(newBookmarks) {
            if let newBookmarks = newBookmarks {
                let data = NSKeyedArchiver.archivedData(withRootObject: newBookmarks)
                userDefaults?.set(data, forKey: Keys.bookmarkKey)
            }
        }
    }
    
    public func addBookmark(_ bookmark: Link) {
        var newBookmarks = bookmarks ?? [Link]()
        newBookmarks.append(bookmark)
        bookmarks = newBookmarks
    }

    public func updateFavicon(_ favicon: URL, forBookmarksWithUrl url: URL) {
        guard var newBookmarks = bookmarks else { return }
        for (index, bookmark) in newBookmarks.enumerated() {
            if  shouldUpdate(bookmark: bookmark, withFavicon: favicon, fromUrl: url) {
                newBookmarks.remove(at: index)
                newBookmarks.insert(Link(title: bookmark.title, url: bookmark.url, favicon: favicon), at: index)
            }
        }
        bookmarks = newBookmarks
    }
    
    private func shouldUpdate(bookmark: Link, withFavicon favicon: URL, fromUrl url: URL) -> Bool {
        return (bookmark.url == url && bookmark.favicon != favicon) ||
               (bookmark.url.host == url.host && !bookmark.hasFavicon)
    }
}
