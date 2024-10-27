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
        let metadata = event(named: "test", parameters: ["param": "value"])
        try persistentStorage.append(pixels: [metadata])
        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual([metadata], storedPixels)
    }

    func testWhenStoringMultiplePixels_ThenPixelsCanBeSuccessfullyRead() throws {
        let metadata1 = event(named: "test1", parameters: ["param1": "value1"])
        let metadata2 = event(named: "test2", parameters: ["param2": "value2"])
        let metadata3 = event(named: "test3", parameters: ["param3": "value3"])

        try persistentStorage.append(pixels: [metadata1, metadata2, metadata3])

        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual([metadata1, metadata2, metadata3], storedPixels)
    }

    func testWhenStoringMorePixelsThanTheLimit_AndPixelsAreAddedIncrementally_ThenOldPixelsAreDropped() throws {
        for index in 1...(DefaultPersistentPixelStorage.Constants.pixelCountLimit + 50) {
            let metadata = event(named: "pixel\(index)", parameters: ["param\(index)": "value\(index)"])
            try persistentStorage.append(pixels: [metadata])
        }

        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual(storedPixels.count, DefaultPersistentPixelStorage.Constants.pixelCountLimit)
        XCTAssertEqual(storedPixels.first?.eventName, "pixel51")
        XCTAssertEqual(storedPixels.last?.eventName, "pixel150")
    }

    func testWhenStoringMorePixelsThanTheLimit_AndPixelsAreAddedInASingleBatch_ThenOldPixelsAreDropped() throws {
        var pixelsToAdd: [PersistentPixelMetadata] = []

        for index in 1...(DefaultPersistentPixelStorage.Constants.pixelCountLimit + 50) {
            let metadata = event(named: "pixel\(index)", parameters: ["param\(index)": "value\(index)"])
            pixelsToAdd.append(metadata)
        }

        try persistentStorage.append(pixels: pixelsToAdd)

        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual(storedPixels.count, DefaultPersistentPixelStorage.Constants.pixelCountLimit)
        XCTAssertEqual(storedPixels.first?.eventName, "pixel51")
        XCTAssertEqual(storedPixels.last?.eventName, "pixel150")
    }

    func testWhenRemovingPixels_AndNoPixelsAreStored_ThenNothingHappens() throws {
        try persistentStorage.remove(pixelsWithIDs: Set([UUID()]))
        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual([], storedPixels)
    }

    func testWhenRemovingPixels_AndIDDoesNotMatchStoredPixel_ThenNothingHappens() throws {
        let metadata = event(named: "test", parameters: ["param": "value"])
        try persistentStorage.append(pixels: [metadata])
        try persistentStorage.remove(pixelsWithIDs: Set([UUID()]))
        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual([metadata], storedPixels)
    }

    func testWhenRemovingPixels_AndIDMatchesStoredPixel_ThenPixelIsRemoved() throws {
        let metadata = event(named: "test", parameters: ["param": "value"])
        try persistentStorage.remove(pixelsWithIDs: Set([metadata.id]))
        let storedPixels = try persistentStorage.storedPixels()

        XCTAssertEqual([], storedPixels)
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

    private func event(named name: String, parameters: [String: String]) -> PersistentPixelMetadata {
        return PersistentPixelMetadata(eventName: name, additionalParameters: parameters, includedParameters: [.appVersion])
    }

}
