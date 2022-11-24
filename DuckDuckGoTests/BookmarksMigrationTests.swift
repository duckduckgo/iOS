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
    
    let destinationStack = BookmarksDatabase.make(location: MockBookmarksDatabase.tempDBDir())
    var sourceStack: BookmarksCoreDataStorage!
    
    override func setUp() async throws {
        try await super.setUp()
        
        destinationStack.loadStore()
        
        let containerLocation = MockBookmarksDatabase.tempDBDir()
        try FileManager.default.createDirectory(at: containerLocation, withIntermediateDirectories: true)
        
        sourceStack = BookmarksCoreDataStorage.init(storeURL: containerLocation.appendingPathComponent("OldBookmarks.sqlite"),
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
    
    func prepareDB(with bookmarksDB: BookmarksCoreDataStorage) async throws {
        
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
        let legacyStore = BookmarksCoreDataStorage.init(storeURL: tempURL)
        XCTAssertNil(legacyStore)
    }
    
    func testWhenNothingToMigrateFromThenNewStackIsInitialized() throws {
        
        let context = destinationStack.makeContext(concurrencyType: .mainQueueConcurrencyType)
        XCTAssertNil(BookmarkUtils.fetchRootFolder(context))
        
        LegacyBookmarksStoreMigration.migrate(from: nil, to: context)
        
        XCTAssertNotNil(BookmarkUtils.fetchRootFolder(context))
        XCTAssertNotNil(BookmarkUtils.fetchFavoritesFolder(context))
        
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
        XCTAssertNotNil(BookmarkUtils.fetchFavoritesFolder(context))
        
        let topLevel = BookmarkListViewModel(bookmarksDatabaseStack: destinationStack, parentID: nil)
        XCTAssertEqual(topLevel.bookmarks.count, 4)
        
        let topLevelNames = topLevel.bookmarks.map { $0.title }
        // Order matters: first favorites (minus duplicates), then bookmarks
        XCTAssertEqual(topLevelNames, ["First", "Third", "One", "Folder A"])
        
        let favFirst = topLevel.bookmarks[0]
        XCTAssertEqual(favFirst.isFolder, false)
        XCTAssertEqual(favFirst.isFavorite, true)
        XCTAssertEqual(favFirst.title, "First")
        XCTAssertEqual(favFirst.url, url(for: "first").absoluteString)

        let favThird = topLevel.bookmarks[1]
        XCTAssertEqual(favThird.isFolder, false)
        XCTAssertEqual(favThird.isFavorite, true)
        XCTAssertEqual(favThird.title, "Third")
        
        let bookOne = topLevel.bookmarks[2]
        XCTAssertEqual(bookOne.isFolder, false)
        XCTAssertEqual(bookOne.isFavorite, false)
        XCTAssertEqual(bookOne.title, "One")

        let folderA = topLevel.bookmarks[3]
        XCTAssertEqual(folderA.title, "Folder A")
        XCTAssertTrue(folderA.isFolder)

        let folderAContents = folderA.childrenArray
        XCTAssertEqual(folderAContents[0].isFolder, false)
        XCTAssertEqual(folderAContents[0].isFavorite, true)
        XCTAssertEqual(folderAContents[0].title, "Two")

        let folderB = folderAContents[1]
        XCTAssertEqual(folderB.title, "Folder B")
        XCTAssertTrue(folderB.isFolder)

        let folderBContents = folderB.childrenArray
        XCTAssertEqual(folderBContents.count, 1)
        XCTAssertEqual(folderBContents[0].isFolder, false)
        XCTAssertEqual(folderBContents[0].isFavorite, false)
        XCTAssertEqual(folderBContents[0].title, "Three")
    }
    
}
