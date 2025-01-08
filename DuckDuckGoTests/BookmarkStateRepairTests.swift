//
//  BookmarkStateRepairTests.swift
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

class BookmarkStateRepairTests: XCTestCase {

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

    func testWhenThereIsNoIssueThenThereAreNoChanges() {
        prepareValidStructure()

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {

            let repair = BookmarksStateRepair(keyValueStore: mockKeyValueStore)

            XCTAssertEqual(repair.validateAndRepairPendingDeletionState(in: testContext), .noBrokenData)
            XCTAssertEqual(repair.validateAndRepairPendingDeletionState(in: testContext), .alreadyPerformed)
        }
    }

    func testWhenPendingDeletionIsNilThenItIsFixed() {
        prepareBrokenStructure()

        let testContext = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)
        testContext.performAndWait {

            let repair = BookmarksStateRepair(keyValueStore: mockKeyValueStore)

            XCTAssertEqual(repair.validateAndRepairPendingDeletionState(in: testContext), .dataRepaired)

            mockKeyValueStore.removeObject(forKey: BookmarksStateRepair.Constants.pendingDeletionRepaired)
            XCTAssertEqual(repair.validateAndRepairPendingDeletionState(in: testContext), .noBrokenData)
            XCTAssertEqual(repair.validateAndRepairPendingDeletionState(in: testContext), .alreadyPerformed)
        }
    }

    private func prepareStructure(_ block: (NSManagedObjectContext) -> Void) {
        let context = dbStack.makeContext(concurrencyType: .privateQueueConcurrencyType)

        context.performAndWait {
            BookmarkUtils.prepareFoldersStructure(in: context)
            block(context)
            do {
                try context.save()
            } catch {
                XCTFail("Could not save context")
            }
        }
    }

    private func prepareValidStructure() {
        prepareStructure { context in
            guard let root = BookmarkUtils.fetchRootFolder(context) else {
                XCTFail("Root missing")
                return
            }

            let bookmarkA = BookmarkEntity.makeBookmark(title: "A", url: "A", parent: root, context: context)
            let bookmarkB = BookmarkEntity.makeBookmark(title: "B", url: "B", parent: root, context: context)
            let bookmarkC = BookmarkEntity.makeBookmark(title: "C", url: "C", parent: root, context: context)
        }
    }

    private func prepareBrokenStructure() {
        prepareStructure { context in
            guard let root = BookmarkUtils.fetchRootFolder(context) else {
                XCTFail("Root missing")
                return
            }

            let bookmarkA = BookmarkEntity.makeBookmark(title: "A", url: "A", parent: root, context: context)
            let bookmarkB = BookmarkEntity.makeBookmark(title: "B", url: "B", parent: root, context: context)
            let bookmarkC = BookmarkEntity.makeBookmark(title: "C", url: "C", parent: root, context: context)

            bookmarkA.setValue(nil, forKey: #keyPath(BookmarkEntity.isPendingDeletion))
            bookmarkB.setValue(nil, forKey: #keyPath(BookmarkEntity.isPendingDeletion))
        }
    }

}
