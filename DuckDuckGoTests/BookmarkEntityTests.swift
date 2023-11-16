//
//  BookmarkEntityTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Persistence
import CoreData
import Bookmarks
import DuckDuckGo

class BookmarkEntityTests: XCTestCase {

    var db: CoreDataDatabase!
    var context: NSManagedObjectContext!
    var root: BookmarkEntity!
    var favoritesFolders: [BookmarkEntity] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!

        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        BookmarkUtils.prepareFoldersStructure(in: context)

        try context.save()

        root = BookmarkUtils.fetchRootFolder(context)
        XCTAssertNotNil(root)

        favoritesFolders = BookmarkUtils.fetchFavoritesFolders(for: .displayNative(.mobile), in: context)
        XCTAssertNotNil(favoritesFolders)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        root = nil
        favoritesFolders = []
        context = nil

        try db.tearDown(deleteStores: true)
    }

    func testWhenBookmarkIsValidThenItSaves() throws {
        _ = BookmarkEntity.makeBookmark(title: "t",
                                        url: "u",
                                        parent: root,
                                        context: context)

        try context.save()
    }

    func testWhenFavoriteIsValidThenItSaves() throws {
        let favorite = BookmarkEntity.makeBookmark(title: "t",
                                                   url: "u",
                                                   parent: root,
                                                   context: context)
        favorite.addToFavorites(folders: favoritesFolders)

        try context.save()
    }

    func testWhenFolderIsValidThenItSaves() throws {
        _ = BookmarkEntity.makeFolder(title: "f", parent: root, context: context)

        try context.save()
    }

    func testWhenFavoriteIsUnderWrongFavoriteRootThenValidationFails() {
        let favorite = BookmarkEntity.makeBookmark(title: "t",
                                                   url: "u",
                                                   parent: root,
                                                   context: context)

        favorite.addToFavorites(favoritesRoot: root)

        do {
            try context.save()
            XCTFail("Save should fail")
        } catch {

        }
    }

    func testWhenFolderHasURLThenValidationFails() {
        let folder = BookmarkEntity.makeFolder(title: "f", parent: root, context: context)

        folder.url = "a"

        do {
            try context.save()
            XCTFail("Save should fail")
        } catch {

        }
    }

    func testWhenFolderHasNoParentThenValidationFails() {
        let folder = BookmarkEntity.makeFolder(title: "f", parent: root, context: context)

        folder.url = "a"

        do {
            try context.save()
            XCTFail("Save should fail")
        } catch {

        }
    }

    func testWhenThereIsACycleAfterInsertThenValidationFails() {

        let folderA = BookmarkEntity.makeFolder(title: "f", parent: root, context: context)

        let folderB = BookmarkEntity.makeFolder(title: "f", parent: folderA, context: context)

        let folderC = BookmarkEntity.makeFolder(title: "f", parent: folderB, context: context)

        folderA.parent = folderC

        do {
            try context.save()
            XCTFail("Save should fail")
        } catch {

        }
    }

    func testWhenThereIsACycleAfterUpdateThenValidationFails() throws {

        let folderA = BookmarkEntity.makeFolder(title: "f", parent: root, context: context)

        let folderB = BookmarkEntity.makeFolder(title: "f", parent: folderA, context: context)

        let folderC = BookmarkEntity.makeFolder(title: "f", parent: folderB, context: context)

        _ = BookmarkEntity.makeFolder(title: "f", parent: folderC, context: context)

        try context.save()

        folderB.parent = folderC

        do {
            try context.save()
            XCTFail("Save should fail")
        } catch {

        }
    }

    func testWhenValidationFailsThenErrorIsParsable() throws {
        let folder = BookmarkEntity.makeFolder(title: "f", parent: root, context: context)
        folder.url = "a"

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            let processedError = CoreDataErrorsParser.parse(error: nsError).first

            XCTAssertNotNil(processedError)
            XCTAssertEqual(processedError?.code, (BookmarkEntity.Error.folderHasURL as NSError).code)
            XCTAssertEqual(processedError?.domain, (BookmarkEntity.Error.folderHasURL as NSError).domain)
        }

    }
}
