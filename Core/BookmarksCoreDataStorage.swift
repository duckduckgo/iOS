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
import os.log

// swiftlint:disable file_length

public enum BookmarksCoreDataStorageError: Error {
    case storeDeallocated
    case fetchingExistingItemFailed
    case fetchingParentFailed
    case insertObjectFailed
    case contextSaveError
}

public typealias BookmarkItemSavedMainThreadCompletion = ((NSManagedObjectID?, BookmarksCoreDataStorageError?) -> Void)
public typealias BookmarkExistsMainThreadCompletion = ((Bool) -> Void)

public typealias BookmarkItemDeletedBackgroundThreadCompletion = ((Bool, BookmarksCoreDataStorageError?) -> Void)
public typealias BookmarkItemUpdatedBackgroundThreadCompletion = ((Bool, BookmarksCoreDataStorageError?) -> Void)
public typealias BookmarkItemIndexUpdatedBackgroundThreadCompletion = ((Bool, BookmarksCoreDataStorageError?) -> Void)
public typealias BookmarkConvertedBackgroundThreadCompletion = ((Bool, BookmarksCoreDataStorageError?) -> Void)

public class BookmarksCoreDataStorage {
    
    public static let shared = BookmarksCoreDataStorage()
    
    public struct Notifications {
        public static let dataDidChange = Notification.Name("com.duckduckgo.app.BookmarksCoreDataDidChange")
    }
    
    private let storeLoadedCondition = RunLoop.ResumeCondition()
    internal var persistentContainer: NSPersistentContainer
    
    internal lazy var viewContext: NSManagedObjectContext = {
        RunLoop.current.run(until: storeLoadedCondition)
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy(merge: .rollbackMergePolicyType)
        context.name = Constants.viewContextName
        return context
    }()
    
    internal func getTemporaryPrivateContext() -> NSManagedObjectContext {
        RunLoop.current.run(until: storeLoadedCondition)
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        context.name = Constants.privateContextName
        return context
    }
    
    private var cachedReadOnlyTopLevelBookmarksFolder: BookmarkFolderManagedObject?
    private var cachedReadOnlyTopLevelFavoritesFolder: BookmarkFolderManagedObject?
    
