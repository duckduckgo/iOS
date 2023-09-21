//
//  FavoriteListViewModelTests.swift
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
import Common
import Persistence
import Bookmarks
import DuckDuckGo

private extension FavoritesListViewModel {
    
    convenience init(bookmarksDatabase: CoreDataDatabase) {
        self.init(bookmarksDatabase: bookmarksDatabase,
                  errorEvents: .init(mapping: { event, _, _, _ in
            XCTFail("Unexpected error: \(event)")
        }),
                  favoritesDisplayMode: .displayNative(.mobile))
    }
}

class FavoriteListViewModelTests: XCTestCase {
    
    var db: CoreDataDatabase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        
        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()
        
        let mainContext = db.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "TestContext")
        BasicBookmarksStructure.populateDB(context: mainContext)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try db.tearDown(deleteStores: true)
    }
    
    func testWhenFavoritesExistThenTheyAreFetched() {
        
        let viewModel = FavoritesListViewModel(bookmarksDatabase: db)
        
        let result = viewModel.favorites
        
        let names = result.map { $0.title }
        XCTAssertEqual(names, BasicBookmarksStructure.favoriteTitles)
    }
    
    func testWhenDeletingAFavoriteThenItIsRemoved() {
                
        let viewModel = FavoritesListViewModel(bookmarksDatabase: db)
        
        let result = viewModel.favorites
        viewModel.removeFavorite(result[1])
        
        let newModel = FavoritesListViewModel(bookmarksDatabase: db)
        let newResult = newModel.favorites
        
        var oldNames = result.map { $0.title }
        _ = oldNames.remove(at: 1)
        let newNames = newResult.map { $0.title }
        XCTAssertEqual(oldNames, newNames)
    }
    
    func testWhenMovingFavoriteThenItGoesToNewPosition() {
        
        let viewModel = FavoritesListViewModel(bookmarksDatabase: db)
        let result = viewModel.favorites
        
        viewModel.moveFavorite(result[1], fromIndex: 1, toIndex: 3)
        
        let newModel = FavoritesListViewModel(bookmarksDatabase: db)
        let newResult = newModel.favorites
        
        XCTAssertEqual(result[0].objectID, newResult[0].objectID)
        XCTAssertEqual(result[1].objectID, newResult[3].objectID)
        XCTAssertEqual(result[2].objectID, newResult[1].objectID)
        XCTAssertEqual(result[3].objectID, newResult[2].objectID)
        XCTAssertEqual(result.count, newResult.count)
    }
    
    func testWhenContextSavesThenChangesArePropagated() {
        
        let viewModel = FavoritesListViewModel(bookmarksDatabase: db)
        let listeningViewModel = FavoritesListViewModel(bookmarksDatabase: db)
        
        let expectation = expectation(description: "Changes propagated")

        withExtendedLifetime(listeningViewModel.externalUpdates.sink { _ in
            expectation.fulfill()
        }) {
            let startState = viewModel.favorites
            viewModel.removeFavorite(startState[0])
            
            waitForExpectations(timeout: 1)
            
            let otherResults = listeningViewModel.favorites
            XCTAssertEqual(otherResults.count + 1, startState.count)
            XCTAssertEqual(otherResults.count, viewModel.favorites.count)
        }
    }
    
    // MARK: Errors
    
    func testWhenUsingWrongIndexesThenNothingHappens() {
        
        var expectedEvents: [BookmarksModelError] = [.favoritesListIndexNotMatchingBookmark,
                                                     .indexOutOfRange(.favorites),
                                                     .indexOutOfRange(.favorites)].reversed()
        
        let expectation = expectation(description: "Errors reported")
        expectation.expectedFulfillmentCount = 3
        let viewModel = FavoritesListViewModel(bookmarksDatabase: db,
                                              errorEvents: .init(mapping: { event, _, _, _ in
            let expectedEvent = expectedEvents.popLast()
            XCTAssertEqual(event, expectedEvent)
            expectation.fulfill()
        }),
                                               favoritesDisplayMode: .displayNative(.mobile))
                                              
        let result = viewModel.favorites
        
        let first = result[0]
        let second = result[1]
        
        // Wrong indexes
        viewModel.moveFavorite(first,
                               fromIndex: 1,
                               toIndex: 0)
        
        // Out of bounds `from`
        viewModel.moveFavorite(first,
                               fromIndex: 10,
                               toIndex: 1)
        
        // Out of bounds `to`
        viewModel.moveFavorite(first,
                               fromIndex: 0,
                               toIndex: 10)
        
        let newViewModel = FavoritesListViewModel(bookmarksDatabase: db)
        let newResult = newViewModel.favorites
        let newFirst = newResult[0]
        let newSecond = newResult[1]
        
        XCTAssertEqual(first.objectID, newFirst.objectID)
        XCTAssertEqual(second.objectID, newSecond.objectID)
        XCTAssertEqual(result.count, newResult.count)
        
        waitForExpectations(timeout: 1)
    }
    
    func testWhenRootIsMissingThenErrorIsReported() throws {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        context.deleteAll(entityDescriptions: [BookmarkEntity.entity(in: context)])
        try context.save()
        
        let expectation = expectation(description: "Error reported")
        expectation.assertForOverFulfill = false
        _ = FavoritesListViewModel(bookmarksDatabase: db,
                                   errorEvents: .init(mapping: { event, _, _, _ in
            XCTAssertEqual(event, .fetchingRootItemFailed(.favorites))
            expectation.fulfill()
        }),
                                   favoritesDisplayMode: .displayNative(.mobile))
        
        waitForExpectations(timeout: 1)
    }
}
