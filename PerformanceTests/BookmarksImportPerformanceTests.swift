//
//  BookmarksImportPerformanceTests.swift
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

class BookmarksImportPerformanceTests: XCTestCase {
    
    var model: NSManagedObjectModel!
    
    var databasesToTearDown = [CoreDataDatabase]()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        for db in databasesToTearDown {
            try db.tearDown(deleteStores: true)
        }
    }
    
    func loadHtmlFile(_ fileName: String) -> String {
        guard let data = try? FileLoader().load(fileName: fileName, fromBundle: Bundle(for: type(of: self))),
              let html = String(data: data, encoding: .utf8)  else {
            fatalError("Unable to load \(fileName)")
        }

        return html
    }
    
    func testImportPerformance() {
        
        let html = loadHtmlFile("bookmarks_30k.html")
        
        measureMetrics(XCTestCase.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
            
            let dir = tempDBDir()
            let db = CoreDataDatabase(name: "Test", containerLocation: dir, model: model)
            db.loadStore()
            databasesToTearDown.append(db)
            
            let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
            BookmarkUtils.prepareFoldersStructure(in: context)
            try? context.save()
            
            let expectation = expectation(description: "Import completed")
            let time = CACurrentMediaTime()
            startMeasuring()
            
            Task {
                let importer = await BookmarksImporter(coreDataStore: db)
                let result = await importer.parseAndSave(html: html)
                switch result {
                case .failure:
                    XCTFail("Could not import bookmarks")
                default:
                    break
                }
                expectation.fulfill()
            }
        
            wait(for: [expectation], timeout: 120)
            stopMeasuring()
            print("==============================")
            print("Completed in \(CACurrentMediaTime() - time)")
        }
    }
    
    
}