    internal static var managedObjectModel: NSManagedObjectModel {
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
        
        loadStore(andMigrate: handler)
        
        RunLoop.current.run(until: storeLoadedCondition)
        cacheReadOnlyTopLevelBookmarksFolder()
        cacheReadOnlyTopLevelFavoritesFolder()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidSave),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(objectsDidChange),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    internal func loadStore(andMigrate handler: @escaping (NSManagedObjectContext) -> Void = { _ in }) {

        persistentContainer = NSPersistentContainer(name: Constants.databaseName, managedObjectModel: BookmarksCoreDataStorage.managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [BookmarksCoreDataStorage.storeDescription]
        persistentContainer.loadPersistentStores { _, error in
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

    static internal func rootFolderManagedObject(_ context: NSManagedObjectContext) -> BookmarkFolderManagedObject {
        guard let bookmarksFolder = NSEntityDescription.insertNewObject(forEntityName: "BookmarkFolderManagedObject", into: context)
                as? BookmarkFolderManagedObject else {
            fatalError("Error creating top level bookmarks folder")
        }

        bookmarksFolder.isFavorite = false
        return bookmarksFolder
    }

    static internal func rootFavoritesFolderManagedObject(_ context: NSManagedObjectContext) -> BookmarkFolderManagedObject {
        guard let bookmarksFolder = NSEntityDescription.insertNewObject(forEntityName: "BookmarkFolderManagedObject", into: context)
                as? BookmarkFolderManagedObject else {
            fatalError("Error creating top level favorites folder")
        }

        bookmarksFolder.isFavorite = true
        return bookmarksFolder
    }
}

// MARK: public interface
extension BookmarksCoreDataStorage {
    
    public var topLevelBookmarksFolder: BookmarkFolderManagedObject? {
        guard let folder = cachedReadOnlyTopLevelBookmarksFolder else {
            return nil
        }
        return folder
    }
    
    public var topLevelFavoritesFolder: BookmarkFolderManagedObject? {
        guard let folder = cachedReadOnlyTopLevelFavoritesFolder else {
            return nil
        }
        return folder
    }

    public var topLevelBookmarksItems: [BookmarkItemManagedObject] {
        guard let folder = cachedReadOnlyTopLevelBookmarksFolder else {
            return []
        }
        return folder.children?.array as? [BookmarkItemManagedObject] ?? []
    }
    
    public var favorites: [BookmarkManagedObject] {
        return readOnlyTopLevelFavoritesItems().map {
            if let fav = $0 as? BookmarkManagedObject {
                return fav
            } else {
                fatalError("Favourites shouldn't contain folders")
            }
        }
    }
    
    public func contains(url: URL, completion: @escaping BookmarkExistsMainThreadCompletion) {
        containsBookmark(url: url, searchType: .bookmarksAndFavorites, completion: completion)
    }
    
    public func containsBookmark(url: URL, completion: @escaping BookmarkExistsMainThreadCompletion) {
        containsBookmark(url: url, searchType: .bookmarksOnly, completion: completion)
    }
    
    public func containsFavorite(url: URL, completion: @escaping BookmarkExistsMainThreadCompletion) {
        containsBookmark(url: url, searchType: .favoritesOnly, completion: completion)
    }
    
    public func bookmark(forURL url: URL, completion: @escaping (BookmarkManagedObject?) -> Void) {
        viewContext.perform {
    
            let fetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == false",
                                                 #keyPath(BookmarkManagedObject.url),
                                                 url as NSURL,
                                                 #keyPath(BookmarkManagedObject.isFavorite))
            
            let results = try? self.viewContext.fetch(fetchRequest)
            completion(results?.first)
        }
    }
    
    public func bookmark(forURL url: URL) async -> BookmarkManagedObject? {
        return await withCheckedContinuation { continuation in
            bookmark(forURL: url) { bookmarkManagedObject in
                continuation.resume(returning: bookmarkManagedObject)
            }
        }
    }

    public func favorite(forURL url: URL, completion: @escaping (BookmarkManagedObject?) -> Void) {
        viewContext.perform {
    
            let fetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == true",
                                                 #keyPath(BookmarkManagedObject.url),
                                                 url as NSURL,
                                                 #keyPath(BookmarkManagedObject.isFavorite))
            
            let results = try? self.viewContext.fetch(fetchRequest)
            completion(results?.first)
        }
    }
    
    public func favorite(forURL url: URL) async throws -> BookmarkManagedObject? {
        return await withCheckedContinuation { continuation in
            favorite(forURL: url) { bookmarkManagedObject in
                continuation.resume(returning: bookmarkManagedObject)
            }
        }
    }

    // Just used for favicon deletion and search
    public func allBookmarksAndFavoritesFlat(completion: @escaping ([BookmarkManagedObject]) -> Void) {
        viewContext.perform { [weak self] in
        
            let fetchRequest: NSFetchRequest<BookmarkManagedObject> = BookmarkManagedObject.fetchRequest()
            fetchRequest.returnsObjectsAsFaults = false

            guard let results = try? self?.viewContext.fetch(fetchRequest) else {
                assertionFailure("Error fetching Bookmarks")
                return
            }
            
            completion(results)
        }
    }
    
    public func allBookmarksAndFavoritesFlat() async -> [BookmarkManagedObject] {
        return await withCheckedContinuation { continuation in
            allBookmarksAndFavoritesFlat { objects in
                return continuation.resume(returning: objects)
            }
        }
    }

    public func saveNewFolder(withTitle title: String, parentID: NSManagedObjectID, completion: BookmarkItemSavedMainThreadCompletion? = nil) {
        createFolder(title: title, isFavorite: false, parentID: parentID, completion: completion)
    }
    
    public func saveNewFolder(withTitle: String, parentID: NSManagedObjectID) async throws -> NSManagedObjectID {
        return try await withCheckedThrowingContinuation { continuation in
            saveNewFolder(withTitle: withTitle, parentID: parentID) { managedObjectID, error in
                if let error = error {
                    assertionFailure("Saving folder failed")
                    return continuation.resume(throwing: error)
                }
                guard let managedObjectID = managedObjectID else {
                    assertionFailure("Saving folder failed")
                    return continuation.resume(throwing: BookmarksCoreDataStorageError.contextSaveError)
                }

                return continuation.resume(returning: managedObjectID)
            }
        }
    }

    public func saveNewFavorite(withTitle title: String, url: URL, completion: BookmarkItemSavedMainThreadCompletion? = nil) {
        createBookmark(url: url, title: title, isFavorite: true, completion: completion)
    }
    
    public func saveNewFavorite(withTitle title: String,
                                url: URL) async throws -> NSManagedObjectID {
        return try await withCheckedThrowingContinuation { continuation in
            saveNewFavorite(withTitle: title, url: url) { managedObjectID, error in
                if let error = error {
                    assertionFailure("Saving favorite failed")
                    return continuation.resume(throwing: error)
                }
                guard let managedObjectID = managedObjectID else {
                    assertionFailure("Saving favorite failed")
                    return continuation.resume(throwing: BookmarksCoreDataStorageError.contextSaveError)
                }

                return continuation.resume(returning: managedObjectID)
            }
        }
    }

    public func saveNewBookmark(withTitle title: String,
                                url: URL,
                                parentID: NSManagedObjectID?,
                                completion: BookmarkItemSavedMainThreadCompletion? = nil) {
        
        createBookmark(url: url, title: title, isFavorite: false, parentID: parentID, completion: completion)
    }
    
    public func saveNewBookmark(withTitle title: String,
                                url: URL,
                                parentID: NSManagedObjectID?) async throws -> NSManagedObjectID {
        return try await withCheckedThrowingContinuation { continuation in
            saveNewBookmark(withTitle: title, url: url, parentID: parentID) { managedObjectID, error in
                if let error = error {
                    assertionFailure("Saving bookmark failed")
                    return continuation.resume(throwing: error)
                }
                guard let managedObjectID = managedObjectID else {
                    assertionFailure("Saving bookmark failed")
                    return continuation.resume(throwing: BookmarksCoreDataStorageError.contextSaveError)
                }

                return continuation.resume(returning: managedObjectID)
            }
        }
    }

    // Since we'll never need to update children at the same time, we only support changing the title and parent
    public func update(folderID: NSManagedObjectID,
                       newTitle: String,
                       newParentID: NSManagedObjectID,
                       completion: BookmarkItemUpdatedBackgroundThreadCompletion? = nil) {
        
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform {

            let mo = try? privateContext.existingObject(with: folderID)
            guard let folder = mo as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get folder")
                completion?(false, .fetchingExistingItemFailed)
                return
            }
            
            if folder.parent?.objectID != newParentID {
                let parentMO = try? privateContext.existingObject(with: newParentID)
                guard let newParentMO = parentMO as? BookmarkFolderManagedObject else {
                    assertionFailure("Failed to get new parent")
                    completion?(false, .fetchingParentFailed)
                    return
                }
                
                folder.parent = newParentMO
            }
            folder.title = newTitle
            
            do {
                try privateContext.save()
            } catch {
                assertionFailure("Updating folder failed")
                completion?(false, .contextSaveError)
                return
            }
            completion?(true, nil)
        }
    }
    
    public func update(favoriteID: NSManagedObjectID,
                       newTitle: String,
                       newURL: URL,
                       completion: BookmarkItemUpdatedBackgroundThreadCompletion? = nil) {
        
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform {

            let mo = try? privateContext.existingObject(with: favoriteID)
            guard let favorite = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get favorite")
                completion?(false, .fetchingExistingItemFailed)
                return
            }

            favorite.title = newTitle
            favorite.url = newURL
            
            do {
                try privateContext.save()
            } catch {
                assertionFailure("Updating favorite failed")
                completion?(false, .contextSaveError)
                return
            }
            completion?(true, nil)
        }
    }
    
    public func update(bookmarkID: NSManagedObjectID,
                       newTitle: String,
                       newURL: URL,
                       newParentID: NSManagedObjectID,
                       completion: BookmarkItemUpdatedBackgroundThreadCompletion? = nil) {
        
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform {

            let mo = try? privateContext.existingObject(with: bookmarkID)
            guard let bookmark = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get bookmark")
                completion?(false, .fetchingExistingItemFailed)
                return
            }
            
            if bookmark.parent?.objectID != newParentID {
                let parentMO = try? privateContext.existingObject(with: newParentID)
                guard let newParentMO = parentMO as? BookmarkFolderManagedObject else {
                    assertionFailure("Failed to get new parent")
                    completion?(false, .fetchingParentFailed)
                    return
                }
                
                bookmark.parent = newParentMO
            }
            
            bookmark.title = newTitle
            bookmark.url = newURL
            
            do {
                try privateContext.save()
            } catch {
                assertionFailure("Updating bookmark failed")
                completion?(false, .contextSaveError)
                return
            }
            completion?(true, nil)
        }
    }
        
