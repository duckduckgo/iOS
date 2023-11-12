//
//  BookmarkEditorViewModelTests.swift
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
import Common
import DuckDuckGo

class BookmarkEditorViewModelTests: XCTestCase {
    
    var db: CoreDataDatabase!
    
    override func setUp() {
        super.setUp()
        
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        
        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()
        
        let mainContext = db.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "TestContext")
        BasicBookmarksStructure.populateDB(context: mainContext)
    }

    override func tearDown() {
        super.tearDown()
        
        try? db.tearDown(deleteStores: true)
    }
    
    func errorValidatingHandler() -> EventMapping<BookmarksModelError> {
        return EventMapping<BookmarksModelError>.init { event, _, _, _ in
            XCTFail("Found error: \(event)")
        }
    }
    
    func testWhenCreatingFolderWithoutParentThenModelCanSave() {
        let model = BookmarkEditorViewModel(creatingFolderWithParentID: nil,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: errorValidatingHandler())
        
        XCTAssertFalse(model.canAddNewFolder)
        XCTAssert(model.isNew)
        
        XCTAssertFalse(model.canSave)
        model.bookmark.title = "New"
        XCTAssert(model.canSave)
        model.save()
    }
    
    func testWhenCreatingFolderWithParentThenModelCanSave() {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let root = BookmarkUtils.fetchRootFolder(context)
        XCTAssertNotNil(root)
        let model = BookmarkEditorViewModel(creatingFolderWithParentID: root?.objectID,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: errorValidatingHandler())
        
        XCTAssertFalse(model.canAddNewFolder)
        XCTAssert(model.isNew)
        
        XCTAssertFalse(model.canSave)
        model.bookmark.title = "New"
        XCTAssert(model.canSave)
        model.save()
    }
    
    func testWhenEditingBookmarkThenModelCanSave() {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let root = BookmarkUtils.fetchRootFolder(context)
        guard let firstBookmark = root?.childrenArray[0] else {
            XCTFail("Missing bookmark")
            return
        }
        
        XCTAssertFalse(firstBookmark.isFolder)
        
        let model = BookmarkEditorViewModel(editingEntityID: firstBookmark.objectID,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: errorValidatingHandler())
        
        XCTAssertFalse(model.isNew)
        XCTAssert(model.canAddNewFolder)
        XCTAssert(model.canSave)
        model.save()
    }
    
    func testWhenEditingFolderThenModelCanSave() {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let root = BookmarkUtils.fetchRootFolder(context)
        guard let firstBookmark = root?.childrenArray[1] else {
            XCTFail("Missing bookmark")
            return
        }
        
        XCTAssert(firstBookmark.isFolder)
        
        let model = BookmarkEditorViewModel(editingEntityID: firstBookmark.objectID,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: errorValidatingHandler())
        
        XCTAssertFalse(model.isNew)
        XCTAssertFalse(model.canAddNewFolder)
        XCTAssert(model.canSave)
        model.save()
    }
    
    func testWhenEditingBookmarkThenFolderCanBeChanged() {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        
        guard let root = BookmarkUtils.fetchRootFolder(context),
              let firstBookmark = root.childrenArray.first else {
            XCTFail("Missing bookmark")
            return
        }
        
        XCTAssertFalse(firstBookmark.isFolder)
        
        let model = BookmarkEditorViewModel(editingEntityID: firstBookmark.objectID,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: errorValidatingHandler())
        
        let folders = model.locations
        
        let fetchFolders = BookmarkEntity.fetchRequest()
        fetchFolders.predicate = NSPredicate(format: "%K == true AND NOT %K IN %@ AND %K == false",
                                             #keyPath(BookmarkEntity.isFolder),
                                             #keyPath(BookmarkEntity.uuid),
                                             FavoritesFolderID.allCases.map(\.rawValue),
                                             #keyPath(BookmarkEntity.isPendingDeletion))
        let allFolders = (try? context.fetch(fetchFolders)) ?? []
        
        XCTAssertEqual(folders.count, allFolders.count)
        
        let editedBookmark = model.bookmark
        
        XCTAssert(editedBookmark.parent != folders[1].bookmark)
        XCTAssert(model.isSelected(root))
        model.selectLocationAtIndex(1)
        XCTAssert(model.isSelected(folders[1].bookmark))
        XCTAssert(model.canSave)
        XCTAssert(editedBookmark.parent == folders[1].bookmark)
        
        model.setParentWithID(root.objectID)
        XCTAssert(model.isSelected(root))
        XCTAssert(model.canSave)
        XCTAssert(editedBookmark.parent == folders[0].bookmark)
        model.save()
    }
    
    func testWhenSettingFavoriteThenObjectIsUpdated() {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        
        guard let root = BookmarkUtils.fetchRootFolder(context),
              let firstBookmark = root.childrenArray.first else {
            XCTFail("Missing bookmark")
            return
        }
        
        XCTAssertFalse(firstBookmark.isFolder)
        
        let model = BookmarkEditorViewModel(editingEntityID: firstBookmark.objectID,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: errorValidatingHandler())
        
        XCTAssert(model.bookmark.isFavorite(on: .mobile))
        model.removeFromFavorites()
        XCTAssertFalse(model.bookmark.isFavorite(on: .mobile))
        XCTAssert(model.canSave)
        model.save()
    }
    
    // MARK: Errors
    
    func testWhenSavingInBrokenStateThenErrorIsReported() {
        let errorReported = expectation(description: "Error reported")
        let model = BookmarkEditorViewModel(creatingFolderWithParentID: nil,
                                            bookmarksDatabase: db,
                                            favoritesDisplayMode: .displayNative(.mobile),
                                            errorEvents: .init(mapping: { event, _, _, _ in
            XCTAssertEqual(event, .saveFailed(.edit))
            errorReported.fulfill()
        }))
        
        XCTAssert(model.isNew)
        model.bookmark.uuid = nil
        model.save()
        
        waitForExpectations(timeout: 1)
    }
}
