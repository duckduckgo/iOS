//
//  BookmarksCoreDataStorage.swift
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
    
    public static let shared = BookmarksCoreDataStorage()
    
    public struct Notifications {
        public static let dataDidChange = Notification.Name("com.duckduckgo.app.BookmarksCoreDataDidChange")
    }
    
    private struct Constants {
        static let privateContextName = "EditBookmarksAndFolders"
        static let viewContextName = "ViewBookmarksAndFolders"
        
        static let bookmarkClassName = "BookmarkManagedObject"
        static let folderClassName = "BookmarkFolderManagedObject"
        
        static let databaseName = "BookmarksAndFolders"
        
        static let groupName = "\(Global.groupIdPrefix).bookmarks"
    }
    
    private let storeLoadedCondition = RunLoop.ResumeCondition()
    private var persistentContainer: NSPersistentContainer
    
    private lazy var privateContext: NSManagedObjectContext = {
        RunLoop.current.run(until: storeLoadedCondition)
        let context = persistentContainer.newBackgroundContext()
        context.name = Constants.privateContextName
        return context
    }()
    
    private lazy var viewContext: NSManagedObjectContext = {
        RunLoop.current.run(until: storeLoadedCondition)
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy(merge: .rollbackMergePolicyType)
        context.name = Constants.viewContextName
        return context
    }()
    
    private var cachedReadOnlyTopLevelBookmarksFolder: BookmarkFolderManagedObject?
    private var cachedReadOnlyTopLevelFavoritesFolder: BookmarkFolderManagedObject?
    
    private static var managedObjectModel: NSManagedObjectModel {
        let coreBundle = Bundle(identifier: "com.duckduckgo.mobile.ios.Core")!
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [coreBundle]) else {
            fatalError("No DB scheme found")
        }
        return managedObjectModel
    }
    
    private static var storeDescription: NSPersistentStoreDescription {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupName)!
        let storeURL = containerURL.appendingPathComponent("\(Constants.databaseName).sqlite")
        return NSPersistentStoreDescription(url: storeURL)
    }
    
    public init() {
        persistentContainer = NSPersistentContainer(name: Constants.databaseName, managedObjectModel: BookmarksCoreDataStorage.managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [BookmarksCoreDataStorage.storeDescription]
    }
    
    public func loadStoreAndCaches(andMigrate handler: @escaping (NSManagedObjectContext) -> Void = { _ in }) {
        
        loadStore() { context in
            handler(context)
        }
        
        RunLoop.current.run(until: storeLoadedCondition)
        cacheReadOnlyTopLevelBookmarksFolder()
        cacheReadOnlyTopLevelFavoritesFolder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    private func loadStore(andMigrate handler: @escaping (NSManagedObjectContext) -> Void = { _ in }) {

        persistentContainer = NSPersistentContainer(name: Constants.databaseName, managedObjectModel: BookmarksCoreDataStorage.managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [BookmarksCoreDataStorage.storeDescription]
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
            context.name = "Migration"
            context.perform {
                handler(context)
                self.storeLoadedCondition.resolve()
            }            
        }
    }
}

// MARK: public interface
extension BookmarksCoreDataStorage {
    
    public var topLevelBookmarksFolder: BookmarkFolder? {
        guard let folder = cachedReadOnlyTopLevelBookmarksFolder else {
            return nil
        }
        return folder
    }
    
    public var topLevelBookmarksItems: [BookmarkItem] {
        guard let folder = cachedReadOnlyTopLevelBookmarksFolder else {
            return []
        }
        return folder.children?.array as? [BookmarkItem] ?? []
    }
    
    public var favorites: [Bookmark] {
        return readOnlyTopLevelFavoritesItems().map {
            if let fav = $0 as? Bookmark {
                return fav
            } else {
                fatalError("Favourites shouldn't contain folders")
            }
        }
    }
    
    public func contains(url: URL, completion: @escaping (Bool) -> Void) {
        containsBookmark(url: url, searchType: .bookmarksAndFavorites, completion: completion)
    }
    
    public func containsBookmark(url: URL, completion: @escaping (Bool) -> Void) {
        containsBookmark(url: url, searchType: .bookmarksOnly, completion: completion)
    }
    
    public func containsFavorite(url: URL, completion: @escaping (Bool) -> Void) {
        containsBookmark(url: url, searchType: .favoritesOnly, completion: completion)
    }
    
    public func bookmark(forURL url: URL, completion: @escaping (Bookmark?) -> Void) {
        viewContext.perform {
    
            let fetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
            fetchRequest.predicate = NSPredicate(format: "url == %@ AND isFavorite == false", url as CVarArg)
            
            let results = try? self.viewContext.fetch(fetchRequest)
            completion(results?.first)
        }
    }
    
    public func favorite(forURL url: URL, completion: @escaping (Bookmark?) -> Void) {
        viewContext.perform {
    
            let fetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
            fetchRequest.predicate = NSPredicate(format: "url == %@ AND isFavorite == true", url as CVarArg)
            
            let results = try? self.viewContext.fetch(fetchRequest)
            completion(results?.first)
        }
    }
    
    // Just used for favicon deletion
    public func allBookmarksAndFavoritesShallow(completion: @escaping ([Bookmark]) -> Void) {
        viewContext.perform { [weak self] in
        
            let fetchRequest: NSFetchRequest<BookmarkManagedObject> = BookmarkManagedObject.fetchRequest()

            guard let results = try? self?.viewContext.fetch(fetchRequest) else {
                fatalError("Error fetching Bookmarks")
            }
            
            completion(results)
        }
    }
    
    public func saveNewFolder(withTitle title: String, parentID: NSManagedObjectID) {
        createFolder(title: title, isFavorite: false, parentID: parentID)
    }
    
    public func saveNewFavorite(withTitle title: String, url: URL) {
        createBookmark(url: url, title: title, isFavorite: true)
    }
    
    public func saveNewBookmark(withTitle title: String, url: URL, parentID: NSManagedObjectID?) {
        createBookmark(url: url, title: title, isFavorite: false, parentID: parentID)
    }
    
    // Since we'll never need to update children at the same time, we only support changing the title and parent
    public func update(folderID: NSManagedObjectID, newTitle: String, newParentID: NSManagedObjectID) {
        privateContext.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.privateContext.object(with: folderID)
            guard let folder = mo as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get folder")
                return
            }
            
            if folder.parent?.objectID != newParentID {
                let parentMO = self.privateContext.object(with: newParentID)
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
                try self.privateContext.save()
            } catch {
                assertionFailure("Updating folder failed")
            }
        }
    }
    
    public func update(favoriteID: NSManagedObjectID, newTitle: String, newURL: URL) {
        privateContext.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.privateContext.object(with: favoriteID)
            guard let favorite = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get favorite")
                return
            }

            favorite.title = newTitle
            favorite.url = newURL
            
            do {
                try self.privateContext.save()
            } catch {
                assertionFailure("Updating favorite failed")
            }
        }
    }
    
    public func update(bookmarkID: NSManagedObjectID, newTitle: String, newURL: URL, newParentID: NSManagedObjectID) {
        privateContext.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.privateContext.object(with: bookmarkID)
            guard let bookmark = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get bookmark")
                return
            }
            
            if bookmark.parent?.objectID != newParentID {
                let parentMO = self.privateContext.object(with: newParentID)
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
                try self.privateContext.save()
            } catch {
                assertionFailure("Updating bookmark failed")
            }
        }
    }
        
    public func updateIndex(of bookmarkItemID: NSManagedObjectID, newIndex: Int) {
        privateContext.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.privateContext.object(with: bookmarkItemID)
            guard let item = mo as? BookmarkItemManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            let parent = item.parent
            parent?.removeFromChildren(item)
            parent?.insertIntoChildren(item, at: newIndex)
            
            do {
                try self.privateContext.save()
            } catch {
                assertionFailure("Updating item failed")
            }
        }
    }
    
    public func convertFavoriteToBookmark(_ favoriteID: NSManagedObjectID, newIndex: Int) {
        swapIsFavorite(favoriteID, newIndex: newIndex)
    }
    
    public func convertBookmarkToFavorite(_ bookmarkID: NSManagedObjectID, newIndex: Int) {
        swapIsFavorite(bookmarkID, newIndex: newIndex)
    }
    
    public func delete(_ bookmarkItemID: NSManagedObjectID) {
        privateContext.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.privateContext.object(with: bookmarkItemID)
            guard let item = mo as? BookmarkItemManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            self.privateContext.delete(item)
            
            do {
                try self.privateContext.save()
            } catch {
                assertionFailure("Updating item failed")
            }
        }
    }
}

