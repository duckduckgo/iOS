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
    
    // Since we'll never need to update children at the same time, we only support changing the title and parent
    public func update(folderID: NSManagedObjectID, newTitle: String?, newParent: BookmarkFolder) {
        // TODO
    }
    
    //hmm don't want to handle saving children changes since that will never happen
    //so I should come up with an interface for this that reflects just changing the title and parent
//    public func saveExisting(folder: Folder, newTitle: String?, newParent: Folder, originalParent: Folder?) {
//        //TODO we're gonna need to know the previous parent
//        //I'm not sure a generic save function is the way to go...
//        //maybe lets ignore rearranging for now
//        //so saving means saving the title and parent
//        //and adding it to the new parents children
//        //and removing it from the old one
//
////        originalParent?.removeFromChildren(folder)
////        newParent.addToChildren(folder)
////        let context1 = folder.managedObjectContext
////        let context2 = newParent.managedObjectContext
////        print(context1)
////        print(context2)
////        //folder.parent = newParent
////        folder.title = newTitle
////        folder.parent?.addToChildren(folder)
////        try? context.save()
//
//        //we would need to invalidate topLevelBookmarkItems maybe?
//        //idk...
//    }

    //TODO should it be possible to save with no title?
    public func saveNewFolder(withTitle title: String?, parent: BookmarkFolder) {
        //TODO will also need to update caches, whatever we end up with
        
        context.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.context.object(with: parent.objectID)
            guard let parentMO = mo as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get parent folder")
                return
            }
            //TODO optional title
            self.createFolder(title: title!, isFavorite: false, parent: parentMO)
        }
    }
    
    public init() { }
    
    //TODO chache bookmark items in memory?
    //probably will need to given we have to make the folder structure
    
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

//
//    public func delete(item: BookmarkItem) {
//        context.delete(item)
//        try? context.save()
//    }
    
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
        do {
            try context.save()
        } catch {
            assertionFailure("Saving new bookmark failed")
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
        do {
            try context.save()
        } catch {
            assertionFailure("Saving new folder failed")
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
    }
}



//extension BookmarksCoreDataStorage: BookmarkStore {
//
//    
//}