    public func updateIndex(of bookmarkItemID: NSManagedObjectID,
                            newIndex: Int,
                            completion: BookmarkItemIndexUpdatedBackgroundThreadCompletion? = nil) {
        
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform {

            let mo = try? privateContext.existingObject(with: bookmarkItemID)
            guard let item = mo as? BookmarkItemManagedObject else {
                assertionFailure("Failed to get item")
                completion?(false, .fetchingExistingItemFailed)
                return
            }
            
            let parent = item.parent
            parent?.removeFromChildren(item)
            parent?.insertIntoChildren(item, at: newIndex)
            
            do {
                try privateContext.save()
            } catch {
                assertionFailure("Updating item failed")
                completion?(false, .contextSaveError)
                return
            }
            completion?(true, nil)
        }
    }
    
    public func convertFavoriteToBookmark(_ favoriteID: NSManagedObjectID,
                                          newIndex: Int,
                                          completion: BookmarkConvertedBackgroundThreadCompletion? = nil) {
        
        swapIsFavorite(favoriteID, newIndex: newIndex, completion: completion)
    }
    
    public func convertBookmarkToFavorite(_ bookmarkID: NSManagedObjectID,
                                          newIndex: Int,
                                          completion: BookmarkConvertedBackgroundThreadCompletion? = nil) {
        
        swapIsFavorite(bookmarkID, newIndex: newIndex, completion: completion)
    }
    
