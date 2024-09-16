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
    var timestampStorage: KeyValueStoring!

    var testDateString: String!
    var oldDateString: String!

    override func setUp() {
        super.setUp()
        let (url, storage) = createPersistentStorage()
        self.currentStorageURL = url
        self.persistentStorage = storage
        self.timestampStorage = MockKeyValueStore()

        PixelFiringMock.tearDown()
        DelayedPixelFiringMock.tearDown()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        testDateString = formatter.string(from: Date())
        oldDateString = formatter.string(from: Date().addingTimeInterval(-.days(30)))
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
            completion: { errors in
                expectation.fulfill()
                XCTAssert(errors.isEmpty)
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
        let error = NSError(domain: "domain", code: 1)
        let expectation = expectation(description: "fireDailyAndCount")

        persistentPixel.fireDailyAndCount(
            pixel: .appLaunch,
            error: error,
            withAdditionalParameters: ["param": "value"],
            includedParameters: [.appVersion],
            completion: { errors in
                expectation.fulfill()
                XCTAssert(errors.isEmpty)
            }
        )

        wait(for: [expectation], timeout: 1.0)

        let storedPixels = try persistentStorage.storedPixels()
        let expectedParams = [
            "param": "value",
            PixelParameters.originalPixelTimestamp: testDateString,
            PixelParameters.errorDomain: error.domain,
            PixelParameters.errorCode: "\(error.code)"
        ]

        XCTAssertEqual(storedPixels.count, 2)
        XCTAssert(storedPixels.contains {
            $0.eventName == Pixel.Event.appLaunch.name &&
            $0.pixelType == .daily &&
            $0.additionalParameters == expectedParams
        })

        XCTAssert(storedPixels.contains {
            $0.eventName == Pixel.Event.appLaunch.name &&
            $0.pixelType == .count &&
            $0.additionalParameters == expectedParams
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
            completion: { errors in
                expectation.fulfill()
                XCTAssert(errors.isEmpty)
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
    }

    func testWhenDailyPixelIsStored_AndSendQueuedPixelsIsCalled_ThenDailyPixelIsSent() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .daily,
            additionalParameters: ["key": "value", PixelParameters.originalPixelTimestamp: testDateString],
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
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, [
            "key": "value",
            PixelParameters.retriedPixel: "1",
            PixelParameters.originalPixelTimestamp: testDateString
        ])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenCountPixelIsStored_AndSendQueuedPixelsIsCalled_ThenCountPixelIsSent() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .count,
            additionalParameters: ["key": "value", PixelParameters.originalPixelTimestamp: testDateString],
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
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.params, [
            "key": "value",
            PixelParameters.retriedPixel: "1",
            PixelParameters.originalPixelTimestamp: testDateString
        ])
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.includedParams, [.appVersion])
    }

    func testWhenPixelIsStored_AndSendQueuedPixelsIsCalled_AndPixelIsOlderThan28Days_ThenPixelIsNotSent_AndPixelIsNoLongerStored() throws {
        let persistentPixel = createPersistentPixel()
        let expectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .daily,
            additionalParameters: ["key": "value", PixelParameters.originalPixelTimestamp: oldDateString],
            includedParameters: [.appVersion]
        )

        try persistentStorage.replaceStoredPixels(with: [pixel])
        persistentPixel.sendQueuedPixels { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        let storedPixels = try persistentStorage.storedPixels()
        XCTAssert(storedPixels.isEmpty)

        XCTAssertNil(PixelFiringMock.lastPixelName)
        XCTAssertNil(PixelFiringMock.lastDailyPixelInfo)
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
        let initialPixel = PersistentPixelMetadata(
            eventName: "test",
            pixelType: .count,
            additionalParameters: [PixelParameters.originalPixelTimestamp: testDateString],
            includedParameters: [.appVersion]
        )

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

    func testWhenPixelQueueHasRecentlyProcessed_ThenPixelsAreNotProcessed() throws {
        let currentDate = Date()
        let persistentPixel = createPersistentPixel(dateGenerator: { currentDate })
        let sendQueuedPixelsExpectation = expectation(description: "sendQueuedPixels")

        let pixel = PersistentPixelMetadata(
            eventName: "unfired_pixel",
            pixelType: .count,
            additionalParameters: [PixelParameters.originalPixelTimestamp: testDateString],
            includedParameters: [.appVersion]
        )

        try persistentStorage.replaceStoredPixels(with: [pixel])

        // Set a last processing date of 1 minute ago:
        timestampStorage.set(currentDate.addingTimeInterval(-60), forKey: PersistentPixel.Constants.lastProcessingDateKey)

        persistentPixel.sendQueuedPixels { _ in
            sendQueuedPixelsExpectation.fulfill()
        }

        wait(for: [sendQueuedPixelsExpectation], timeout: 3.0)

        let storedPixelsAfterSendingQueuedPixels = try persistentStorage.storedPixels()
        XCTAssertEqual(storedPixelsAfterSendingQueuedPixels, [pixel])
        XCTAssertNil(PixelFiringMock.lastPixelName)
    }

    // MARK: - Test Utilities

    private func createPersistentPixel(pixelFiring: PixelFiring.Type = PixelFiringMock.self,
                                       dailyPixelFiring: DailyPixelFiring.Type = PixelFiringMock.self,
                                       dateGenerator: (() -> Date)? = nil) -> PersistentPixel {
        return PersistentPixel(
            pixelFiring: pixelFiring,
            dailyPixelFiring: dailyPixelFiring,
            persistentPixelStorage: persistentStorage,
            lastProcessingDateStorage: timestampStorage,
            dateGenerator: dateGenerator ?? self.dateGenerator
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
