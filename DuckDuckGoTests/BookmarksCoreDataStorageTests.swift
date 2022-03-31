//
//  BookmarksCoreDataStorageTests.swift
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
@testable import Core

class BookmarksCoreDataStorageTests: XCTestCase {

    private var storage: MockBookmarksCoreDataStore!

    override func setUpWithError() throws {
        try super.setUpWithError()

        storage = MockBookmarksCoreDataStore()
        _ = BookmarksCoreDataStorage.rootFolderManagedObject(storage.viewContext)
        _ = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(storage.viewContext)
        storage.saveContext()
        storage.loadStoreAndCaches { _ in }
    }

    override func tearDownWithError() throws {
        storage = nil

        try super.tearDownWithError()
    }

    func test_WhenBookmarksCoreDataStoreExists_ThenTopLevelBookmarksFolderMustExist() throws {
        XCTAssertNotNil(storage.topLevelBookmarksFolder)
    }

    func test_WhenBookmarksCoreDataStoreExists_ThenTopLevelFavoritesFolderMustExist() throws {
        XCTAssertNotNil(storage.topLevelFavoritesFolder)
    }

    func test_WhenSaveNewFavorite_ThenNewFavoriteExists() async throws {
        guard let favorites = storage.topLevelFavoritesFolder else {
            XCTFail("must have topLevelFavoritesFolder")
            return
        }

        let managedObjectID = try await storage.saveNewFavorite(withTitle: Constants.bookmarkTitle,
                                                                url: Constants.bookmarkURL)

        XCTAssertNotNil(managedObjectID)

        guard let favoriteManagedObject = try await storage.favorite(forURL: Constants.bookmarkURL) else {
            XCTFail("favorite should exist")
            return
        }

        XCTAssertNotNil(favoriteManagedObject)
        XCTAssertEqual(favoriteManagedObject.title, Constants.bookmarkTitle)
        XCTAssertEqual(favoriteManagedObject.parentFolder?.objectID, favorites.objectID)
        XCTAssertEqual(favoriteManagedObject.url, Constants.bookmarkURL)
    }

    func test_WhenRootFolderAndSaveNewFolder_ThenNewFolderExists() async throws {
        guard let topLevelBookMarksFolder = storage.topLevelBookmarksFolder else {
            XCTFail("must have topLevelBookMarkFolder")
            return
        }

        let title = "AFolder"
        let managedObjectID = try await storage.saveNewFolder(withTitle: "AFolder", parentID: topLevelBookMarksFolder.objectID)
        guard let bookmarkFolderManagedObject = await storage.getFolder(objectID: managedObjectID) else {
            XCTFail("Folder should exist")
            return
        }

        XCTAssertNotNil(bookmarkFolderManagedObject)
        XCTAssertNotNil(storage.topLevelBookmarksItems)
        XCTAssertEqual(storage.topLevelBookmarksItems.count, 1)
        XCTAssertEqual(bookmarkFolderManagedObject.parent?.objectID, topLevelBookMarksFolder.objectID)
        XCTAssertEqual(bookmarkFolderManagedObject.title, title)
    }

    func test_WhenSaveNewBookmarkAtRoot_ThenNewBookmarkExists() async throws {
        guard let topLevelBookMarksFolder = storage.topLevelBookmarksFolder else {
            XCTFail("must have topLevelBookMarkFolder")
            return
        }

        let managedObjectID = try await storage.saveNewBookmark(withTitle: Constants.bookmarkTitle,
                                                                url: Constants.bookmarkURL,
                                                                parentID: topLevelBookMarksFolder.objectID)
        XCTAssertNotNil(managedObjectID)

        guard let bookmarkManagedObject = await storage.bookmark(forURL: Constants.bookmarkURL) else {
            XCTFail("bookmark should exist")
            return
        }

        XCTAssertNotNil(bookmarkManagedObject)
        XCTAssertEqual(bookmarkManagedObject.title, Constants.bookmarkTitle)
        XCTAssertEqual(bookmarkManagedObject.parentFolder?.objectID, topLevelBookMarksFolder.objectID)
        XCTAssertEqual(bookmarkManagedObject.url, Constants.bookmarkURL)
    }

