//
//  BookmarksManager.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 20/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

class BookmarksManager {
    
    private lazy var dataStore = BookmarkUserDefaults()
    
    var isEmpty: Bool {
        return dataStore.bookmarks?.isEmpty ?? true
    }
    
    var count: Int {
        return dataStore.bookmarks?.count ?? 0
    }
    
    func bookmark(atIndex index: Int) -> Link {
        return dataStore.bookmarks![index]
    }
    
    func save(bookmark: Link) {
        dataStore.addBookmark(bookmark)
    }
    
    func delete(itemAtIndex index: Int) {
        if var newBookmarks = dataStore.bookmarks {
            newBookmarks.remove(at: index)
            dataStore.bookmarks = newBookmarks
        }
    }
    
    func move(itemAtIndex oldIndex: Int, to newIndex: Int) {
        if var newBookmarks = dataStore.bookmarks {
            let link = newBookmarks.remove(at: oldIndex)
            newBookmarks.insert(link, at: newIndex)
            dataStore.bookmarks = newBookmarks
        }
    }
    
    func update(index: Int, withBookmark newBookmark: Link) {
        if var newBookmarks = dataStore.bookmarks {
            _ = newBookmarks.remove(at: index)
            newBookmarks.insert(newBookmark, at: index)
            dataStore.bookmarks = newBookmarks
        }
    }
}
