//
//  BookmarksCoreDataFixTests.swift
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
@testable import Core

class BookmarksCoreDataFixTests: XCTestCase {
    private var storage: MockBookmarksCoreDataStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        storage = MockBookmarksCoreDataStore()
        storage.saveContext()
    }

    override func tearDownWithError() throws {
        storage = nil

        try super.tearDownWithError()
    }

    
    func test_WhenThereAreMultipleBookmarksOrphanedFolder_ThenTheyAreDeleted() {
        _ = BookmarksCoreDataStorage.rootFolderManagedObject(storage.viewContext)
        _ = BookmarksCoreDataStorage.rootFolderManagedObject(storage.viewContext)
        _ = BookmarksCoreDataStorage.rootFolderManagedObject(storage.viewContext)

        let expectedExceedingCount = 3
        let expectedFinalCount = 1

        let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: "BookmarkFolderManagedObject")
        fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == false",
                                             #keyPath(BookmarkManagedObject.parent),
                                             #keyPath(BookmarkManagedObject.isFavorite))
        
        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        // The structure is compromised, it should return nil
        var topLevelFolder = storage.fetchReadOnlyTopLevelFolder(withFolderType: .bookmark)
        XCTAssertNil(topLevelFolder)

        XCTAssertEqual(results.count, expectedExceedingCount)
        
        storage.fixFolderDataStructure(withFolderType: .bookmark)

        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        XCTAssertEqual(results.count, expectedFinalCount)
        
        topLevelFolder = storage.fetchReadOnlyTopLevelFolder(withFolderType: .bookmark)
        XCTAssertNotNil(topLevelFolder)
    }
    
    func test_WhenThereAreMultipleFavoritesOrphanedFolder_ThenTheyAreDeleted() {
        _ = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(storage.viewContext)
        _ = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(storage.viewContext)
        _ = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(storage.viewContext)

        let expectedExceedingCount = 3
        let expectedFinalCount = 1

        let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: "BookmarkFolderManagedObject")
        fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == true",
                                             #keyPath(BookmarkManagedObject.parent),
                                             #keyPath(BookmarkManagedObject.isFavorite))
        
        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        // The structure is compromised, it should return nil
        var topLevelFolder = storage.fetchReadOnlyTopLevelFolder(withFolderType: .favorite)
        XCTAssertNil(topLevelFolder)

        XCTAssertEqual(results.count, expectedExceedingCount)
        
        storage.fixFolderDataStructure(withFolderType: .favorite)

        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        XCTAssertEqual(results.count, expectedFinalCount)
        
        topLevelFolder = storage.fetchReadOnlyTopLevelFolder(withFolderType: .favorite)
        XCTAssertNotNil(topLevelFolder)
    }
    
    func test_WhenThereTheresNoBookmarkRootLevelFolder_ThenTheyCreated() {
        let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: "BookmarkFolderManagedObject")
        fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == false",
                                             #keyPath(BookmarkManagedObject.parent),
                                             #keyPath(BookmarkManagedObject.isFavorite))
        
        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        let expectedInitialCount = 0
        let expectedFinalCount = 1
        
        XCTAssertEqual(results.count, expectedInitialCount)
        
        storage.fixFolderDataStructure(withFolderType: .bookmark)
        
        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        XCTAssertEqual(results.count, expectedFinalCount)
    }
    
    func test_WhenThereTheresNoFavoriteRootLevelFolder_ThenTheyAreCreated() {
        let fetchRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: "BookmarkFolderManagedObject")
        fetchRequest.predicate = NSPredicate(format: "%K == nil AND %K == true",
                                             #keyPath(BookmarkManagedObject.parent),
                                             #keyPath(BookmarkManagedObject.isFavorite))
        
        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        let expectedInitialCount = 0
        let expectedFinalCount = 1
        
        XCTAssertEqual(results.count, expectedInitialCount)
        
        storage.fixFolderDataStructure(withFolderType: .favorite)
        
        guard let results = try? storage.viewContext.fetch(fetchRequest) else {
            XCTFail("Must have folders")
            return
        }
        
        XCTAssertEqual(results.count, expectedFinalCount)
    }
}
