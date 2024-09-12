//
//  PersistentPixelTests.swift
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
import Persistence
import TestUtils
@testable import Core

final class PersistentPixelTests: XCTestCase {
    
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
        PixelFiringMock.tearDown()
    }

    func testWhenDailyAndCountPixelsSendSuccessfully_ThenNoPixelsAreStored() throws {
        let timestampStorage = MockKeyValueStore()
        let persistentPixel = PersistentPixel(
            pixelFiring: PixelFiringMock.self,
            dailyPixelFiring: PixelFiringMock.self,
            persistentPixelStorage: persistentStorage,
            lastSentTimestampStorage: timestampStorage)

        let expectation = expectation(description: "completion")

        persistentPixel.fireDailyAndCount(
            pixel: .appLaunch,
            withAdditionalParameters: ["param": "value"],
            includedParameters: [.appVersion],
            completion: { error in
                expectation.fulfill()
                XCTAssertNil(error)
            }
        )

        wait(for: [expectation], timeout: 1.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixels.isEmpty)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixel, Pixel.Event.appLaunch)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["param": "value"])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenDailyAndCountPixelsFail_ThenPixelsAreStored() throws {
        PixelFiringMock.expectedDailyPixelFireError = NSError(domain: "PixelFailure", code: 1)
        PixelFiringMock.expectedCountPixelFireError = NSError(domain: "PixelFailure", code: 2)

        let timestampStorage = MockKeyValueStore()
        let persistentPixel = PersistentPixel(
            pixelFiring: PixelFiringMock.self,
            dailyPixelFiring: PixelFiringMock.self,
            persistentPixelStorage: persistentStorage,
            lastSentTimestampStorage: timestampStorage)

        let expectation = expectation(description: "completion")

        persistentPixel.fireDailyAndCount(
            pixel: .appLaunch,
            withAdditionalParameters: ["param": "value"],
            includedParameters: [.appVersion],
            completion: { error in
                expectation.fulfill()
                XCTAssertNil(error)
            }
        )

        wait(for: [expectation], timeout: 1.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssertEqual(storedPixels.count, 2)
        XCTAssert(storedPixels.contains { $0.event == .appLaunch && $0.pixelType == .daily })
        XCTAssert(storedPixels.contains { $0.event == .appLaunch && $0.pixelType == .count })

        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixel, Pixel.Event.appLaunch)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["param": "value"])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenPixelsAreStored_AndSendQueuedPixelsIsCalled_AndPixelRetrySucceeds_ThenPixelIsRemovedFromStorage() throws {
        let timestampStorage = MockKeyValueStore()
        let persistentPixel = PersistentPixel(
            pixelFiring: PixelFiringMock.self,
            dailyPixelFiring: PixelFiringMock.self,
            persistentPixelStorage: persistentStorage,
            lastSentTimestampStorage: timestampStorage
        )

        let expectation = expectation(description: "completion")

        let pixel = PersistentPixelMetadata(event: .appLaunch, pixelType: .count, parameters: ["key": "value"])
        let pixel2 = PersistentPixelMetadata(event: .networkProtectionTunnelStartAttempt, pixelType: .count, parameters: ["key": "value"])
        let pixel3 = PersistentPixelMetadata(event: .networkProtectionTunnelStopAttempt, pixelType: .count, parameters: ["key": "value"])
        let pixel4 = PersistentPixelMetadata(event: .networkProtectionTunnelUpdateAttempt, pixelType: .count, parameters: ["key": "value"])

        try persistentStorage.replaceStoredPixels(with: [pixel, pixel2, pixel3, pixel4])
        persistentPixel.sendQueuedPixels { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixels.isEmpty)

        // TODO: Test that the pixels successfully fired
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
