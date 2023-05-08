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
import Bookmarks

public class LegacyBookmarksCoreDataStorage {
    
    private let storeLoadedCondition = RunLoop.ResumeCondition()
    internal var persistentContainer: NSPersistentContainer
    
    public lazy var viewContext: NSManagedObjectContext = {
        RunLoop.current.run(until: storeLoadedCondition)
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy(merge: .rollbackMergePolicyType)
        context.name = Constants.viewContextName
        return context
    }()
    
    public func getTemporaryPrivateContext() -> NSManagedObjectContext {
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
    
    private var storeDescription: NSPersistentStoreDescription {
        return NSPersistentStoreDescription(url: storeURL)
    }
    
    public static var defaultStoreURL: URL {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: BookmarksDatabase.Constants.bookmarksGroupID)!
        return containerURL.appendingPathComponent("\(Constants.databaseName).sqlite")
    }
    
    private let storeURL: URL
    
    public init?(storeURL: URL = defaultStoreURL, createIfNeeded: Bool = false) {
        if !FileManager.default.fileExists(atPath: storeURL.path),
           createIfNeeded == false {
            return nil
        }
        
        self.storeURL = storeURL
        
        persistentContainer = NSPersistentContainer(name: Constants.databaseName, managedObjectModel: Self.managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
    }
    
    public func removeStore() {
        
        typealias StoreInfo = (url: URL?, type: String)
        
        do {
            var storesToDelete = [StoreInfo]()
            for store in persistentContainer.persistentStoreCoordinator.persistentStores {
                storesToDelete.append((url: store.url, type: store.type))
                try persistentContainer.persistentStoreCoordinator.remove(store)
            }
            
            for (url, type) in storesToDelete {
                if let url = url {
                    try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url,
                                                                                              ofType: type)
                }
            }
        } catch {
            Pixel.fire(pixel: .bookmarksMigrationCouldNotRemoveOldStore,
                       error: error)
        }
        
        try? FileManager.default.removeItem(atPath: storeURL.path)
        try? FileManager.default.removeItem(atPath: storeURL.path.appending("-wal"))
        try? FileManager.default.removeItem(atPath: storeURL.path.appending("-shm"))
    }
    
    public func loadStoreAndCaches(andMigrate handler: @escaping (NSManagedObjectContext) -> Void = { _ in }) {
        
        loadStore(andMigrate: handler)
        
        RunLoop.current.run(until: storeLoadedCondition)
        cacheReadOnlyTopLevelBookmarksFolder()
        cacheReadOnlyTopLevelFavoritesFolder()
    }
    
