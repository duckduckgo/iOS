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
import Networking
import Persistence
import TestUtils
@testable import Core

final class PersistentPixelTests: XCTestCase {
    
    var currentStorageURL: URL!
    var persistentStorage: DefaultPersistentPixelStorage!
    let testDateString = "2024-01-01T12:00:00Z"

    override func setUp() {
        super.setUp()
        let (url, storage) = createPersistentStorage()
        self.currentStorageURL = url
        self.persistentStorage = storage

        PixelFiringMock.tearDown()
        DelayedPixelFiringMock.tearDown()
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: currentStorageURL)

        PixelFiringMock.tearDown()
        DelayedPixelFiringMock.tearDown()
    }

    func testWhenDailyAndCountPixelsSendSuccessfully_ThenNoPixelsAreStored() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "fireDailyAndCount")

        persistentPixel.fireDailyAndCount(
            pixel: .appLaunch,
            withAdditionalParameters: ["key": "value"],
            includedParameters: [.appVersion, .atb],
            completion: { error in
                expectation.fulfill()
                XCTAssertNil(error)
            }
        )

        wait(for: [expectation], timeout: 1.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssertEqual(storedPixels, [])

        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixel, Pixel.Event.appLaunch)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["key": "value", PixelParameters.originalPixelTimestamp: testDateString])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion, .atb])
    }

    func testWhenDailyAndCountPixelsFail_ThenPixelsAreStored() throws {
        PixelFiringMock.expectedDailyPixelFireError = NSError(domain: "PixelFailure", code: 1)
        PixelFiringMock.expectedCountPixelFireError = NSError(domain: "PixelFailure", code: 2)

        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "fireDailyAndCount")

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
        XCTAssert(storedPixels.contains {
            $0.eventName == Pixel.Event.appLaunch.name &&
            $0.pixelType == .daily &&
            $0.additionalParameters == ["param": "value", PixelParameters.originalPixelTimestamp: testDateString]
        })

        XCTAssert(storedPixels.contains {
            $0.eventName == Pixel.Event.appLaunch.name &&
            $0.pixelType == .count &&
            $0.additionalParameters == ["param": "value", PixelParameters.originalPixelTimestamp: testDateString]
        })

        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixel, Pixel.Event.appLaunch)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["param": "value", PixelParameters.originalPixelTimestamp: testDateString])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenOnlyCountPixelFails_ThenCountPixelIsStored() throws {
        PixelFiringMock.expectedCountPixelFireError = NSError(domain: "PixelFailure", code: 1)

        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "fireDailyAndCount")

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
        XCTAssertEqual(storedPixels.count, 1)
        XCTAssert(storedPixels.contains {
            $0.eventName == Pixel.Event.appLaunch.name &&
            $0.pixelType == .count &&
            $0.additionalParameters == ["param": "value", PixelParameters.originalPixelTimestamp: testDateString]
        })

        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixel, Pixel.Event.appLaunch)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["param": "value", PixelParameters.originalPixelTimestamp: testDateString])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenPixelsAreStored_AndSendQueuedPixelsIsCalled_AndPixelRetrySucceeds_ThenPixelIsRemovedFromStorage() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(eventName: "test1", pixelType: .count, additionalParameters: ["key": "value"], includedParameters: [.appVersion])
        let pixel2 = PersistentPixelMetadata(eventName: "test2", pixelType: .count, additionalParameters: ["key": "value"], includedParameters: [.appVersion])
        let pixel3 = PersistentPixelMetadata(eventName: "test3", pixelType: .count, additionalParameters: ["key": "value"], includedParameters: [.appVersion])
        let pixel4 = PersistentPixelMetadata(eventName: "test4", pixelType: .count, additionalParameters: ["key": "value"], includedParameters: [.appVersion])

        try persistentStorage.replaceStoredPixels(with: [pixel, pixel2, pixel3, pixel4])
        persistentPixel.sendQueuedPixels { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixels.isEmpty)

        // TODO: Test that the pixels successfully fired
    }

    func testWhenDailyPixelIsStored_AndSendQueuedPixelsIsCalled_ThenDailyPixelIsSent() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .daily,
            additionalParameters: ["key": "value"],
            includedParameters: [.appVersion]
        )

        try persistentStorage.replaceStoredPixels(with: [pixel])
        persistentPixel.sendQueuedPixels { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixels.isEmpty)

        XCTAssertEqual(PixelFiringMock.lastPixelName, "test_d")
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["key": "value", PixelParameters.retriedPixel: "1"])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenCountPixelIsStored_AndSendQueuedPixelsIsCalled_ThenCountPixelIsSent() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .count,
            additionalParameters: ["key": "value"],
            includedParameters: [.appVersion]
        )

        try persistentStorage.replaceStoredPixels(with: [pixel])
        persistentPixel.sendQueuedPixels { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixels.isEmpty)

        XCTAssertEqual(PixelFiringMock.lastPixelName, "test_c")
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, ["key": "value", PixelParameters.retriedPixel: "1"])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenPixelQueueIsProcessing_AndProcessingSucceeds_AndNewFailedPixelIsReceived_ThenPixelIsNotStoredUntilProcessingIsComplete() throws {
        PixelFiringMock.expectedCountPixelFireError = NSError(domain: "PixelFailure", code: 1)

        let persistentPixel = createPersistentPixel(pixelFiring: DelayedPixelFiringMock.self)
        let sendQueuedPixelsExpectation = expectation(description: "sendQueuedPixels")

        let initialPixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .count,
            additionalParameters: [PixelParameters.originalPixelTimestamp: testDateString],
            includedParameters: [.appVersion]
        )

        try persistentStorage.replaceStoredPixels(with: [initialPixel])

        // Initiate pixel queue processing:
        persistentPixel.sendQueuedPixels { _ in
            sendQueuedPixelsExpectation.fulfill()
        }

        // Trigger a failed pixel call while processing:
        persistentPixel.fireDailyAndCount(pixel: .appLaunch, withAdditionalParameters: [:], includedParameters: [.appVersion], completion: { _ in })

        // Check that the failed pixel call didn't cause a pixel to get stored:
        let storedPixelsWhenSendingQueuedPixels = try persistentStorage.storedPixels()
        XCTAssertEqual(storedPixelsWhenSendingQueuedPixels, [initialPixel])

        // Complete pixel processing callback:
        DelayedPixelFiringMock.callCompletionHandler()

        wait(for: [sendQueuedPixelsExpectation], timeout: 3.0)

        // Check that the incoming failed pixel call is now stored and ready to retry for next time:
        let expectedPixel = PersistentPixelMetadata(
            eventName: Pixel.Event.appLaunch.name,
            pixelType: .count,
            additionalParameters: [PixelParameters.originalPixelTimestamp: testDateString],
            includedParameters: [.appVersion]
        )

        let storedPixelsAfterSendingQueuedPixels = try persistentStorage.storedPixels()
        XCTAssertEqual(storedPixelsAfterSendingQueuedPixels, [expectedPixel])
    }

    func testWhenPixelQueueIsProcessing_AndProcessingFails_AndNewFailedPixelIsReceived_ThenExistingAndNewPixelsAreStored() throws {
        PixelFiringMock.expectedCountPixelFireError = NSError(domain: "PixelFailure", code: 1)
        DelayedPixelFiringMock.completionError = NSError(domain: "PixelFailure", code: 1)

        let persistentPixel = createPersistentPixel(pixelFiring: DelayedPixelFiringMock.self)
        let initialPixel = PersistentPixelMetadata(eventName: "test", pixelType: .count, additionalParameters: [:], includedParameters: [.appVersion])
        try persistentStorage.replaceStoredPixels(with: [initialPixel])

        let sendQueuedPixelsExpectation = expectation(description: "sendQueuedPixels")

        // Initiate pixel queue processing:
        persistentPixel.sendQueuedPixels { _ in
            sendQueuedPixelsExpectation.fulfill()
        }

        // Trigger a failed pixel call while processing:
        persistentPixel.fireDailyAndCount(pixel: .appLaunch, withAdditionalParameters: [:], includedParameters: [.appVersion], completion: { _ in })

        // Check that the failed pixel call didn't cause a pixel to get stored:
        let storedPixelsWhenSendingQueuedPixels = try persistentStorage.storedPixels()
        XCTAssertEqual(storedPixelsWhenSendingQueuedPixels, [initialPixel])

        // Complete pixel processing callback:
        DelayedPixelFiringMock.callCompletionHandler()

        wait(for: [sendQueuedPixelsExpectation], timeout: 3.0)

        // Check that the incoming failed pixel call is now stored and ready to retry for next time:
        let expectedPixel = PersistentPixelMetadata(
            eventName: Pixel.Event.appLaunch.name,
            pixelType: .count,
            additionalParameters: [PixelParameters.originalPixelTimestamp: testDateString],
            includedParameters: [.appVersion]
        )

        let storedPixelsAfterSendingQueuedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixelsAfterSendingQueuedPixels.contains(initialPixel))
        XCTAssert(storedPixelsAfterSendingQueuedPixels.contains(expectedPixel))
    }

    // MARK: - Test Utilities

    private func createPersistentPixel(pixelFiring: PixelFiring.Type = PixelFiringMock.self,
                                       dailyPixelFiring: DailyPixelFiring.Type = PixelFiringMock.self) -> PersistentPixel {
        let timestampStorage = MockKeyValueStore()
        return PersistentPixel(
            pixelFiring: pixelFiring,
            dailyPixelFiring: dailyPixelFiring,
            persistentPixelStorage: persistentStorage,
            lastSentTimestampStorage: timestampStorage,
            dateGenerator: self.dateGenerator
        )
    }

    private func createPersistentStorage() -> (URL, DefaultPersistentPixelStorage) {
        let storageDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString.appendingPathExtension("json")

        return (
            storageDirectory.appendingPathComponent(fileName),
            DefaultPersistentPixelStorage(fileName: fileName, storageDirectory: storageDirectory)
        )
    }

    private func dateGenerator() -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: testDateString)!
    }

}

// MARK: - Mocks

/// Provides a way to receive a pixel call and let the caller control when it completes.
private class DelayedPixelFiringMock: PixelFiring {

    static var completionError: Error?
    static var lastCompletionHandler: ((Error?) -> Void)?

    static func tearDown() {
        completionError = nil
        lastCompletionHandler = nil
    }

    static func callCompletionHandler() {
        lastCompletionHandler?(completionError)
    }

    static func fire(_ pixel: Core.Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Core.Pixel.QueryParameters],
                     onComplete: @escaping ((any Error)?) -> Void) {
        lastCompletionHandler = onComplete
    }
    
    static func fire(_ pixel: Core.Pixel.Event, withAdditionalParameters params: [String: String]) {
        // no-op
    }
    
    static func fire(pixelNamed pixelName: String,
                     forDeviceType deviceType: UIUserInterfaceIdiom?,
                     withAdditionalParameters params: [String: String],
                     allowedQueryReservedCharacters: CharacterSet?,
                     withHeaders headers: Networking.APIRequest.Headers,
                     includedParameters: [Core.Pixel.QueryParameters],
                     onComplete: @escaping ((any Error)?) -> Void) {
        lastCompletionHandler = onComplete
    }
    

}