    public func delete(_ bookmarkItemID: NSManagedObjectID, completion: BookmarkItemDeletedBackgroundThreadCompletion? = nil) {
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform {

            let mo = try? privateContext.existingObject(with: bookmarkItemID)
            guard let item = mo as? BookmarkItemManagedObject else {
                assertionFailure("Failed to get item")
                completion?(false, .fetchingExistingItemFailed)
                return
            }
            
            privateContext.delete(item)
            
            do {
                try privateContext.save()
            } catch {
                assertionFailure("Updating item failed")
                completion?(false, .contextSaveError)
                return
            }
            
            completion?(true, nil)
        }
    }

    // MARK: Import Bookmarks
    public func importBookmarks(_ bookmarks: [BookmarkOrFolder]) async throws {
        guard let topLevelBookmarksFolder = topLevelBookmarksFolder else {
            throw BookmarksCoreDataStorageError.fetchingExistingItemFailed
        }

        try await recursivelyCreateEntities(from: bookmarks,
                                  parent: topLevelBookmarksFolder,
                                  in: viewContext)
    }

    private func recursivelyCreateEntities(from bookmarks: [BookmarkOrFolder],
                                           parent: BookmarkItemManagedObject,
                                           in context: NSManagedObjectContext) async throws {
        for bookmarkOrFolder in bookmarks {
            if bookmarkOrFolder.isInvalidBookmark {
                continue
            }

            switch bookmarkOrFolder.type {
            case .folder:
                let folderManagedObjectID = try await saveNewFolder(withTitle: bookmarkOrFolder.name, parentID: parent.objectID)
                if let children = bookmarkOrFolder.children, let bookmarkFolderManagedObject = await getFolder(objectID: folderManagedObjectID) {
                    try await recursivelyCreateEntities(from: children, parent: bookmarkFolderManagedObject, in: context)
                }
            case .favorite:
                if let url = bookmarkOrFolder.url, await !containsBookmark(url: url, searchType: .favoritesOnly) {
                    _ = try await saveNewFavorite(withTitle: bookmarkOrFolder.name, url: url)
                }
            case .bookmark:
                if let url = bookmarkOrFolder.url {
                    if parent == topLevelBookmarksFolder,
                       await containsBookmark(url: url, searchType: .topLevelBookmarksOnly, parentId: parent.objectID) {
                        continue
                    } else {
                        _ = try await saveNewBookmark(withTitle: bookmarkOrFolder.name, url: url, parentID: parent.objectID)
                    }
                }
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
    
    public func favoritesUncachedForWidget(completion: @escaping ([BookmarkManagedObject]) -> Void) {
        Task {
            guard await hasTopLevelFolder() else {
                completion([])
                return
            }
            
            getTopLevelFolder(isFavorite: true, onContext: viewContext) { folder in
                let children = folder.children?.array as? [BookmarkItemManagedObject] ?? []
                let favorites: [BookmarkManagedObject] = children.map {
                    if let fav = $0 as? BookmarkManagedObject {
                        return fav
                    } else {
                        fatalError("Favourites shouldn't contain folders")
                    }
                }
                completion(favorites)
            }
        }
    }
    
    private func hasTopLevelFolder() async -> Bool {
        return await withCheckedContinuation { continuation in
            viewContext.perform { [weak self] in
                let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
                let count = (try? self?.viewContext.count(for: fetchRequest)) ?? 0
                continuation.resume(returning: count > 0)
            }
        }
    }
}

// MARK: respond to data updates
extension BookmarksCoreDataStorage {
            
    @objc func contextDidSave(notification: Notification) {
        guard let sender = notification.object as? NSManagedObjectContext else { return }
        
        if sender.name == Constants.privateContextName {
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
    
    private func swapIsFavorite(_ bookmarkID: NSManagedObjectID, newIndex: Int, completion: BookmarkConvertedBackgroundThreadCompletion? = nil) {
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform { [weak self] in
            guard let self = self else {
                completion?(false, .storeDeallocated)
                return
            }

            let mo = try? privateContext.existingObject(with: bookmarkID)
            guard let bookmark = mo as? BookmarkManagedObject else {
                assertionFailure("Failed to get item")
                completion?(false, .fetchingExistingItemFailed)
                return
            }
            
            self.getTopLevelFolder(isFavorite: !bookmark.isFavorite, onContext: privateContext) { newParent in
                
                bookmark.isFavorite = !bookmark.isFavorite
                newParent.insertIntoChildren(bookmark, at: newIndex)
                
                do {
                    try privateContext.save()
                } catch {
                    assertionFailure("Updating item failed")
                    completion?(false, .contextSaveError)
                    return
                }
                completion?(true, nil)
            }
        }
    }
    
    internal enum SearchType {
        case bookmarksOnly
        case favoritesOnly
        case bookmarksAndFavorites
        case topLevelBookmarksOnly
    }
    
    private func containsBookmark(url: URL,
                                  searchType: SearchType,
                                  parentId: NSManagedObjectID? = nil,
                                  completion: @escaping BookmarkExistsMainThreadCompletion) {
        viewContext.perform {
            let fetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
            fetchRequest.fetchLimit = 1
            
            switch searchType {
            case .bookmarksOnly:
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == false",
                                                     #keyPath(BookmarkManagedObject.url),
                                                     url as NSURL,
                                                     #keyPath(BookmarkManagedObject.isFavorite))
            case .favoritesOnly:
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == true",
                                                     #keyPath(BookmarkManagedObject.url),
                                                     url as NSURL,
                                                     #keyPath(BookmarkManagedObject.isFavorite))
            case .bookmarksAndFavorites:
                fetchRequest.predicate = NSPredicate(format: "%K == %@",
                                                     #keyPath(BookmarkManagedObject.url),
                                                     url as NSURL)
            case .topLevelBookmarksOnly:
                guard let parentId = parentId else {
                    completion(false)
                    return
                }
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == false AND %K == %@",
                                                     #keyPath(BookmarkManagedObject.url),
                                                     url as NSURL,
                                                     #keyPath(BookmarkManagedObject.isFavorite),
                                                     #keyPath(BookmarkManagedObject.parent),
                                                     parentId)
            }
            
            guard let result = try? self.viewContext.count(for: fetchRequest) else {
                completion(false)
                return
            }
            completion(result > 0)
        }
    }
    
    internal func containsBookmark(url: URL, searchType: SearchType, parentId: NSManagedObjectID? = nil) async -> Bool {
        return await withCheckedContinuation({ continuation in
            containsBookmark(url: url, searchType: searchType, parentId: parentId) { exists in
                return continuation.resume(returning: exists)
            }
        })
    }

    // MainActor added - crashes when called from Favicons without using main thread
    @MainActor func containsDomain(_ domain: String) async -> Bool {
        let bookmarks = await allBookmarksAndFavoritesFlat()
        return bookmarks.first(where: { $0.url?.host == domain }) != nil
    }

    private func getTopLevelFolder(isFavorite: Bool,
                                   onContext context: NSManagedObjectContext,
                                   completion: @escaping (BookmarkFolderManagedObject) -> Void) {
        
        context.perform {
            
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == %@",
                                                 #keyPath(BookmarkManagedObject.parent),
                                                 #keyPath(BookmarkManagedObject.isFavorite),
                                                 NSNumber(value: isFavorite))
            
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
    
    func getFolder(objectID: NSManagedObjectID,
                   onContext context: NSManagedObjectContext,
                   completion: @escaping (BookmarkFolderManagedObject?) -> Void) {

        context.perform {

            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "SELF == %@", objectID)

            let results = try? context.fetch(fetchRequest)

            guard let folder = results?.first else {
                os_log("folder not found")
                completion(nil)
                return
            }

            completion(folder)
        }
    }

    func getFolder(objectID: NSManagedObjectID) async -> BookmarkFolderManagedObject? {
        return await withCheckedContinuation { continuation in
            getFolder(objectID: objectID, onContext: viewContext) { bookmarkFolderManagedObject in
                continuation.resume(returning: bookmarkFolderManagedObject)
            }
        }
    }

    internal func cacheReadOnlyTopLevelBookmarksFolder() {
        
        viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == false",
                                                 #keyPath(BookmarkManagedObject.parent),
                                                 #keyPath(BookmarkManagedObject.isFavorite))
            
            let results = try? viewContext.fetch(fetchRequest)
            guard (results?.count ?? 0) <= 1 else {
              
                let count = results?.count ?? 0
                let pixelParam = [PixelParameters.bookmarkErrorOrphanedFolderCount: "\(count)"]
                
                Pixel.fire(pixel: .debugBookmarkOrphanFolder, withAdditionalParameters: pixelParam)
                Thread.sleep(forTimeInterval: 1)
                fatalError("There shouldn't be an orphaned folder")
            }
            
            guard let folder = results?.first else {
                Pixel.fire(pixel: .debugBookmarkTopLevelMissing)
                Thread.sleep(forTimeInterval: 1)
                fatalError("Top level folder missing")
            }
            
            self.cachedReadOnlyTopLevelBookmarksFolder = folder
        }
    }
    
    internal func cacheReadOnlyTopLevelFavoritesFolder() {
        viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == true",
                                                 #keyPath(BookmarkManagedObject.parent),
                                                 #keyPath(BookmarkManagedObject.isFavorite))
            
            let results = try? viewContext.fetch(fetchRequest)
            guard (results?.count ?? 0) <= 1 else {
                let count = results?.count ?? 0
                let pixelParam = [PixelParameters.bookmarkErrorOrphanedFolderCount: "\(count)"]

                Pixel.fire(pixel: .debugFavoriteOrphanFolder, withAdditionalParameters: pixelParam)
                Thread.sleep(forTimeInterval: 1)
                fatalError("There shouldn't be an orphaned folder")
            }
            
            guard let folder = results?.first else {
                Pixel.fire(pixel: .debugFavoriteTopLevelMissing)
                Thread.sleep(forTimeInterval: 1)
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
    
    private func createBookmark(url: URL,
                                title: String,
                                isFavorite: Bool,
                                parentID: NSManagedObjectID? = nil,
                                completion: BookmarkItemSavedMainThreadCompletion? = nil) {
        
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform { [weak self] in
            guard let self = self else {
                assertionFailure("self nil when creating bookmark")
                completion?(nil, .storeDeallocated)
                return
            }
        
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.bookmarkClassName, into: privateContext)
            guard let bookmark = managedObject as? BookmarkManagedObject else {
                assertionFailure("Inserting new bookmark failed")
                completion?(nil, .insertObjectFailed)
                return
            }
            bookmark.url = url
            bookmark.title = title
            bookmark.isFavorite = isFavorite
            
            self.updateParentAndSave(of: bookmark, parentID: parentID, context: privateContext, completion: completion)
        }
    }
    
    private func createFolder(title: String,
                              isFavorite: Bool,
                              parentID: NSManagedObjectID? = nil,
                              completion: BookmarkItemSavedMainThreadCompletion? = nil) {
        
        let privateContext = getTemporaryPrivateContext()
        privateContext.perform { [weak self] in
            guard let self = self else {
                assertionFailure("self nil when creating folder")
                completion?(nil, .storeDeallocated)
                return
            }
            
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: Constants.folderClassName, into: privateContext)
            guard let folder = managedObject as? BookmarkFolderManagedObject else {
                assertionFailure("Inserting new folder failed")
                completion?(nil, .insertObjectFailed)
                return
            }
            folder.title = title
            folder.isFavorite = isFavorite
            
            self.updateParentAndSave(of: folder, parentID: parentID, context: privateContext, completion: completion)
        }
    }
    
    private func updateParentAndSave(of item: BookmarkItemManagedObject,
                                     parentID: NSManagedObjectID?,
                                     context: NSManagedObjectContext,
                                     completion: BookmarkItemSavedMainThreadCompletion? = nil) {
        
        func updateParentAndSave(parent: BookmarkFolderManagedObject) {
            item.parent = parent
            
            do {
                try context.save()
            } catch {
                assertionFailure("Saving item failed")
                completion?(nil, .contextSaveError)
                return
            }
            
            DispatchQueue.main.async {
                completion?(item.objectID, nil)
            }
        }
        
        if let parentID = parentID {
            let parentMO = try? context.existingObject(with: parentID)
            guard let newParentMO = parentMO as? BookmarkFolderManagedObject else {
                assertionFailure("Failed to get new parent")
                completion?(nil, .fetchingParentFailed)
                return
            }
            updateParentAndSave(parent: newParentMO)
        } else {
            self.getTopLevelFolder(isFavorite: item.isFavorite, onContext: context) { parent in
                updateParentAndSave(parent: parent)
            }
        }
    }
}

// MARK: Constants
extension BookmarksCoreDataStorage {
    enum Constants {
        static let privateContextName = "EditBookmarksAndFolders"
        static let viewContextName = "ViewBookmarksAndFolders"

        static let bookmarkClassName = "BookmarkManagedObject"
        static let folderClassName = "BookmarkFolderManagedObject"

        static let databaseName = "BookmarksAndFolders"

        static let groupName = "\(Global.groupIdPrefix).bookmarks"
    }
}

public class BookmarksCoreDataStorageMigration {
    
    @UserDefaultsWrapper(key: .bookmarksMigratedFromUserDefaultsToCD, defaultValue: false)
    private static var migratedFromUserDefaults: Bool
    
    /// Migrates bookmark data to Core Data.
    ///
    /// - Returns: A boolean representing whether the migration took place. If the migration has already happened and this function is called, it returns `false`.
    public static func migrate(fromBookmarkStore bookmarkStore: BookmarkStore, context: NSManagedObjectContext) -> Bool {
        if migratedFromUserDefaults {
            return false
        }
        
        context.performAndWait {
            let countRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: BookmarksCoreDataStorage.Constants.folderClassName)
            countRequest.fetchLimit = 1
            let result = (try? context.count(for: countRequest)) ?? 0
            
            guard result == 0 else {
                // Already migrated
                return
            }
            
            let favoritesFolder = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(context)
            let bookmarksFolder = BookmarksCoreDataStorage.rootFolderManagedObject(context)
            
            func migrateLink(_ link: Link, isFavorite: Bool) {
                let managedObject = NSEntityDescription.insertNewObject(
                    forEntityName: BookmarksCoreDataStorage.Constants.bookmarkClassName,
                    into: context)
                guard let bookmark = managedObject as? BookmarkManagedObject else {
                    assertionFailure("Inserting new bookmark failed")
                    return
                }
                bookmark.url = link.url
                bookmark.title = link.title
                bookmark.isFavorite = isFavorite
                
                let folder = isFavorite ? favoritesFolder : bookmarksFolder
                bookmark.parent = folder
            }
            
            let favorites = bookmarkStore.favorites
            for favorite in favorites {
                migrateLink(favorite, isFavorite: true)
            }
            
            let bookmarks = bookmarkStore.bookmarks
            for bookmark in bookmarks {
                migrateLink(bookmark, isFavorite: false)
            }
                        
            do {
                try context.save()
            } catch {
                fatalError("Error creating top level bookmark folders")
            }
            
            bookmarkStore.deleteAllData()
        }

        migratedFromUserDefaults = true
        return true
    }
}

// swiftlint:enable file_length
