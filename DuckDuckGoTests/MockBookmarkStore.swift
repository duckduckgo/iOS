//
//  MockBookmarkStore.swift
//  UnitTests
//
//  Created by Chris Brind on 14/12/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Core

class MockBookmarkStore: BookmarkStore {
    
    var bookmarks: [Link]?
    
    var favorites: [Link]?
    
    var addedBookmarks = [Link]()
    func addBookmark(_ bookmark: Link) {
        addedBookmarks.append(bookmark)
    }
    
    var addedFavorites = [Link]()
    func addFavorite(_ favorite: Link) {
        addedFavorites.append(favorite)
    }
    
}
