//
//  BookmarksTestHelpers.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Bookmarks
import CoreData
import XCTest

struct BasicBookmarksStructure {
    
    static let topLevelTitles = ["1", "Folder", "2", "3"]
    static let nestedTitles = ["Nested", "F1", "F2"]
    static let favoriteTitles = ["1", "2", "F1", "3"]
    
    static func urlString(forName name: String) -> String {
        "https://\(name).com"
    }
    
    static func createBookmarksList(usingNames names: [String],
                                    parent: BookmarkEntity,
                                    in context: NSManagedObjectContext) -> [BookmarkEntity] {
        
        let bookmarks: [BookmarkEntity] = names.map { name in
            let b = BookmarkEntity(context: context)
            b.uuid = UUID().uuidString
            b.title = name
            b.url = urlString(forName: name)
            b.isFolder = false
            b.parent = parent
            return b
        }
        return bookmarks
    }
    
    static func populateDB(context: NSManagedObjectContext) {
        
        // Structure:
        // Bookmark 1
        // Folder Folder ->
        //   - Folder Nested
        //   - Bookmark F1
        //   - Bookmark F2
        // Bookmark 2
        // Bookmark 3
        //
        // Favorites: 1 -> 2 -> F1 -> 3
        
        BookmarkUtils.prepareFoldersStructure(in: context)
        
        guard let rootFolder = BookmarkUtils.fetchRootFolder(context)
        else {
            XCTFail("Couldn't find required folders")
            return
        }

        let favoritesFolders = BookmarkUtils.fetchFavoritesFolders(for: .displayNative(.mobile), in: context)

        let topLevel = createBookmarksList(usingNames: topLevelTitles, parent: rootFolder, in: context)
        
        let parent = topLevel[1]
        parent.url = nil
        parent.isFolder = true
        
        let nestedLevel = createBookmarksList(usingNames: nestedTitles, parent: parent, in: context)
        
        nestedLevel[0].url = nil
        nestedLevel[0].isFolder = true
        
        topLevel[0].addToFavorites(folders: favoritesFolders)
        topLevel[2].addToFavorites(folders: favoritesFolders)
        nestedLevel[1].addToFavorites(folders: favoritesFolders)
        topLevel[3].addToFavorites(folders: favoritesFolders)
        
        do {
            try context.save()
        } catch {
            XCTFail("Couldn't populate db: \(error.localizedDescription)")
        }
    }
}
