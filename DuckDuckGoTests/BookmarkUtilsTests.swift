//
//  BookmarkUtilsTests.swift
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
import Persistence
import CoreData
import Bookmarks
import DuckDuckGo

class BookmarkUtilsTests: XCTestCase {
    
    var db: CoreDataDatabase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        
        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try db.tearDown(deleteStores: true)
    }
    
    func testWhenStructureIsEmptyThenItIsPrepared() throws {
        
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "Test")
        
        let countRequest = NSFetchRequest<BookmarkEntity>(entityName: "BookmarkEntity")
        countRequest.predicate = NSPredicate(value: true)
        
        var count = try context.count(for: countRequest)
        XCTAssertEqual(count, 0)
        
        BookmarkUtils.prepareFoldersStructure(in: context)
        
        count = try context.count(for: countRequest)
        XCTAssertEqual(count, 4)
        
        BookmarkUtils.prepareFoldersStructure(in: context)
        
        count = try context.count(for: countRequest)
        XCTAssertEqual(count, 4)
    }
 
}
