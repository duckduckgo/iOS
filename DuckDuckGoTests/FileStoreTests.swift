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
            try "xxx".write(to: location.appendingPathComponent("surrogates.js"), atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to write file \(error.localizedDescription)")
        }
        
        FileStore().removeLegacyData()
        
        assertDeleted(location.appendingPathComponent("surrogates.js"))
    }

    func assertDeleted(_ url: URL, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.absoluteString), file: file, line: line)
    }
    
}
