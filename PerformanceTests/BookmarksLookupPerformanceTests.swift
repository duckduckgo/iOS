//
//  BookmarksLookupPerformanceTests.swift
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
import Bookmarks
import Persistence
import CoreData
@testable import Core
@testable import DuckDuckGo

class BookmarksLookupPerformanceTests: XCTestCase {

    var db: CoreDataDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!

        let dir = tempDBDir()
        db = CoreDataDatabase(name: "Test", containerLocation: dir, model: model)
        db.loadStore()
        try populateData()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        try db.tearDown(deleteStores: true)
    }

    func populateData() throws {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        // 30k+ entries
        try BookmarksTestData().generate(bookmarksPerFolder: 21, foldersPerFolder: 4, levels: 5, in: context)
    }

    func testUUIDQueryPerformance() throws {

        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)

        let allBookmarks = try context.fetch(BookmarkEntity.fetchRequest())

        let firstQuery = BookmarkEntity.fetchRequest()
        firstQuery.predicate = NSPredicate(format: "%K == %@ AND %K == NO",
                                           #keyPath(BookmarkEntity.uuid),
                                           allBookmarks[0].uuid!,
                                           #keyPath(BookmarkEntity.isPendingDeletion))

        let secondQuery = BookmarkEntity.fetchRequest()
        secondQuery.predicate = NSPredicate(format: "%K == %@ AND %K == NO",
                                            #keyPath(BookmarkEntity.uuid),
                                            allBookmarks[allBookmarks.count / 2].uuid!,
                                            #keyPath(BookmarkEntity.isPendingDeletion))

        let thirdQuery = BookmarkEntity.fetchRequest()
        thirdQuery.predicate = NSPredicate(format: "%K == %@ AND %K == NO",
                                           #keyPath(BookmarkEntity.uuid),
                                           allBookmarks[allBookmarks.count - 1].uuid!,
                                           #keyPath(BookmarkEntity.isPendingDeletion))

        context.reset()

        measure {
            let time = CACurrentMediaTime()

            let r1 = try? context.fetch(firstQuery)
            XCTAssertNotNil(r1?.first)
            XCTAssertEqual(r1?.count, 1)

            let r2 = try? context.fetch(secondQuery)
            XCTAssertNotNil(r2?.first)
            XCTAssertEqual(r2?.count, 1)

            let r3 = try? context.fetch(thirdQuery)
            XCTAssertNotNil(r3?.first)
            XCTAssertEqual(r3?.count, 1)

            print("==============================")
            print("Completed in \(CACurrentMediaTime() - time)")
        }
    }
}
