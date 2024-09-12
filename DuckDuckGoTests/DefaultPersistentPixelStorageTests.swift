//
//  DefaultPersistentPixelStorageTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import XCTest
@testable import Core

class DefaultPersistentPixelStorageTests: XCTestCase {

    var currentStorageURL: URL!
    var persistentStorage: DefaultPersistentPixelStorage!

    override func setUp() {
        super.setUp()
        let (url, storage) = createPersistentStorage()
        self.currentStorageURL = url
        self.persistentStorage = storage
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: currentStorageURL)
    }

    func testWhenStoringPixel_ThenPixelCanBeSuccessfullyRead() throws {
        let metadata = PersistentPixelMetadata(pixelName: "test", parameters: ["param": "value"])
        try persistentStorage.append(pixel: metadata)
        let readPixelMetadata = try persistentStorage.storedPixels()

        XCTAssertEqual([metadata], readPixelMetadata)
    }

    func testWhenStoringMultiplePixels_ThenPixelsCanBeSuccessfullyRead() throws {
        let metadata1 = PersistentPixelMetadata(pixelName: "test1", parameters: ["param1": "value1"])
        let metadata2 = PersistentPixelMetadata(pixelName: "test2", parameters: ["param2": "value2"])
        let metadata3 = PersistentPixelMetadata(pixelName: "test3", parameters: ["param3": "value3"])

        try persistentStorage.append(pixel: metadata1)
        try persistentStorage.append(pixel: metadata2)
        try persistentStorage.append(pixel: metadata3)

        let readPixelMetadata = try persistentStorage.storedPixels()

        XCTAssertEqual([metadata1, metadata2, metadata3], readPixelMetadata)
    }

    func testWhenReplacingPixels_AndNoPixelsAreStored_ThenNewPixelsAreStored() throws {
        let metadata = PersistentPixelMetadata(pixelName: "test", parameters: ["param": "value"])
        try persistentStorage.replaceStoredPixels(with: [metadata])
        let readPixelMetadata = try persistentStorage.storedPixels()

        XCTAssertEqual([metadata], readPixelMetadata)
    }

    func testWhenReplacingPixels_AndExistingPixelsAreStored_ThenOldPixelsAreReplacedWithNewOnes() throws {
        let initialMetadata = PersistentPixelMetadata(pixelName: "old", parameters: ["param1": "value1"])
        try persistentStorage.replaceStoredPixels(with: [initialMetadata])

        let newMetadata = PersistentPixelMetadata(pixelName: "new", parameters: ["param2": "value2"])
        try persistentStorage.replaceStoredPixels(with: [newMetadata])

        let readPixelMetadata = try persistentStorage.storedPixels()
        XCTAssertEqual([newMetadata], readPixelMetadata)
    }

    // MARK: - Test Utilities

    private func createPersistentStorage() -> (URL, DefaultPersistentPixelStorage) {
        let storageDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString.appendingPathExtension("json")

        return (
            storageDirectory.appendingPathComponent(fileName),
            DefaultPersistentPixelStorage(fileName: fileName, storageDirectory: storageDirectory)
        )
    }

}
