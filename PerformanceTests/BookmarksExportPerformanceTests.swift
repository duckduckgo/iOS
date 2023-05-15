//
//  BookmarksExportPerformanceTests.swift
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

class BookmarksExportPerformanceTests: XCTestCase {
    
    var db: CoreDataDatabase!
    
    override func setUp() async throws {
        try await super.setUp()
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        
        let dir = tempDBDir()
        db = CoreDataDatabase(name: "Test", containerLocation: dir, model: model)
        db.loadStore()
        
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        BookmarkUtils.prepareFoldersStructure(in: context)
        try? context.save()
        
        let html = loadHtmlFile("bookmarks_3k.html")
        
        let importer = await BookmarksImporter(coreDataStore: db)
        _ = await importer.parseAndSave(html: html)
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? db.tearDown(deleteStores: true)
    }
    
    func loadHtmlFile(_ fileName: String) -> String {
        guard let data = try? FileLoader().load(fileName: fileName, fromBundle: Bundle(for: type(of: self))),
              let html = String(data: data, encoding: .utf8)  else {
            fatalError("Unable to load \(fileName)")
        }
        
        return html
    }
    
    func testExportPerformance() {
        
        measure {
            let time = CACurrentMediaTime()
            let expectation = expectation(description: "Exported")
            Task {
                let exporter = await BookmarksExporter(coreDataStore: db)
                _ = try? await exporter.exportBookmarksToContent()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30)
            print("==============================")
            print("Completed in \(CACurrentMediaTime() - time)")
        }
        
    }
    
}
    
