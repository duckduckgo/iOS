//
//  TabPreviewsSourceTests.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class TabPreviewsSourceTests: XCTestCase {
    
    private static func makeContainerUrl() -> URL? {
        guard var cachesDirURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        cachesDirURL.appendPathComponent(UUID().uuidString, isDirectory: true)
        return cachesDirURL
    }
    
    private let containerUrl = TabPreviewsSourceTests.makeContainerUrl()
    
    override func setUp() {
        guard let containerUrl = containerUrl else {
            XCTFail("Could not determine containerUrl")
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: containerUrl,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            XCTFail("Could not create test dir")
        }
    }
    
    override func tearDown() {
        guard let containerUrl = containerUrl else {
            XCTFail("Could not determine containerUrl")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: containerUrl)
        } catch {
            XCTFail("Could not cleanup test dir")
        }
    }
    
    func testWhenNothingToMigrateThenDoNothing() {
        guard let containerUrl = containerUrl else {
            XCTFail("Could not determine containerUrl")
            return
        }
        
        let fromUrl = containerUrl.appendingPathComponent("src", isDirectory: true)
        let toUrl = containerUrl.appendingPathComponent("dst", isDirectory: true)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: fromUrl.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: toUrl.path))
        
        let source = TabPreviewsSource(storeDir: toUrl, legacyDir: fromUrl)
        source.prepare()
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: fromUrl.path))
        
        var isDir: ObjCBool = false
        XCTAssert(FileManager.default.fileExists(atPath: toUrl.path, isDirectory: &isDir))
        XCTAssert(isDir.boolValue)
    }
    
    func testWhenEmptySourceToMigrateThenJustRemoveIt() {
        guard let containerUrl = containerUrl else {
            XCTFail("Could not determine containerUrl")
            return
        }
        
        let fromUrl = containerUrl.appendingPathComponent("src", isDirectory: true)
        let toUrl = containerUrl.appendingPathComponent("dst", isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: fromUrl,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
        } catch {
            XCTFail("Could not prepare source directory")
        }
        
        var isDir: ObjCBool = false
        
        XCTAssert(FileManager.default.fileExists(atPath: fromUrl.path, isDirectory: &isDir))
        XCTAssert(isDir.boolValue)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: toUrl.path))
        
        let source = TabPreviewsSource(storeDir: toUrl, legacyDir: fromUrl)
        source.prepare()
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: fromUrl.path))

        XCTAssert(FileManager.default.fileExists(atPath: toUrl.path, isDirectory: &isDir))
        XCTAssert(isDir.boolValue)
    }
    
    func testWhenMigratingThenPreviewsAreCopiedAndSourceIsRemoved() {
        guard let containerUrl = containerUrl else {
            XCTFail("Could not determine containerUrl")
            return
        }
        
        let fromUrl = containerUrl.appendingPathComponent("src", isDirectory: true)
        let toUrl = containerUrl.appendingPathComponent("dst", isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: fromUrl,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
            
            // Prepare png file
            let pngFile = fromUrl.appendingPathComponent("test.png")
            try "".write(to: pngFile, atomically: false, encoding: .utf8)
            
            // Prepare random file
            let randomFile = fromUrl.appendingPathComponent("test.file")
            try "".write(to: randomFile, atomically: false, encoding: .utf8)
        } catch {
            XCTFail("Could not prepare source directory")
        }
        
        var isDir: ObjCBool = false
        
        XCTAssert(FileManager.default.fileExists(atPath: fromUrl.path, isDirectory: &isDir))
        XCTAssert(isDir.boolValue)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: toUrl.path))
        
        let source = TabPreviewsSource(storeDir: toUrl, legacyDir: fromUrl)
        source.prepare()
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: fromUrl.path))

        XCTAssert(FileManager.default.fileExists(atPath: toUrl.path, isDirectory: &isDir))
        XCTAssert(isDir.boolValue)
        
        let pngFile = toUrl.appendingPathComponent("test.png")
        XCTAssert(FileManager.default.fileExists(atPath: pngFile.path))
        let testFile = toUrl.appendingPathComponent("test.file")
        XCTAssertFalse(FileManager.default.fileExists(atPath: testFile.path))
    }
    
    func testWhenStoreDirCreatedThenItIsNotBackedUp() {
        guard let containerUrl = containerUrl else {
            XCTFail("Could not determine containerUrl")
            return
        }
        
        let fromUrl = containerUrl.appendingPathComponent("src", isDirectory: true)
        let toUrl = containerUrl.appendingPathComponent("dst", isDirectory: true)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: toUrl.path))
        
        let source = TabPreviewsSource(storeDir: toUrl, legacyDir: fromUrl)
        source.prepare()
        
        var isDir: ObjCBool = false
        XCTAssert(FileManager.default.fileExists(atPath: toUrl.path, isDirectory: &isDir))
        XCTAssert(isDir.boolValue)
        
        do {
            var storeUrl = toUrl
            storeUrl.removeAllCachedResourceValues()
            let values = try storeUrl.resourceValues(forKeys: [URLResourceKey.isExcludedFromBackupKey])
            
            XCTAssert(values.isExcludedFromBackup ?? false)
        } catch {
            XCTFail("Could not determine resource values")
        }
    }
    
}