// MARK: Public interface for widget
extension BookmarksCoreDataStorage {
    
    // Widget doesn't need to care about caches
    public func loadStoreOnlyForWidget() {
        loadStore()
    }
    
    public func favoritesUncachedForWidget(completion: @escaping ([Bookmark]) -> Void) {
        getTopLevelFolder(isFavorite: true, readOnly: true) { folder in
            
            let children = folder.children?.array as? [BookmarkItem] ?? []
            let favorites: [Bookmark] = children.map {
                if let fav = $0 as? Bookmark {
                    return fav
                } else {
                    fatalError("Favourites shouldn't contain folders")
                }
            }
            completion(favorites)
        }
    }
}


// MARK: respond to data updates
extension BookmarksCoreDataStorage {
            
    @objc func contextDidSave(notification: Notification) {
        guard let sender = notification.object as? NSManagedObjectContext else { return }
        
        if sender == privateContext {
            viewContext.perform { [weak self] in
                self?.viewContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    @objc func objectsDidChange(notification: Notification) {
        guard let sender = notification.object as? NSManagedObjectContext else { return }

        if sender == viewContext {
            NotificationCenter.default.post(name: BookmarksCoreDataStorage.Notifications.dataDidChange, object: nil)
        }
    }
}

// MARK: private
extension BookmarksCoreDataStorage {
    
    private func swapIsFavorite(_ bookmarkID: NSManagedObjectID, newIndex: Int) {
        privateContext.perform { [weak self] in
            guard let self = self else { return }

            let mo = self.privateContext.object(with: bookmarkID)
            guard let bookmark = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get item")
                return
            }
            
            self.getTopLevelFolder(isFavorite: !bookmark.isFavorite, readOnly: false) { newParent in
                
                bookmark.parent?.removeFromChildren(bookmark)
                bookmark.isFavorite = !bookmark.isFavorite
                newParent.insertIntoChildren(bookmark, at: newIndex)
                
                
                do {
                    try self.privateContext.save()
                } catch let error {
                    print(error)
                    assertionFailure("Updating item failed")
                }
            }
        }
    }
    
    private enum SearchType {
        case bookmarksOnly
        case favoritesOnly
        case bookmarksAndFavorites
    }
    
    private func containsBookmark(url: URL, searchType: SearchType, completion: @escaping (Bool) -> Void) {
        viewContext.perform {
            let fetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
            
            switch searchType {
            case .bookmarksOnly:
                fetchRequest.predicate = NSPredicate(format: "url == %@ AND isFavorite == false", url as CVarArg)
            case .favoritesOnly:
                fetchRequest.predicate = NSPredicate(format: "url == %@ AND isFavorite == true", url as CVarArg)
            case .bookmarksAndFavorites:
                fetchRequest.predicate = NSPredicate(format: "url == %@", url as CVarArg)
            }
            
            guard let results = try? self.viewContext.fetch(fetchRequest) else {
                completion(false)
                return
            }
            completion(results.count > 0)
        }
    }
    
    private func getTopLevelFolder(isFavorite: Bool, readOnly: Bool, completion: @escaping (BookmarkFolderManagedObject) -> Void) {
        
        let context = readOnly ? viewContext : privateContext
        context.perform {
            
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "parent == nil AND isFavorite == %@", NSNumber(value: isFavorite))
            
            let results = try? context.fetch(fetchRequest)
            guard (results?.count ?? 0) <= 1 else {
                fatalError("There shouldn't be an orphaned folder")
            }
            
            guard let folder = results?.first else {
                fatalError("Top level folder missing. isFavorite: \(isFavorite)")
            }
            completion(folder)
        }
    }
    
    private func cacheReadOnlyTopLevelBookmarksFolder() {
        
        viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "parent == nil AND isFavorite == false")
            
            let results = try? viewContext.fetch(fetchRequest)
            guard (results?.count ?? 0) <= 1 else {
                fatalError("There shouldn't be an orphaned folder")
            }
            
            guard let folder = results?.first else {
                fatalError("Top level folder missing")
            }
            
            self.cachedReadOnlyTopLevelBookmarksFolder = folder
        }
    }
    
    private func cacheReadOnlyTopLevelFavoritesFolder() {
        viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "parent == nil AND isFavorite == true")
            
            let results = try? viewContext.fetch(fetchRequest)
            guard (results?.count ?? 0) <= 1 else {
                fatalError("There shouldn't be an orphaned folder")
            }
            
            guard let folder = results?.first else {
                fatalError("Top level folder missing")
            }
            
            self.cachedReadOnlyTopLevelFavoritesFolder = folder
        }
    }
    
    private func readOnlyTopLevelFavoritesItems() -> [BookmarkItem] {
        guard let folder = cachedReadOnlyTopLevelFavoritesFolder else {
            return []
        }
        return folder.children?.array as? [BookmarkItem] ?? []
    }
}


