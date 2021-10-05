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
    
    private struct Constants {
        static let contextName = "BookmarksAndFolders"
        static let bookmarkClassName = "BookmarkManagedObject"
        static let folderClassName = "BookmarkFolderManagedObject"
    }
    
    private lazy var context = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType, name: Constants.contextName)
    
    //TODO this should maybe be cached
    //re caching, updating etc
    //maybe I should just cache the not managed objects, and just use MOs for saving...
    //hmm, currently leaning that way tbh
    
    public var topLevelBookmarksFolder: BookmarkFolder {
        let folder = BookmarkFolder(managedObject: topLevelBookmarksFolderMO)
        folder.title = NSLocalizedString("Bookmarks", comment: "Top level bookmarks folder title")
        return folder
    }
    
    public var topLevelBookmarksItems: [BookmarkItem] {
        topLevelBookmarksFolder.children.array as? [BookmarkItem] ?? []
    }
    
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
    
    // Doesn't include parents
    public func allBookmarksAndFavoritesShallow() -> [Bookmark] {
        let fetchRequest: NSFetchRequest<BookmarkManagedObject> = BookmarkManagedObject.fetchRequest()

        guard let results = try? context.fetch(fetchRequest) else {
            fatalError("Error fetching Bookmarks")
        }
        let bookmarks = results.map {
            Bookmark(managedObject: $0, deepCopy: false)
        }

        return bookmarks
    }
    
    //TODO rearranging

    public func saveNewFolder(withTitle title: String, parentID: NSManagedObjectID) {
        //TODO will also need to update caches, whatever we end up with
        
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: parentID)
            guard let parentMO = mo as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get parent folder")
                return
            }

            self.createFolder(title: title, isFavorite: false, parent: parentMO)
        }
    }
    
    public func saveNewFavorite(withTitle title: String, url: URL) {
        context.perform { [weak self] in
            guard let self = self else { return }

            self.createBookmark(url: url, title: title, isFavorite: true)
        }
    }
    
    public func saveNewBookmark(withTitle title: String, url: URL, parentID: NSManagedObjectID) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: parentID)
            guard let parentMO = mo as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get parent folder")
                return
            }

            self.createBookmark(url: url, title: title, isFavorite: false, parent: parentMO)
        }
    }
    
    // Since we'll never need to update children at the same time, we only support changing the title and parent
    public func update(folderID: NSManagedObjectID, newTitle: String, newParentID: NSManagedObjectID) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: folderID)
            guard let folder = mo as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get folder")
                return
            }
            
            if folder.parent?.objectID != newParentID {
                let parentMO = self.context.object(with: newParentID)
                guard let newParentMO = parentMO as? BookmarkFolderManagedObject else {
                    assertionFailure("Failed to get new parent")
                    return
                }
                
                folder.parent?.removeFromChildren(folder)
                folder.parent = newParentMO
                newParentMO.addToChildren(folder)
            }
            folder.title = newTitle
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating folder failed")
            }
        }
        // TODO update any caches
    }
    
    public func update(favoriteID: NSManagedObjectID, newTitle: String, newURL: URL) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: favoriteID)
            guard let favorite = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get favorite")
                return
            }

            favorite.title = newTitle
            favorite.url = newURL
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating favorite failed")
            }
        }
    }
    
    public func update(bookmarkID: NSManagedObjectID, newTitle: String, newURL: URL, newParentID: NSManagedObjectID) {
        //TODO currently changes order and shouldn't
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: bookmarkID)
            guard let bookmark = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get bookmark")
                return
            }
            
            if bookmark.parent?.objectID != newParentID {
                let parentMO = self.context.object(with: newParentID)
                guard let newParentMO = parentMO as? BookmarkFolderManagedObject else {
                    assertionFailure("Failed to get new parent")
                    return
                }
                
                bookmark.parent?.removeFromChildren(bookmark)
                bookmark.parent = newParentMO
                newParentMO.addToChildren(bookmark)
            }
            
            bookmark.title = newTitle
            bookmark.url = newURL
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating bookmark failed")
            }
        }
    }
    
    //tODO will also need to be able to move favs and bookmarks between each other >:(
    
    public func updateIndex(of bookmarkItemID: NSManagedObjectID, newIndex: Int) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: bookmarkItemID)
            guard let item = mo as? BookmarkItemManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            let parent = item.parent
            parent?.removeFromChildren(item)
            parent?.insertIntoChildren(item, at: newIndex)
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating item failed")
            }
        }
    }
    
    public func convertFavoriteToBookmark(_ favoriteID: NSManagedObjectID, newIndex: Int) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: favoriteID)
            guard let favorite = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            favorite.parent?.removeFromChildren(favorite)
            favorite.isFavorite = false
            self.topLevelBookmarksFolderMO.insertIntoChildren(favorite, at: newIndex)
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating item failed")
            }
        }
    }
    
    public func convertBookmarkToFavorite(_ bookmarkID: NSManagedObjectID, newIndex: Int) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: bookmarkID)
            guard let bookmark = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            bookmark.parent?.removeFromChildren(bookmark)
            bookmark.isFavorite = true
            self.topLevelFavoritesFolderMO.insertIntoChildren(bookmark, at: newIndex)
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating item failed")
            }
        }
    }
    
    public func delete(_ bookmarkItemID: NSManagedObjectID) {
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: bookmarkItemID)
            guard let item = mo as? BookmarkItemManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            self.context.delete(item)
            
            do {
                try self.context.save()
            } catch {
                assertionFailure("Updating item failed")
            }
        }
    }
    
    public init() { }
    
    
    //TODO context.perform good behaviour
        
    private func getTopLevelFolder(isFavorite: Bool) -> BookmarkFolderManagedObject {
        let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
        fetchRequest.predicate = NSPredicate(format: "parent == nil AND isFavorite == %@", NSNumber(value: isFavorite))

        guard let results = try? context.fetch(fetchRequest),
          let folder = results.first else {

            let folder = NSEntityDescription.insertNewObject(forEntityName: "BookmarkFolderManagedObject", into: context) as? BookmarkFolderManagedObject
            folder?.isFavorite = isFavorite
            try? context.save()

            guard let newFolder = folder else {
                fatalError("Error creating top level bookmark folder")
            }
            return newFolder
        }

        return folder
    }
    
    private lazy var topLevelBookmarksFolderMO: BookmarkFolderManagedObject = {
        let folder = getTopLevelFolder(isFavorite: false)
        folder.title = NSLocalizedString("Bookmarks", comment: "Top level bookmarks folder title")
        return folder
    }()
    
    private lazy var topLevelFavoritesFolderMO: BookmarkFolderManagedObject = {
        getTopLevelFolder(isFavorite: true)
    }()
    
    private var topLevelFavoritesFolder: BookmarkFolder {
        BookmarkFolder(managedObject: topLevelFavoritesFolderMO)
    }
    
    private var topLevelFavoritesItems: [BookmarkItem] {
        topLevelFavoritesFolder.children.array as? [BookmarkItem] ?? []
    }
    
