//
//  ContentBlockerStringCacheTests.swift
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
@testable import Core

class ContentBlockerStringCacheTests: XCTestCase {

    func testWhenRemovingLegacyDataThenStringCacheDirectoryIsRemoved() {
        
        let fileManager = FileManager.default
        let groupName = ContentBlockerStoreConstants.groupName
        let cacheDir = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupName)!.appendingPathComponent("string-cache")
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        let file = cacheDir.appendingPathComponent("test")
    
        do {
            try "test".write(to: file, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Unable to write file \(error.localizedDescription)")
        }
        
        ContentBlockerStringCache.removeLegacyData()
        
        XCTAssertFalse(fileManager.fileExists(atPath: cacheDir.absoluteString))
        
    }

}