// MARK: creation
extension BookmarksCoreDataStorage {
    
    private func createBookmark(url: URL, title: String, isFavorite: Bool, parentID: NSManagedObjectID? = nil) {
        privateContext.perform { [weak self] in
            guard let self = self else {
                fatalError("self nil when creating bookmark")
            }
        
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.bookmarkClassName, into: self.privateContext)
            guard let bookmark = managedObject as? BookmarkManagedObject else {
                assertionFailure("Inserting new bookmark failed")
                return
            }
            bookmark.url = url
            bookmark.title = title
            bookmark.isFavorite = isFavorite
            
            self.updateParentAndSave(of: bookmark, parentID: parentID)
        }
    }
    
    private func createFolder(title: String, isFavorite: Bool, parentID: NSManagedObjectID? = nil) {
        
        privateContext.perform { [weak self] in
            guard let self = self else {
                fatalError("self nil when creating folder")
            }
            
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.folderClassName, into: self.privateContext)
            guard let folder = managedObject as? BookmarkFolderManagedObject else {
                assertionFailure("Inserting new folder failed")
                return
            }
            folder.title = title
            folder.isFavorite = isFavorite
            
            self.updateParentAndSave(of: folder, parentID: parentID)
        }
    }
    
    private func updateParentAndSave(of item: BookmarkItemManagedObject, parentID: NSManagedObjectID?) {
        func updateParentAndSave(parent: BookmarkFolderManagedObject) {
            item.parent = parent
            parent.addToChildren(item)
            
            do {
                try self.privateContext.save()
            } catch {
                assertionFailure("Saving item failed")
            }
        }
        
        if let parentID = parentID {
            let parentMO = self.privateContext.object(with: parentID)
            guard let newParentMO = parentMO as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get new parent")
                return
            }
            updateParentAndSave(parent: newParentMO)
        } else {
            self.getTopLevelFolder(isFavorite: item.isFavorite, readOnly: false) { parent in
                updateParentAndSave(parent: parent)
            }
        }
    }
}

public class BookmarksCoreDataStorageMigration {
    
    @UserDefaultsWrapper(key: .bookmarksMigratedFromUserDefaultsToCoreData, defaultValue: false)
    private static var migratedFromUserDefaults: Bool
    
    public static func migrateFromUserDefaults(context: NSManagedObjectContext) {
        if migratedFromUserDefaults {
            return
        }
        
        context.performAndWait {
            let favoritesFolder = NSEntityDescription.insertNewObject(forEntityName: "BookmarkFolderManagedObject", into: context) as? BookmarkFolderManagedObject
            favoritesFolder?.isFavorite = true
            let bookmarksFolder = NSEntityDescription.insertNewObject(forEntityName: "BookmarkFolderManagedObject", into: context) as? BookmarkFolderManagedObject
            bookmarksFolder?.isFavorite = false
                        
            do {
                try context.save()
            } catch {
                fatalError("Error creating top level bookmark folders")
            }
        }

        migratedFromUserDefaults = true
    }
}


//extension BookmarksCoreDataStorage: BookmarkStore {
//
//    
//}

