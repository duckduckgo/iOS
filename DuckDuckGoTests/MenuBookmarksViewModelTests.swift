//
//  MenuBookmarksViewModelTests.swift
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
import XCTest
import Bookmarks
import Persistence
import DuckDuckGo

private extension MenuBookmarksViewModel {
    
    convenience init(bookmarksDatabase: CoreDataDatabase) {
        self.init(bookmarksDatabase: bookmarksDatabase,
                  errorEvents: .init(mapping: { event, _, _, _ in
            XCTFail("Unexpected error: \(event)")
        }))
    }
}

class MenuBookmarksViewModelTests: XCTestCase {
    
    let url = URL(string: "https://test.com")!
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
    
    private func validateNewBookmark(_ bookmark: BookmarkEntity?) {
        guard let bookmark = bookmark else { XCTFail("Missing bookmark"); return }
        XCTAssertNotNil(bookmark)
        XCTAssertFalse(bookmark.isFavorite(on: .mobile))
        XCTAssertTrue(bookmark.favoriteFoldersSet.isEmpty)
        XCTAssertEqual(bookmark, bookmark.parent?.childrenArray.last)
    }
    
    private func validateNewFavorite(_ favorite: BookmarkEntity?) {
        guard let favorite = favorite else { XCTFail("Missing favorite"); return }
        XCTAssert(favorite.isFavorite(on: .mobile))
        XCTAssertFalse(favorite.favoriteFoldersSet.isEmpty)
        XCTAssertEqual(favorite, favorite.parent?.childrenArray.last)
        XCTAssertEqual(favorite, favorite.favoriteFoldersSet
            .first(where: { $0.uuid == FavoritesFolderID.mobile.rawValue })?
            .favorites?.lastObject as? BookmarkEntity)
    }

    func testWhenCheckingBookmarkStatusThenReturnOneIfFound() {
        let model = MenuBookmarksViewModel(bookmarksDatabase: db)
        
        XCTAssertNil(model.bookmark(for: URL(string: BasicBookmarksStructure.urlString(forName: "0"))!))
        XCTAssertNotNil(model.bookmark(for: URL(string: BasicBookmarksStructure.urlString(forName: "1"))!))
        XCTAssertNotNil(model.bookmark(for: URL(string: BasicBookmarksStructure.urlString(forName: "F2"))!))
        
        XCTAssertNil(model.favorite(for: URL(string: BasicBookmarksStructure.urlString(forName: "F2"))!))
        XCTAssertNotNil(model.favorite(for: URL(string: BasicBookmarksStructure.urlString(forName: "1"))!))
    }
    
    func testWhenAddingBookmarkThenNewEntryIsCreated() {
        let model = MenuBookmarksViewModel(bookmarksDatabase: db)
        
        XCTAssertNil(model.bookmark(for: url))
        model.createBookmark(title: "test", url: url)
        validateNewBookmark(model.bookmark(for: url))
        
        // Validate if other context will reflect same state
        let anotherModel = MenuBookmarksViewModel(bookmarksDatabase: db)
        validateNewBookmark(anotherModel.bookmark(for: url))
    }
    
    func testWhenAddingNewAsFavoriteThenNewEntryIsCreated() {
        let model = MenuBookmarksViewModel(bookmarksDatabase: db)
        
        XCTAssertNil(model.bookmark(for: url))
        model.createOrToggleFavorite(title: "test", url: url)
        validateNewFavorite(model.bookmark(for: url))
        
        // Validate if other context will reflect same state
        let anotherModel = MenuBookmarksViewModel(bookmarksDatabase: db)
        validateNewFavorite(anotherModel.bookmark(for: url))
    }
    
    func testWhenAddingExistingAsFavoriteThenBookmarkIsUpdated() {
        let model = MenuBookmarksViewModel(bookmarksDatabase: db)
        
        XCTAssertNil(model.bookmark(for: url))
        model.createBookmark(title: "test", url: url)
        let newBookmark = model.bookmark(for: url)
        let topLevelCount = newBookmark?.parent?.childrenArray.count ?? 0
        validateNewBookmark(newBookmark)
        model.createOrToggleFavorite(title: "test", url: url)
        validateNewFavorite(newBookmark)
        
        // Validate if other context will reflect same state
        let anotherModel = MenuBookmarksViewModel(bookmarksDatabase: db)
        let anotherBookmark = anotherModel.bookmark(for: url)
        let anotherLevelCount = newBookmark?.parent?.childrenArray.count ?? 0
        validateNewFavorite(anotherBookmark)
        
        XCTAssertEqual(topLevelCount, anotherLevelCount)
    }
    
    func testWhenRemovingFavoriteThenBookmarkIsUpdated() {
        let model = MenuBookmarksViewModel(bookmarksDatabase: db)
        
        XCTAssertNil(model.bookmark(for: url))
        model.createOrToggleFavorite(title: "test", url: url)
        let newBookmark = model.bookmark(for: url)
        validateNewFavorite(newBookmark)
        model.createOrToggleFavorite(title: "test", url: url)
        validateNewBookmark(newBookmark)
        
        // Validate if other context will reflect same state
        let anotherModel = MenuBookmarksViewModel(bookmarksDatabase: db)
        validateNewBookmark(anotherModel.bookmark(for: url))
    }
}
