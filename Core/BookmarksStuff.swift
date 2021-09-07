//
//  BookmarksStuff.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import CoreData

public class BookmarksCoreDataStorage {
    
    private lazy var context = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "BookmarksAndFolders")
    
    //TODO chache bookmark items in memory?
    //probably will need to given we have to make the folder structure
        
    private func getTopLevelFolder(isFavorite: Bool) -> Folder {
        let fetchRequest = NSFetchRequest<Folder>(entityName: "Folder")
        fetchRequest.predicate = NSPredicate(format: "parent == nil AND isFavorite == %@", NSNumber(value: isFavorite))

        guard let results = try? context.fetch(fetchRequest),
          let folder = results.first else {

            let folder = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: context) as? Folder
            folder?.isFavorite = isFavorite
            try? context.save()

            guard let newFolder = folder else {
                fatalError("Error creating top level bookmark folder")
            }
            return newFolder
        }

        return folder
    }
    
    public lazy var topLevelBookmarksFolder: Folder = {
        getTopLevelFolder(isFavorite: false)
    }()
    
    private lazy var topLevelFavoritesFolder: Folder = {
        getTopLevelFolder(isFavorite: true)
    }()

    //TODO will need to keep these in sync?
    public lazy var topLevelBookmarksItems: [BookmarkItem] = {
        topLevelBookmarksFolder.children?.array as? [BookmarkItem] ?? []
    }()
    
    private lazy var topLevelFavoritesItems: [BookmarkItem] = {
        topLevelFavoritesFolder.children?.array as? [BookmarkItem] ?? []
    }()
    
    public func favorites() -> [Bookmark] {
        let favorites: [Bookmark] = topLevelFavoritesItems.map {
            if let fav = $0 as? Bookmark {
                return fav
            } else {
                fatalError("Favourites shouldn't contain folders")
            }
        }
        return favorites
    }
        
    public init() { }
    
    public func bookmarkItems() -> [BookmarkItem] {
        let fetchRequest: NSFetchRequest<BookmarkItem> = BookmarkItem.fetchRequest()
        
        guard let results = try? context.fetch(fetchRequest) else {
            fatalError("Error fetching BookmarkItems")
        }
        
        return results
    }
    
    private func createBookmark(url: URL, title: String, isFavorite: Bool, parent: Folder? = nil) {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: "Bookmark", into: context)
        guard let bookmark = managedObject as? Bookmark else { return }
        bookmark.url = url
        bookmark.title = title
        bookmark.isFavorite = isFavorite
        if let parent = parent {
            parent.addToChildren(bookmark)
        } else {
            let parent = isFavorite ? topLevelFavoritesFolder : topLevelBookmarksFolder
            parent.addToChildren(bookmark)
        }
        try? context.save()
    }
    
    private func createFolder(title: String, isFavorite: Bool, parent: Folder? = nil) -> Folder? {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: context)
        guard let folder = managedObject as? Folder else { return nil }
        folder.title = title
        folder.isFavorite = isFavorite
        if let parent = parent {
            parent.addToChildren(folder)
        } else {
            let parent = isFavorite ? topLevelFavoritesFolder : topLevelBookmarksFolder
            parent.addToChildren(folder)
        }
        try? context.save()
        return folder
    }
    
    public func createTestData() {
        createBookmark(url: URL(string: "http://example.com")!, title: "example 1.1", isFavorite: false)
        createBookmark(url: URL(string: "http://fish.com")!, title: "fish 1.2", isFavorite: false)
        let topFolder = createFolder(title: "Test folder 1, 1.3", isFavorite: false)
        createBookmark(url: URL(string: "http://dogs.com")!, title: "dogs 1.4", isFavorite: false)
        createBookmark(url: URL(string: "http://cnn.com")!, title: "cnn 2.1", isFavorite: false, parent: topFolder)
        let secondLevelFolder = createFolder(title: "Test folder 2 2.2", isFavorite: false, parent: topFolder)
        createBookmark(url: URL(string: "httP://pig.com")!, title: "pig 3.1", isFavorite: false, parent: secondLevelFolder)
        try? context.save()
    }
    
    public func createTestFavourites() {
        createBookmark(url: URL(string: "http://example.com")!, title: "example fav", isFavorite: true)
        createBookmark(url: URL(string: "http://fish.com")!, title: "fish fav", isFavorite: true)
    }
}

