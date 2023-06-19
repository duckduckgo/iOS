//
//  BookmarksIndexesTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Bookmarks

final class BookmarksIndexesTests: XCTestCase {
    var bookmarksDatabase: CoreDataDatabase!
    var location: URL!

    override func setUp() {
        super.setUp()

        location = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let bundle = Bookmarks.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "BookmarksModel") else {
            XCTFail("Failed to load model")
            return
        }
        bookmarksDatabase = CoreDataDatabase(name: "BookmarksIndexesTests", containerLocation: location, model: model)
        bookmarksDatabase.loadStore()
    }

    override func tearDown() {
        super.tearDown()

        try? bookmarksDatabase.tearDown(deleteStores: true)
        bookmarksDatabase = nil
        try? FileManager.default.removeItem(at: location)
    }

    private func populateDatabase(_ database: CoreDataDatabase, _ numberOfItems: Int) {
        let context = database.makeContext(concurrencyType: .privateQueueConcurrencyType)

        context.performAndWait {
            BookmarkUtils.prepareFoldersStructure(in: context)

            do {
                try context.save()
            } catch {
                XCTFail(error.localizedDescription)
            }

            guard let rootFolder = BookmarkUtils.fetchRootFolder(context) else {
                XCTFail("Failed to find root folder")
                return
            }

            (0..<numberOfItems).forEach { number in
                let bookmark = BookmarkEntity.makeBookmark(
                    title: "Bookmark \(number)",
                    url: "https://www.example.com/\(number)",
                    parent: rootFolder,
                    context: context
                )
                if number % 3 == 0 {
                    bookmark.markPendingDeletion()
                }
            }
            do {
                try context.save()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testIsPendingDeletionIndexPerformance() throws {

        populateDatabase(bookmarksDatabase, 100000)

        let context = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)

        measure {
            context.performAndWait {
                _ = BookmarkUtils.fetchBookmarksPendingDeletion(context)
            }
        }
    }

    func testURLIndexPerformance() throws {

        populateDatabase(bookmarksDatabase, 100000)

        let context = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)

        measure {
            context.performAndWait {
                _ = BookmarkUtils.fetchBookmark(for: URL(string: "https://example.com/17892")!, context: context)
            }
        }
    }

}
