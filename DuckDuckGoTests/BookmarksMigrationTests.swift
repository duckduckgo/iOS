//
//  BookmarksMigrationTests.swift
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

import XCTest
import CoreData
import Bookmarks
@testable import Core
@testable import DuckDuckGo

@MainActor
class BookmarksMigrationTests: XCTestCase {
    
    let destinationStack = MockBookmarksDatabase.make(prepareFolderStructure: false)
    var sourceStack: LegacyBookmarksCoreDataStorage!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let containerLocation = MockBookmarksDatabase.tempDBDir()
        try FileManager.default.createDirectory(at: containerLocation, withIntermediateDirectories: true)
        
        sourceStack = LegacyBookmarksCoreDataStorage(storeURL: containerLocation.appendingPathComponent("OldBookmarks.sqlite"),
                                                    createIfNeeded: true)
        sourceStack.loadStoreAndCaches()
        try await prepareDB(with: sourceStack)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        
        try destinationStack.tearDown(deleteStores: true)
    }
    
    private func url(for title: String) -> URL {
        URL(string: "https://\(title).com")!
    }
    
    func prepareDB(with bookmarksDB: LegacyBookmarksCoreDataStorage) async throws {
        
        guard let topLevelBookmarksFolder = bookmarksDB.topLevelBookmarksFolder else {
            XCTFail("Missing folder structure")
            return
        }
        
        // Bookmarks:
        // One
        // Folder A /
        //   - Two
        //   - Folder B/
        //       - Three
        
        _ = try await bookmarksDB.saveNewBookmark(withTitle: "One", url: url(for: "one"), parentID: nil)
        let fAId = try await bookmarksDB.saveNewFolder(withTitle: "Folder A", parentID: topLevelBookmarksFolder.objectID)
        
        _ = try await bookmarksDB.saveNewBookmark(withTitle: "Two", url: url(for: "two"), parentID: fAId)
        let fBId = try await bookmarksDB.saveNewFolder(withTitle: "Folder B", parentID: fAId)
        
        _ = try await bookmarksDB.saveNewBookmark(withTitle: "Three", url: url(for: "three"), parentID: fBId)
        
        // Favorites:
        // First
        // Two (duplicate)
        // Third
        
        _ = try await bookmarksDB.saveNewFavorite(withTitle: "First", url: url(for: "first"))
        _ = try await bookmarksDB.saveNewFavorite(withTitle: "Two", url: url(for: "two"))
        _ = try await bookmarksDB.saveNewFavorite(withTitle: "Third", url: url(for: "third"))
        
        bookmarksDB.viewContext.refreshAllObjects()
        XCTAssert((topLevelBookmarksFolder.children?.count ?? 0) > 0)
    }
    
    func testWhenThereIsNoDatabaseThenLegacyStackIsNotCreated() {
        let tempURL = MockBookmarksDatabase.tempDBDir().appendingPathComponent("OldBookmarks.sqlite")
        let legacyStore = LegacyBookmarksCoreDataStorage(storeURL: tempURL)
        XCTAssertNil(legacyStore)
    }
    
    func testWhenNothingToMigrateFromThenNewStackIsInitialized() throws {
        
        let context = destinationStack.makeContext(concurrencyType: .mainQueueConcurrencyType)
        XCTAssertNil(BookmarkUtils.fetchRootFolder(context))
        
        LegacyBookmarksStoreMigration.migrate(from: nil, to: context)
        
        XCTAssertNotNil(BookmarkUtils.fetchRootFolder(context))
        XCTAssertEqual(BookmarkUtils.fetchFavoritesFolders(withUUIDs: Set(FavoritesFolderID.allCases.map(\.rawValue)), in: context).count, 1)
        
        // Simulate subsequent app instantiations
        LegacyBookmarksStoreMigration.migrate(from: nil, to: context)
        LegacyBookmarksStoreMigration.migrate(from: nil, to: context)
        
        let countRequest = BookmarkEntity.fetchRequest()
        countRequest.predicate = NSPredicate(value: true)
        
        let count = try context.count(for: countRequest)
        XCTAssertEqual(count, 2)
    }
    
    func testWhenRegularMigrationIsNeededThenItIsDoneAndDataIsDeduplicated() {
        
        let context = destinationStack.makeContext(concurrencyType: .mainQueueConcurrencyType)
        LegacyBookmarksStoreMigration.migrate(from: sourceStack, to: context)
        
        XCTAssertNotNil(BookmarkUtils.fetchRootFolder(context))
        XCTAssertEqual(
            BookmarkUtils.fetchFavoritesFolders(withUUIDs: Set(FavoritesFolderID.allCases.map(\.rawValue)), in: context).count,
            FavoritesFolderID.allCases.count
        )

        let topLevel = BookmarkListViewModel(
            bookmarksDatabase: destinationStack,
            parentID: nil,
            favoritesDisplayMode: .displayNative(.mobile),
            syncService: nil
        )

        XCTAssertEqual(topLevel.bookmarks.count, 4)
        
        let topLevelNames = topLevel.bookmarks.map { $0.title }
        // Order matters: first favorites (minus duplicates), then bookmarks
        XCTAssertEqual(topLevelNames, ["First", "Third", "One", "Folder A"])
        
        let favFirst = topLevel.bookmarks[0]
        XCTAssertEqual(favFirst.isFolder, false)
        XCTAssertEqual(favFirst.isFavorite(on: .mobile), true)
        XCTAssertEqual(favFirst.title, "First")
        XCTAssertEqual(favFirst.url, url(for: "first").absoluteString)

        let favThird = topLevel.bookmarks[1]
        XCTAssertEqual(favThird.isFolder, false)
        XCTAssertEqual(favThird.isFavorite(on: .mobile), true)
        XCTAssertEqual(favThird.title, "Third")
        
        let bookOne = topLevel.bookmarks[2]
        XCTAssertEqual(bookOne.isFolder, false)
        XCTAssertEqual(bookOne.isFavorite(on: .mobile), false)
        XCTAssertEqual(bookOne.title, "One")

        let folderA = topLevel.bookmarks[3]
        XCTAssertEqual(folderA.title, "Folder A")
        XCTAssertTrue(folderA.isFolder)

        let folderAContents = folderA.childrenArray
        XCTAssertEqual(folderAContents[0].isFolder, false)
        XCTAssertEqual(folderAContents[0].isFavorite(on: .mobile), true)
        XCTAssertEqual(folderAContents[0].title, "Two")

        let folderB = folderAContents[1]
        XCTAssertEqual(folderB.title, "Folder B")
        XCTAssertTrue(folderB.isFolder)

        let folderBContents = folderB.childrenArray
        XCTAssertEqual(folderBContents.count, 1)
        XCTAssertEqual(folderBContents[0].isFolder, false)
        XCTAssertEqual(folderBContents[0].isFavorite(on: .mobile), false)
        XCTAssertEqual(folderBContents[0].title, "Three")
    }
    
}

public enum LegacyBookmarksCoreDataStorageError: Error {
    case storeDeallocated
    case fetchingExistingItemFailed
    case fetchingParentFailed
    case insertObjectFailed
    case contextSaveError
}

public typealias BookmarkItemSavedMainThreadCompletion = ((NSManagedObjectID?, LegacyBookmarksCoreDataStorageError?) -> Void)

extension LegacyBookmarksCoreDataStorage {
    
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
                    return continuation.resume(throwing: LegacyBookmarksCoreDataStorageError.contextSaveError)
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
                    return continuation.resume(throwing: LegacyBookmarksCoreDataStorageError.contextSaveError)
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
                    return continuation.resume(throwing: LegacyBookmarksCoreDataStorageError.contextSaveError)
                }
                
                return continuation.resume(returning: managedObjectID)
            }
        }
    }
    
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
