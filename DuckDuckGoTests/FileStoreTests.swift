//
//  FileStoreTests.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
@testable import Core

class FileStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .surrogates))
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .temporaryUnprotectedSites))
    }
    
    func testWhenFileExistsThenHasDataReturnsTrue() {
        let store = FileStore()
        XCTAssertFalse(store.hasData(forConfiguration: .surrogates))
        
        XCTAssertTrue(store.persist(Data(), forConfiguration: .surrogates))
        XCTAssertTrue(store.hasData(forConfiguration: .surrogates))
    }
    
    func testWhenNewThenStorageIsEmptyForConfiguration() {
        let store = FileStore()
        XCTAssertNil(store.loadAsString(forConfiguration: .surrogates))
    }
    
    func testWhenDataSavedForConfigurationItCanBeLoadedAsAString() {
        let uuid = UUID().uuidString
        let data = uuid.data(using: .utf8)
        let store = FileStore()
        XCTAssertTrue(store.persist(data, forConfiguration: .surrogates))
        XCTAssertEqual(uuid, store.loadAsString(forConfiguration: .surrogates))
        XCTAssertNil(store.loadAsString(forConfiguration: .temporaryUnprotectedSites))
    }
    
    func testWhenRemovingLegacyDataThenItAllGetsDeleted() {
        let store = FileStore()
        let location = store.persistenceLocation(forConfiguration: .surrogates).deletingLastPathComponent()
                
        do {
            try FileStore.Constants.legacyFiles.forEach {
                try "test".write(to: location.appendingPathComponent($0), atomically: true, encoding: .utf8)
            }
        } catch {
            XCTFail("Failed to write file \(error.localizedDescription)")
        }
        
        FileStore().removeLegacyData()
        
        FileStore.Constants.legacyFiles.forEach {
            assertDeleted(location.appendingPathComponent($0))
        }
    }
    
    func testLegacyFiles() {
        
        XCTAssertEqual([
            "disconnectme.json",
            "easylistWhitelist.txt",
            "entitylist2.json",
            "surrogate.js"
        ], FileStore.Constants.legacyFiles)
        
    }

    private func assertDeleted(_ url: URL, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.absoluteString), file: file, line: line)
    }
    
}
