//
//  MockBookmarkStore.swift
//  UnitTests
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import Core

class MockBookmarkStore: BookmarkStore {
    
    var bookmarks: [Link] = []
    
    var favorites: [Link] = []
    
    var addedBookmarks = [Link]()
    func addBookmark(_ bookmark: Link) {
        addedBookmarks.append(bookmark)
    }
    
    var addedFavorites = [Link]()
    func addFavorite(_ favorite: Link) {
        addedFavorites.append(favorite)
    }

    func contains(domain: String) -> Bool {
        return false
    }

}
