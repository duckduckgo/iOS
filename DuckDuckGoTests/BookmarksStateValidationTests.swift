//
//  BookmarksStateValidationTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import PersistenceTestingUtils
@testable import Core
@testable import DuckDuckGo

class BookmarksStateValidationTests: XCTestCase {

    let dbStack = MockBookmarksDatabase.make(prepareFolderStructure: false)

    let mockKeyValueStore = MockKeyValueStore()

    override func setUp() async throws {
        try await super.setUp()

        let containerLocation = MockBookmarksDatabase.tempDBDir()
        try FileManager.default.createDirectory(at: containerLocation, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        try await super.tearDown()

        try dbStack.tearDown(deleteStores: true)
    }

    private func prepareStructure(_ block: (NSManagedObjectContext) -> Void) {
        let context = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)

        context.performAndWait {
            block(context)

            do {
                try context.save()
            } catch {
                XCTFail("Could not save context")
            }
        }
    }

    func testWhenDatabaseIsGoodThenThereIsNoError() {
        prepareStructure { context in
            BookmarkUtils.prepareFoldersStructure(in: context)
        }

        let validator = BookmarksStateValidator(keyValueStore: mockKeyValueStore) { error in
            XCTFail("Did not expect error: \(error)")
        }

        mockKeyValueStore.set(true, forKey: BookmarksStateValidator.Constants.bookmarksDBIsInitialized)

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {
            XCTAssertTrue(validator.validateInitialState(context: testContext, validationError: .bookmarksStructureLost))
            validator.validateBookmarksStructure(context: testContext)
        }
    }

    func testWhenDatabaseIsEmptyButItHasNotBeenInitiatedThenThereIsNoError() {

        let validator = BookmarksStateValidator(keyValueStore: mockKeyValueStore) { error in
            XCTFail("Did not expect error: \(error)")
        }

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {
            XCTAssertTrue(validator.validateInitialState(context: testContext, validationError: .bookmarksStructureLost))
        }
    }

    func testWhenDatabaseIsEmptyThenErrorIsRaised() {

        let expectation1 = expectation(description: "Lost structure Error raised")
        let expectation2 = expectation(description: "Broken structure Error raised")

        let validator = BookmarksStateValidator(keyValueStore: mockKeyValueStore) { error in
            switch error {
            case .bookmarksStructureLost:
                expectation1.fulfill()
            case .bookmarksStructureBroken:
                expectation2.fulfill()
            default:
                XCTFail("Did not expect error: \(error)")
            }
        }

        mockKeyValueStore.set(true, forKey: BookmarksStateValidator.Constants.bookmarksDBIsInitialized)

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {
            XCTAssertFalse(validator.validateInitialState(context: testContext, validationError: .bookmarksStructureLost))
            validator.validateBookmarksStructure(context: testContext)
        }

        wait(for: [expectation1, expectation2], timeout: 5.0)
    }

    func testWhenDatabaseIsMissingSomeRootsThenErrorIsRaised() {
        prepareStructure { context in
            BookmarkUtils.prepareFoldersStructure(in: context)

            if let unifiedFolder = BookmarkUtils.fetchFavoritesFolder(withUUID: FavoritesFolderID.unified.rawValue, in: context) {
                context.delete(unifiedFolder)
            }
            if let rootFolder = BookmarkUtils.fetchRootFolder(context) {
                context.delete(rootFolder)
            }

            try? context.save()
        }

        let expectation = expectation(description: "Broken structure Error raised")

        let validator = BookmarksStateValidator(keyValueStore: mockKeyValueStore) { error in
            switch error {
            case .bookmarksStructureBroken(let errorInfo):
                expectation.fulfill()

                XCTAssertEqual(errorInfo[FavoritesFolderID.unified.rawValue], "0")
                XCTAssertEqual(errorInfo[FavoritesFolderID.mobile.rawValue], "1")
                XCTAssertEqual(errorInfo[FavoritesFolderID.desktop.rawValue], "1")
                XCTAssertEqual(errorInfo[BookmarkEntity.Constants.rootFolderID], "0")
            default:
                XCTFail("Did not expect error: \(error)")
            }
        }

        mockKeyValueStore.set(true, forKey: BookmarksStateValidator.Constants.bookmarksDBIsInitialized)

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {
            XCTAssertTrue(validator.validateInitialState(context: testContext, validationError: .bookmarksStructureLost))
            validator.validateBookmarksStructure(context: testContext)
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testWhenDatabaseHasTooManyRootsThenErrorIsRaised() {
        prepareStructure { context in
            BookmarkUtils.prepareFoldersStructure(in: context)

            if let root = BookmarkUtils.fetchRootFolder(context) {
                let newRoot = BookmarkEntity.makeFolder(title: "a", parent: root, context: context)
                newRoot.parent = nil
                newRoot.uuid = root.uuid
                try? context.save()
            }

        }

        let expectation = expectation(description: "Broken structure Error raised")

        let validator = BookmarksStateValidator(keyValueStore: mockKeyValueStore) { error in
            switch error {
            case .bookmarksStructureBroken(let errorInfo):
                expectation.fulfill()

                XCTAssertEqual(errorInfo[FavoritesFolderID.unified.rawValue], "1")
                XCTAssertEqual(errorInfo[FavoritesFolderID.mobile.rawValue], "1")
                XCTAssertEqual(errorInfo[FavoritesFolderID.desktop.rawValue], "1")
                XCTAssertEqual(errorInfo[BookmarkEntity.Constants.rootFolderID], "2")
            default:
                XCTFail("Did not expect error: \(error)")
            }
        }

        mockKeyValueStore.set(true, forKey: BookmarksStateValidator.Constants.bookmarksDBIsInitialized)

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {
            XCTAssertTrue(validator.validateInitialState(context: testContext, validationError: .bookmarksStructureLost))
            validator.validateBookmarksStructure(context: testContext)
        }

        wait(for: [expectation], timeout: 5.0)
    }


}