    internal func loadStore(andMigrate handler: @escaping (NSManagedObjectContext) -> Void = { _ in }) {

        persistentContainer = NSPersistentContainer(name: Constants.databaseName, managedObjectModel: Self.managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
            context.name = "Migration"
            context.performAndWait {
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
extension LegacyBookmarksCoreDataStorage {
    
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

}

// MARK: private
extension LegacyBookmarksCoreDataStorage {

    internal enum TopLevelFolderType {
        case favorite
        case bookmark
    }
    
    /*
     This function will return nil if the database desired structure is not met
     i.e: If there are more than one root level folder OR
     if there is less than one root level folder
     */
    internal func fetchReadOnlyTopLevelFolder(withFolderType
                                             folderType: TopLevelFolderType) -> BookmarkFolderManagedObject? {
        
        var folder: BookmarkFolderManagedObject?
        
        viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == %@",
                                                 #keyPath(BookmarkManagedObject.parent),
                                                 #keyPath(BookmarkManagedObject.isFavorite),
                                                 NSNumber(value: folderType == .favorite))
            
            let results = try? viewContext.fetch(fetchRequest)
            guard (results?.count ?? 0) == 1,
                  let fetchedFolder = results?.first else {
                return
            }

            folder = fetchedFolder
        }
        return folder
    }
    
    internal func cacheReadOnlyTopLevelBookmarksFolder() {
        guard let folder = fetchReadOnlyTopLevelFolder(withFolderType: .bookmark) else {
            fixFolderDataStructure(withFolderType: .bookmark)
            
            // https://app.asana.com/0/414709148257752/1202779945035904/f
            guard let fixedFolder = fetchReadOnlyTopLevelFolder(withFolderType: .bookmark) else {
                Pixel.fire(pixel: .debugCouldNotFixBookmarkFolder)
                Thread.sleep(forTimeInterval: 1)
                fatalError("Coudn't fix bookmark folder")
            }
            self.cachedReadOnlyTopLevelBookmarksFolder = fixedFolder
            return
        }
        self.cachedReadOnlyTopLevelBookmarksFolder = folder
    }
    
    internal func cacheReadOnlyTopLevelFavoritesFolder() {
        guard let folder = fetchReadOnlyTopLevelFolder(withFolderType: .favorite) else {
            fixFolderDataStructure(withFolderType: .favorite)
            
            // https://app.asana.com/0/414709148257752/1202779945035904/f
            guard let fixedFolder = fetchReadOnlyTopLevelFolder(withFolderType: .favorite) else {
                Pixel.fire(pixel: .debugCouldNotFixFavoriteFolder)
                Thread.sleep(forTimeInterval: 1)
                fatalError("Coudn't fix favorite folder")
            }
            self.cachedReadOnlyTopLevelFavoritesFolder = fixedFolder
            return
        }
        self.cachedReadOnlyTopLevelFavoritesFolder = folder
    }

}

// MARK: Constants
extension LegacyBookmarksCoreDataStorage {
    enum Constants {
        static let privateContextName = "EditBookmarksAndFolders"
        static let viewContextName = "ViewBookmarksAndFolders"

        static let bookmarkClassName = "BookmarkManagedObject"
        static let folderClassName = "BookmarkFolderManagedObject"

        static let databaseName = "BookmarksAndFolders"
    }
}

// MARK: - CoreData structure fixer
// https://app.asana.com/0/414709148257752/1202779945035904/f
// This is a temporary workaround, do not use the following functions for anything else

extension LegacyBookmarksCoreDataStorage {
    
    private func deleteExtraOrphanedFolders(_ orphanedFolders: [BookmarkFolderManagedObject],
                                            onContext context: NSManagedObjectContext,
                                            withFolderType folderType: TopLevelFolderType) {
        let count = orphanedFolders.count
        let pixelParam = [PixelParameters.bookmarkErrorOrphanedFolderCount: "\(count)"]
        
        if folderType == .favorite {
            Pixel.fire(pixel: .debugFavoriteOrphanFolderNew, withAdditionalParameters: pixelParam)
        } else {
            Pixel.fire(pixel: .debugBookmarkOrphanFolderNew, withAdditionalParameters: pixelParam)
        }
        
        // Sort all orphaned folders by number of children
        let sorted = orphanedFolders.sorted { ($0.children?.count ?? 0) > ($1.children?.count ?? 0) }
        
        // Get the folder with the highest number of children
        let folderWithMoreChildren = sorted.first
        
        // Separate the other folders
        let otherFolders = sorted.suffix(from: 1)

        // Move all children from other folders to the one with highest count and delete the folder
        otherFolders.forEach { folder in
            if let children = folder.children {
                folderWithMoreChildren?.addToChildren(children)
                folder.children = nil
            }
            context.delete(folder)
        }
    }
    
    /*
     Top level (orphaned) folders need to match its type
     i.e: Favorites and Bookmarks each have their own root folder
     */
    private func createMissingTopLevelFolder(onContext context: NSManagedObjectContext,
                                             withFolderType folderType: TopLevelFolderType) {
        if folderType == .favorite {
            Pixel.fire(pixel: .debugFavoriteTopLevelMissingNew)
        } else {
            Pixel.fire(pixel: .debugBookmarkTopLevelMissingNew)
        }

        // Get all bookmarks
        let bookmarksFetchRequest = NSFetchRequest<BookmarkManagedObject>(entityName: Constants.bookmarkClassName)
        bookmarksFetchRequest.predicate = NSPredicate(format: " %K == %@",
                                                      #keyPath(BookmarkManagedObject.isFavorite),
                                                      NSNumber(value: folderType == .favorite))
        bookmarksFetchRequest.returnsObjectsAsFaults = false

        let bookmarks = try? context.fetch(bookmarksFetchRequest)
        
        if bookmarks?.count ?? 0 > 0 {
            if folderType == .favorite {
                Pixel.fire(pixel: .debugMissingTopFolderFixHasFavorites)
            } else {
                Pixel.fire(pixel: .debugMissingTopFolderFixHasBookmarks)
            }
        }
        
        // Create root folder for the specified folder type
        let bookmarksFolder: BookmarkFolderManagedObject
        if folderType == .favorite {
            bookmarksFolder = Self.rootFavoritesFolderManagedObject(context)
        } else {
            bookmarksFolder = Self.rootFolderManagedObject(context)
        }
        
        // Assign all bookmarks to the parent folder
        bookmarks?.forEach {
            $0.parent = bookmarksFolder
        }
    }
    
    internal func fixFolderDataStructure(withFolderType folderType: TopLevelFolderType) {
        let privateContext = getTemporaryPrivateContext()
        
        privateContext.performAndWait {
            let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: Constants.folderClassName)
            fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == %@",
                                                 #keyPath(BookmarkManagedObject.parent),
                                                 #keyPath(BookmarkManagedObject.isFavorite),
                                                 NSNumber(value: folderType == .favorite))
            
            let results = try? privateContext.fetch(fetchRequest)
            
            if let orphanedFolders = results, orphanedFolders.count > 1 {
                deleteExtraOrphanedFolders(orphanedFolders, onContext: privateContext, withFolderType: folderType)
            } else {
                createMissingTopLevelFolder(onContext: privateContext, withFolderType: folderType)
            }
            
            do {
                try privateContext.save()
            } catch {
                Pixel.fire(pixel: .debugCantSaveBookmarkFix)
                assertionFailure("Failure saving bookmark top folder fix")
            }
        }
    }
}
