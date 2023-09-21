//
//  LegacyBookmarksStoreMigration.swift
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
import CoreData
import Bookmarks

public class LegacyBookmarksStoreMigration {
    
    internal enum LegacyTopLevelFolderType {
        case favorite
        case bookmark
    }
    
    public static func migrate(from legacyStorage: LegacyBookmarksCoreDataStorage?,
                               to context: NSManagedObjectContext) {
        if let legacyStorage = legacyStorage {
            // Perform migration from legacy store.
            let source = legacyStorage.getTemporaryPrivateContext()
            source.performAndWait {
                LegacyBookmarksStoreMigration.migrate(source: source,
                                                      destination: context)
            }
        } else {
            // Initialize structure if needed
            BookmarkUtils.prepareLegacyFoldersStructure(in: context)
            if context.hasChanges {
                do {
                    try context.save(onErrorFire: .bookmarksCouldNotPrepareDatabase)
                } catch {
                    Thread.sleep(forTimeInterval: 1)
                    fatalError("Could not prepare Bookmarks DB structure")
                }
            }
        }
    }
    
    private static func fetchTopLevelFolder(_ folderType: LegacyTopLevelFolderType,
                                            in context: NSManagedObjectContext) -> [BookmarkFolderManagedObject] {
        
        let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: LegacyBookmarksCoreDataStorage.Constants.folderClassName)
        fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == %@",
                                             #keyPath(BookmarkManagedObject.parent),
                                             #keyPath(BookmarkManagedObject.isFavorite),
                                             NSNumber(value: folderType == .favorite))
        
        guard let results = try? context.fetch(fetchRequest) else {
            return []
        }
        
        // In case of corruption, we can cat more than one 'root'
        return results
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    
    private static func migrate(source: NSManagedObjectContext, destination: NSManagedObjectContext) {
        
        // Do not migrate more than once
        guard BookmarkUtils.fetchRootFolder(destination) == nil else {
            Pixel.fire(pixel: .bookmarksMigrationAlreadyPerformed)
            return
        }
        
        BookmarkUtils.prepareFoldersStructure(in: destination)
        
        guard let newRoot = BookmarkUtils.fetchRootFolder(destination),
              let newFavoritesRoot = BookmarkUtils.fetchFavoritesFolder(withUUID: FavoritesFolderID.unified.rawValue, in: destination),
              let newMobileFavoritesRoot = BookmarkUtils.fetchFavoritesFolder(withUUID: FavoritesFolderID.mobile.rawValue, in: destination) else {
            Pixel.fire(pixel: .bookmarksMigrationCouldNotPrepareDatabase)
            Thread.sleep(forTimeInterval: 2)
            fatalError("Could not write to Bookmarks DB")
        }
        
        // Fetch all 'roots' in case we had some kind of inconsistency and duplicated objects
        let bookmarkRoots = fetchTopLevelFolder(.bookmark, in: source)
        let favoriteRoots = fetchTopLevelFolder(.favorite, in: source)
        
        var index = 0
        var folderMap = [NSManagedObjectID: BookmarkEntity]()
        
        var favoritesToMigrate = [BookmarkItemManagedObject]()
        var bookmarksToMigrate = [BookmarkItemManagedObject]()
        
        // Map old roots to new one, prepare list of top level bookmarks to migrate
        for folder in favoriteRoots {
            folderMap[folder.objectID] = newRoot
            
            favoritesToMigrate.append(contentsOf: folder.children?.array as? [BookmarkItemManagedObject] ?? [])
        }
        
        for folder in bookmarkRoots {
            folderMap[folder.objectID] = newRoot
            
            bookmarksToMigrate.append(contentsOf: folder.children?.array as? [BookmarkItemManagedObject] ?? [])
        }
        
        var urlToBookmarkMap = [URL: BookmarkEntity]()
        
        // Iterate over bookmarks to migrate
        while index < bookmarksToMigrate.count {
            
            let objectToMigrate = bookmarksToMigrate[index]
            
            guard let parent = objectToMigrate.parent,
                  let newParent = folderMap[parent.objectID],
                  let title = objectToMigrate.title else {
                // Pixel?
                index += 1
                continue
            }
            
            if let folder = objectToMigrate as? BookmarkFolderManagedObject {
                let newFolder = BookmarkEntity.makeFolder(title: title,
                                                          parent: newParent,
                                                          context: destination)
                folderMap[folder.objectID] = newFolder
                
                if let children = folder.children?.array as? [BookmarkItemManagedObject] {
                    bookmarksToMigrate.append(contentsOf: children)
                }
                
            } else if let bookmark = objectToMigrate as? BookmarkManagedObject,
                      let url = bookmark.url {
                
                let newBookmark = BookmarkEntity.makeBookmark(title: title,
                                                              url: url.absoluteString,
                                                              parent: newParent,
                                                              context: destination)
                
                urlToBookmarkMap[url] = newBookmark
            }
            
            index += 1
        }
        
        // Process favorites starting from the last one, so we preserve the order while adding at begining
        for favorite in favoritesToMigrate.reversed() {
            guard let favorite = favorite as? BookmarkManagedObject,
                  let title = favorite.title,
                  let url = favorite.url else { continue }
            
            let bookmark = {
                if let existingBookmark = urlToBookmarkMap[url] {
                    return existingBookmark
                } else {
                    return BookmarkEntity.makeBookmark(title: title,
                                                       url: url.absoluteString,
                                                       parent: newRoot,
                                                       insertAtBeginning: true,
                                                       context: destination)
                }
            }()
            bookmark.addToFavorites(insertAt: 0,
                                    favoritesRoot: newFavoritesRoot)
            bookmark.addToFavorites(insertAt: 0,
                                    favoritesRoot: newMobileFavoritesRoot)
        }
        
        do {
            try destination.save(onErrorFire: .bookmarksMigrationFailed)
        } catch {
            destination.reset()
            
            BookmarkUtils.prepareLegacyFoldersStructure(in: destination)
            do {
                try destination.save(onErrorFire: .bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration)
            } catch {
                Thread.sleep(forTimeInterval: 2)
                fatalError("Could not write to Bookmarks DB")
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

}
