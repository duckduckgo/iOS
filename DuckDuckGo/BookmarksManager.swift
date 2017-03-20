//
//  BookmarksManager.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 20/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

class BookmarksManager {
    
    private lazy var groupData = GroupData()
    
    var isEmpty: Bool {
        return groupData.quickLinks?.isEmpty ?? true
    }
    
    var count: Int {
        return groupData.quickLinks?.count ?? 0
    }
    
    func bookmark(atIndex index: Int) -> Link {
        return groupData.quickLinks![index]
    }
    
    func save(bookmark: Link) {
        groupData.addQuickLink(link: bookmark)
    }
    
    func delete(itemAtIndex index: Int) {
        if var newLinks = groupData.quickLinks {
            newLinks.remove(at: index)
            groupData.quickLinks = newLinks
        }
    }
    
    func move(itemAtIndex oldIndex: Int, to newIndex: Int) {
        if var newLinks = groupData.quickLinks {
            let link = newLinks.remove(at: oldIndex)
            newLinks.insert(link, at: newIndex)
            groupData.quickLinks = newLinks
        }
    }
    
    func update(index: Int, withBookmark newBookmark: Link) {
        if var newLinks = groupData.quickLinks {
            _ = newLinks.remove(at: index)
            newLinks.insert(newBookmark, at: index)
            groupData.quickLinks = newLinks
        }
    }
}
