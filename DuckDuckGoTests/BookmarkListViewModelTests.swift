//
//  BookmarkListViewModelTests.swift
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

import XCTest
import CoreData
import Common
import Persistence
import Bookmarks
import DuckDuckGo

private extension BookmarkListViewModel {
    
    convenience init(bookmarksDatabase: CoreDataDatabase,
                     parentID: NSManagedObjectID?,
                     favoritesDisplayMode: FavoritesDisplayMode) {
        self.init(bookmarksDatabase: bookmarksDatabase,
                  parentID: parentID,
                  favoritesDisplayMode: favoritesDisplayMode,
                  errorEvents: .init(mapping: { event, _, _, _ in
            XCTFail("Unexpected error: \(event)")
        }))
    }
}

class BookmarkListViewModelTests: XCTestCase {
    
    var db: CoreDataDatabase!
    var mainContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        
        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()
        
        self.mainContext = db.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "TestContext")
        BasicBookmarksStructure.populateDB(context: mainContext)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        mainContext.reset()
        mainContext = nil
        
        try db.tearDown(deleteStores: true)
    }

    func testWhenFolderIsSetThenBookmarksFetchedFromThatLocation() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        XCTAssertNotNil(viewModel.currentFolder?.objectID)
        XCTAssertEqual(viewModel.currentFolder?.objectID, BookmarkUtils.fetchRootFolder(context)?.objectID)
        let result = viewModel.bookmarks
        
        XCTAssertEqual(result[1], viewModel.bookmark(at: 1))
        
        let names = result.map { $0.title }
        XCTAssertEqual(names, BasicBookmarksStructure.topLevelTitles)
        
        let nestedViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                    parentID: result[1].objectID,
                                                    favoritesDisplayMode: .displayNative(.mobile))
        XCTAssertEqual(nestedViewModel.currentFolder?.objectID, result[1].objectID)
        
        let result2 = nestedViewModel.bookmarks
        
        let names2 = result2.map { $0.title }
        XCTAssertEqual(names2, BasicBookmarksStructure.nestedTitles)
    }
        
    func testWhenDeletingABookmarkItIsRemoved() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))
        let result = viewModel.bookmarks
        let idSet = Set(result.map { $0.objectID })
        
        let bookmark = result[0]
        XCTAssertFalse(bookmark.isFolder)
        
        viewModel.softDeleteBookmark(bookmark)
        
        let newViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                 parentID: nil,
                                                 favoritesDisplayMode: .displayNative(.mobile))
        let newResult = newViewModel.bookmarks
        let newIdSet = Set(newResult.map { $0.objectID })
        
        let diff = idSet.subtracting(newIdSet)
        
        XCTAssertEqual(diff.count, 1)
        XCTAssert(diff.contains(bookmark.objectID))
    }
    
    func testWhenDeletingABookmarkFolderItIsRemovedWithContents() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))
        let result = viewModel.bookmarks
        let idSet = Set(result.map { $0.objectID })
        
        let folder = result[1]
        XCTAssert(folder.isFolder)
        
        let totalCount = viewModel.totalBookmarksCount
        let expectedCountAfterRemoval = totalCount - folder.childrenArray.filter { !$0.isFolder }.count
        
        viewModel.softDeleteBookmark(folder)
        
        let newViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                 parentID: nil,
                                                 favoritesDisplayMode: .displayNative(.mobile))
        let newResult = newViewModel.bookmarks
        let newIdSet = Set(newResult.map { $0.objectID })
        
        let diff = idSet.subtracting(newIdSet)
        
        XCTAssertEqual(diff.count, 1)
        XCTAssertEqual(newViewModel.totalBookmarksCount, expectedCountAfterRemoval)
        XCTAssert(diff.contains(folder.objectID))
    }
    
    func testWhenGettingTotalCountThenFoldersAreNotTakenIntoAccount() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))

        XCTAssertEqual(viewModel.totalBookmarksCount, 5)
    }
    
    func testWhenMovingBookmarkItGoesToNewPosition() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))
        let result = viewModel.bookmarks
        
        let first = result[0]
        let second = result[1]
        
        viewModel.moveBookmark(first,
                               fromIndex: 0,
                               toIndex: 1)
        
        let newViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                 parentID: nil,
                                                 favoritesDisplayMode: .displayNative(.mobile))
        let newResult = newViewModel.bookmarks
        let newFirst = newResult[0]
        let newSecond = newResult[1]
        
        XCTAssertEqual(first.objectID, newSecond.objectID)
        XCTAssertEqual(second.objectID, newFirst.objectID)
        XCTAssertEqual(result.count, newResult.count)
    }
    
    func testWhenContextSavesThenChangesArePropagated() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))
        let listeningViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                       parentID: nil,
                                                       favoritesDisplayMode: .displayNative(.mobile))
        
        let expectation = expectation(description: "Changes propagated")
        
        withExtendedLifetime(listeningViewModel.externalUpdates.sink { _ in
            expectation.fulfill()
        }) {
            let startState = viewModel.bookmarks
            viewModel.softDeleteBookmark(startState[0])
            
            waitForExpectations(timeout: 1)
            
            let otherResults = listeningViewModel.bookmarks
            XCTAssertEqual(otherResults.count + 1, startState.count)
            XCTAssertEqual(otherResults.count, viewModel.bookmarks.count)
        }
    }
    
    // MARK: Errors
    
    func testWhenUsingWrongIndexesNothingHappens() {
        
        var expectedEvents: [BookmarksModelError] = [.bookmarksListIndexNotMatchingBookmark,
                                                     .indexOutOfRange(.bookmarks),
                                                     .indexOutOfRange(.bookmarks)].reversed()
        
        let expectation = expectation(description: "Errors reported")
        expectation.expectedFulfillmentCount = 3
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile),
                                              errorEvents: .init(mapping: { event, _, _, _ in
            let expectedEvent = expectedEvents.popLast()
            XCTAssertEqual(event, expectedEvent)
            expectation.fulfill()
        }))
                                              
        let result = viewModel.bookmarks
        
        let first = result[0]
        let second = result[1]
        
        // Wrong indexes
        viewModel.moveBookmark(first,
                               fromIndex: 1,
                               toIndex: 0)
        
        // Out of bounds `from`
        viewModel.moveBookmark(first,
                               fromIndex: 10,
                               toIndex: 1)
        
        // Out of bounds `to`
        viewModel.moveBookmark(first,
                               fromIndex: 0,
                               toIndex: 10)
        
        let newViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                 parentID: nil,
                                                 favoritesDisplayMode: .displayNative(.mobile))
        let newResult = newViewModel.bookmarks
        let newFirst = newResult[0]
        let newSecond = newResult[1]
        
        XCTAssertEqual(first.objectID, newFirst.objectID)
        XCTAssertEqual(second.objectID, newSecond.objectID)
        XCTAssertEqual(result.count, newResult.count)
        
        waitForExpectations(timeout: 1)
    }
    
    func testWhenFolderIsNotAFolderThenErrorIsReported() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))

        let result = viewModel.bookmarks
        let bookmark = result[0]
        XCTAssertFalse(bookmark.isFolder)
        
        let errorReported = expectation(description: "Error reported")
        let brokenViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                    parentID: bookmark.objectID,
                                                    favoritesDisplayMode: .displayNative(.mobile),
                                                    errorEvents: .init(mapping: { event, _, _, _ in
            errorReported.fulfill()
            XCTAssertEqual(event, .bookmarkFolderExpected)
        }))
        
        XCTAssertEqual(brokenViewModel.bookmarks.map { $0.objectID }, viewModel.bookmarks.map { $0.objectID })
        
        waitForExpectations(timeout: 1)
    }
    
    func testWhenFolderIsMissingThenErrorIsReported() {
        
        let viewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                              parentID: nil,
                                              favoritesDisplayMode: .displayNative(.mobile))

        let result = viewModel.bookmarks
        let bookmark = result[0]
        XCTAssertFalse(bookmark.isFolder)
        
        // Create local object:
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let tmpFolder = BookmarkEntity.makeFolder(title: "tmp",
                                                  parent: BookmarkUtils.fetchRootFolder(context)!,
                                                  context: context)
        
        let errorReported = expectation(description: "Error reported")
        let brokenViewModel = BookmarkListViewModel(bookmarksDatabase: db,
                                                    parentID: tmpFolder.objectID,
                                                    favoritesDisplayMode: .displayNative(.mobile),
                                                    errorEvents: .init(mapping: { event, _, _, _ in
            errorReported.fulfill()
            XCTAssertEqual(event, .bookmarksListMissingFolder)
        }))
        
        XCTAssertEqual(brokenViewModel.bookmarks.map { $0.objectID }, viewModel.bookmarks.map { $0.objectID })
        
        waitForExpectations(timeout: 1)
    }
    
    func testWhenRootIsMissingThenErrorIsReported() throws {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        context.deleteAll(entityDescriptions: [BookmarkEntity.entity(in: context)])
        try context.save()
        
        let expectation = expectation(description: "Error reported")
        _ = BookmarkListViewModel(bookmarksDatabase: db,
                                  parentID: nil,
                                  favoritesDisplayMode: .displayNative(.mobile),
                                  errorEvents: .init(mapping: { event, _, _, _ in
            XCTAssertEqual(event, .fetchingRootItemFailed(.bookmarks))
            expectation.fulfill()
        }))
        
        waitForExpectations(timeout: 1)
    }
}