    func test_WhenSaveNestedFoldersAtRoot_ThenNestedFoldersExist() async throws {
        guard let topLevelBookMarksFolder = storage.topLevelBookmarksFolder else {
            XCTFail("must have topLevelBookMarkFolder")
            return
        }

        let titleOuterFolder = "OuterFolder"
        let managedObjectID1 = try await storage.saveNewFolder(withTitle: titleOuterFolder, parentID: topLevelBookMarksFolder.objectID)

        guard let bookmarkFolderManagedObject1 = await storage.getFolder(objectID: managedObjectID1) else {
            XCTFail("Folder should exist")
            return
        }

        XCTAssertNotNil(bookmarkFolderManagedObject1)
        XCTAssertEqual(bookmarkFolderManagedObject1.parent?.objectID, topLevelBookMarksFolder.objectID)
        XCTAssertEqual(bookmarkFolderManagedObject1.title, titleOuterFolder)

        let titleInnerFolder = "InnerFolder"
        let managedObjectID2 = try await storage.saveNewFolder(withTitle: titleInnerFolder, parentID: managedObjectID1)

        guard let bookmarkFolderManagedObject2 = await storage.getFolder(objectID: managedObjectID2) else {
            XCTFail("Folder should exist")
            return
        }

        XCTAssertNotNil(bookmarkFolderManagedObject2)
        XCTAssertEqual(bookmarkFolderManagedObject2.parent?.objectID, managedObjectID1)
        XCTAssertEqual(bookmarkFolderManagedObject2.title, titleInnerFolder)
    }

    func test_WhenSaveBookmarkInFolder_ThenBookmarkExistsInFolder() async throws {
        guard let topLevelBookMarksFolder = storage.topLevelBookmarksFolder else {
            XCTFail("must have topLevelBookMarkFolder")
            return 
        }

        let folderManagedObjectID = try await storage.saveNewFolder(withTitle: "AFolder", parentID: topLevelBookMarksFolder.objectID)
        XCTAssertNotNil(folderManagedObjectID)

        let bookmarkManagedObjectID = try await storage.saveNewBookmark(withTitle: Constants.bookmarkTitle,
                                                                        url: Constants.bookmarkURL,
                                                                        parentID: folderManagedObjectID)
        XCTAssertNotNil(bookmarkManagedObjectID)

        guard let bookmarkManagedObject = await storage.bookmark(forURL: Constants.bookmarkURL) else {
            XCTFail("bookmark should exist")
            return
        }

        XCTAssertNotNil(bookmarkManagedObject)
        XCTAssertEqual(bookmarkManagedObject.title, Constants.bookmarkTitle)
        XCTAssertEqual(bookmarkManagedObject.parentFolder?.objectID, folderManagedObjectID)
        XCTAssertEqual(bookmarkManagedObject.url, Constants.bookmarkURL)
    }

    func test_WhenSaveTopLevelBookmark_AndBookmarkAlreadySavedInFolder_ThenBookmarkSaves() async throws {
        guard let topLevelBookMarksFolder = storage.topLevelBookmarksFolder else {
            XCTFail("must have topLevelBookMarkFolder")
            return
        }

        let folderManagedObjectID = try await storage.saveNewFolder(withTitle: "AFolder", parentID: topLevelBookMarksFolder.objectID)
        XCTAssertNotNil(folderManagedObjectID)

        let bookmarkManagedObjectID = try await storage.saveNewBookmark(withTitle: Constants.bookmarkTitle,
                                                                        url: Constants.bookmarkURL,
                                                                        parentID: folderManagedObjectID)
        XCTAssertNotNil(bookmarkManagedObjectID)

        guard let bookmarkManagedObject = await storage.bookmark(forURL: Constants.bookmarkURL) else {
            XCTFail("bookmark should exist")
            return
        }

        if let url = bookmarkManagedObject.url,
           await storage.containsBookmark(url: url, searchType: .topLevelBookmarksOnly, parentId: topLevelBookMarksFolder.objectID) {
            XCTFail("bookmark should not already exist at top level")
            return
        }

        let topLevelBookmarkManagedObjectID = try await storage.saveNewBookmark(withTitle: Constants.bookmarkTitle,
                                                                                url: Constants.bookmarkURL,
                                                                                parentID: topLevelBookMarksFolder.objectID)
        XCTAssertNotNil(topLevelBookmarkManagedObjectID)
    }

    func test_WhenSaveBookmarkInFolder_ThenAllBookmarksCountIsCorrect() async throws {
        guard let topLevelBookMarksFolder = storage.topLevelBookmarksFolder else {
            XCTFail("must have topLevelBookMarkFolder")
            return
        }

        let allBookmarksBefore = await storage.allBookmarksAndFavoritesFlat()
        XCTAssertEqual(allBookmarksBefore.count, 0)

        let folderManagedObjectID = try await storage.saveNewFolder(withTitle: "AFolder", parentID: topLevelBookMarksFolder.objectID)
        XCTAssertNotNil(folderManagedObjectID)

        let bookmarkManagedObjectID = try await storage.saveNewBookmark(withTitle: Constants.bookmarkTitle,
                                                                        url: Constants.bookmarkURL,
                                                                        parentID: folderManagedObjectID)
        XCTAssertNotNil(bookmarkManagedObjectID)

        let allBookmarksAfter = await storage.allBookmarksAndFavoritesFlat()
        XCTAssertEqual(allBookmarksAfter.count, 1)
    }
}

private extension BookmarksCoreDataStorageTests {
    enum Constants {
        static let bookmarkTitle = "my bookmark"
        static let bookmarkURL = URL(string: "https://duckduckgo.com")!
    }
}