//    //TODO shouldn't be public, just for testing
//    public func bookmarkItems() -> [BookmarkItem] {
//        let fetchRequest: NSFetchRequest<BookmarkItemManagedObject> = BookmarkItem.fetchRequest()
//
//        guard let results = try? context.fetch(fetchRequest) else {
//            fatalError("Error fetching BookmarkItems")
//        }
//
//        return results
//    }
//

    
    private func createBookmark(url: URL, title: String, isFavorite: Bool, parent: BookmarkFolderManagedObject? = nil) {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.bookmarkClassName, into: context)
        guard let bookmark = managedObject as? BookmarkManagedObject else {
            assertionFailure("Inserting new bookmark failed")
            return
        }
        bookmark.url = url
        bookmark.title = title
        bookmark.isFavorite = isFavorite
        if let parent = parent {
            bookmark.parent = parent
            parent.addToChildren(bookmark)
        } else {
            let parent = isFavorite ? topLevelFavoritesFolderMO : topLevelBookmarksFolderMO
            bookmark.parent = parent
            parent.addToChildren(bookmark)
        }
    }
    
    @discardableResult
    private func createFolder(title: String, isFavorite: Bool, parent: BookmarkFolderManagedObject? = nil) -> BookmarkFolderManagedObject? {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.folderClassName, into: context)
        guard let folder = managedObject as? BookmarkFolderManagedObject else {
            assertionFailure("Inserting new folder failed")
            return nil
        }
        folder.title = title
        folder.isFavorite = isFavorite
        if let parent = parent {
            folder.parent = parent
            parent.addToChildren(folder)
        } else {
            let parent = isFavorite ? topLevelFavoritesFolderMO : topLevelBookmarksFolderMO
            folder.parent = parent
            parent.addToChildren(folder)
        }
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
        try? context.save()
    }
}



//extension BookmarksCoreDataStorage: BookmarkStore {
//
//    
//}

