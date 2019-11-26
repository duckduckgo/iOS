//
//  FileStoreTests.swift
//  Core
//
//  Created by Chris Brind on 26/11/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class FileStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .surrogates))
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
        XCTAssertNil(store.loadAsString(forConfiguration: .temporaryWhitelist))
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
            "surrogates.js",
            "easylist.txt",
            "easylistPrivacy.txt",
            "easylistWhitelist.txt",
            "disconnectme.json",
            "entitylist2.json"
        ], FileStore.Constants.legacyFiles)
        
    }

    private func assertDeleted(_ url: URL, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.absoluteString), file: file, line: line)
    }
    
}
