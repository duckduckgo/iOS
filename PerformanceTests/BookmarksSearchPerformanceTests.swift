//
//  BookmarksSearchPerformanceTests.swift
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
import Bookmarks
import Persistence
import CoreData
@testable import Core
@testable import DuckDuckGo

func tempDBDir() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
}

class BookmarksSearchPerformanceTests: XCTestCase {
    
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
    
    func testCacheCreationPerformance() {
        _ = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: db))
        
        measure {
            Thread.sleep(forTimeInterval: 1)
            _ = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: db))
        }
    }
    
    func testSimpleSearchPerformance() {
        let search = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: db))
        
        measure {
            let result = search.search(query: "ab")
            XCTAssertFalse(result.isEmpty)
        }
    }
    
    func testComplexSearchPerformance() {
        let search = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: db))
        
        measure {
            let result = search.search(query: "a ab abc abcd")
            XCTAssertFalse(result.isEmpty)
        }
    }
}
