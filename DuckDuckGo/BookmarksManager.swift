//
//  BookmarksManager.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 20/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

class BookmarksManager {
    
    private lazy var groupData = GroupDataStore()
    
    var isEmpty: Bool {
        return groupData.bookmarks?.isEmpty ?? true
    }
    
    var count: Int {
        return groupData.bookmarks?.count ?? 0
    }
    
    func bookmark(atIndex index: Int) -> Link {
        return groupData.bookmarks![index]
    }
    
    func save(bookmark: Link) {
        groupData.addBookmark(bookmark)
    }
    
    func delete(itemAtIndex index: Int) {
        if var newLinks = groupData.bookmarks {
            newLinks.remove(at: index)
            groupData.bookmarks = newLinks
        }
    }
    
    func move(itemAtIndex oldIndex: Int, to newIndex: Int) {
        if var newLinks = groupData.bookmarks {
            let link = newLinks.remove(at: oldIndex)
            newLinks.insert(link, at: newIndex)
            groupData.bookmarks = newLinks
        }
    }
    
    func update(index: Int, withBookmark newBookmark: Link) {
        if var newLinks = groupData.bookmarks {
            _ = newLinks.remove(at: index)
            newLinks.insert(newBookmark, at: index)
            groupData.bookmarks = newLinks
        }
    }
}
