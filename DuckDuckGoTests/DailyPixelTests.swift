//
//  DailyPixelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Networking
import PersistenceTestingUtils
import Persistence
@testable import Core

final class DailyPixelTests: XCTestCase {

    let mockStore = MockKeyValueStore()

    override func tearDown() {
        super.tearDown()

        PixelFiringMock.tearDown()
    }

    func testThatDailyPixelFiresCorrectlyForTheFirstTime() {
        let expectation = XCTestExpectation()

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testThatDailyPixelFiresForTheFirstTimeButNotForTheSecond() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? DailyPixel.Error, .alreadyFired)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)

        wait(for: [expectation], timeout: 3.0)
    }
    
    func testThatDailyPixelWillFireIfFiredPreviouslyOnDifferentDay() {
        let expectation = XCTestExpectation()
        
        updateLastFireDateToYesterday(for: .forgetAllPressedBrowsing)
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatDailyPixelWithSameErrorFiresForTheFirstTimeButNotForTheSecond() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        let error = NSError(domain: "test", code: 0, userInfo: nil)

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? DailyPixel.Error, .alreadyFired)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)
        XCTAssertEqual(PixelFiringMock.lastPixelInfo?.error as? NSError, error)

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatDailyPixelWithTwoDifferentErrorsBothFireFirstTime() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        let error1 = NSError(domain: "test1", code: 1, userInfo: nil)
        let error2 = NSError(domain: "test2", code: 2, userInfo: nil)

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error1,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)
        XCTAssertEqual(PixelFiringMock.lastPixelInfo?.error as? NSError, error1)

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error2,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)
        XCTAssertEqual(PixelFiringMock.lastPixelInfo?.error as? NSError, error2)

        wait(for: [expectation], timeout: 3.0)
    }


    func testThatDailyPixelWithTwoDifferentErrorsBothFireFirstTimeButNotForTheSecond() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 4

        let error1 = NSError(domain: "test1", code: 1, userInfo: nil)
        let error2 = NSError(domain: "test1", code: 2, userInfo: nil)

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error1,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)
        XCTAssertEqual(PixelFiringMock.lastPixelInfo?.error as? NSError, error1)


        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error2,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.forgetAllPressedBrowsing.name)
        XCTAssertEqual(PixelFiringMock.lastPixelInfo?.error as? NSError, error2)

        PixelFiringMock.tearDown()

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error1,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? DailyPixel.Error, .alreadyFired)
            expectation.fulfill()
        }

        XCTAssertNil(PixelFiringMock.lastPixelName)

        DailyPixel.fire(pixel: .forgetAllPressedBrowsing,
                        error: error2,
                        pixelFiring: PixelFiringMock.self,
                        dailyPixelStore: mockStore) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? DailyPixel.Error, .alreadyFired)
            expectation.fulfill()
        }

        XCTAssertNil(PixelFiringMock.lastPixelName)

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatDailyPixelWithCountFiresCorrectlyForTheFirstTime() {
        let countExpectation = XCTestExpectation()
        let dailyExpectation = XCTestExpectation()

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onDailyComplete: { error in
                XCTAssertNil(error)
                dailyExpectation.fulfill()

            },
            onCountComplete: { error in
                XCTAssertNil(error)
                countExpectation.fulfill()
            }
        )

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 2)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_d")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")

        wait(for: [countExpectation, dailyExpectation], timeout: 3.0)
    }

    func testThatDailyPixelWithCount_DailyFiresForTheFirstTimeButNotForTheSecond() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onDailyComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onDailyComplete: { error in
                XCTAssertNotNil(error)
                XCTAssertEqual(error as? DailyPixel.Error, .alreadyFired)
                expectation.fulfill()
            }
        )

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 3)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_d")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[2].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatDailyPixelWithCountBubblesUpNetworkErrors() {
        let countExpectation = XCTestExpectation()
        let dailyExpectation = XCTestExpectation()

        PixelFiringMock.expectedFireError = TestError.testError

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onDailyComplete: { error in
                XCTAssertNotNil(error)
                dailyExpectation.fulfill()
            },
            onCountComplete: { error in
                XCTAssertNotNil(error)
                countExpectation.fulfill()
            }
        )

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 2)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_d")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")

        wait(for: [countExpectation, dailyExpectation], timeout: 3.0)
    }

    func testThatDailyPixelWithCount_CountFiresBothTimes() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onCountComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onCountComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 3)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_d")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[2].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatDailyPixelWithCountWillFireIfFiredPreviouslyOnDifferentDay() {
        let expectation = XCTestExpectation()

        updateLastFireDateToYesterday(for: .forgetAllPressedBrowsing)

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onDailyComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 2)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_d")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatDailyPixelWithLegacyPixelSuffixAndCountWillAppendDAndC() {
        let expectation = XCTestExpectation()

        updateLastFireDateToYesterday(for: .forgetAllPressedBrowsing)

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onCountComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 2)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_d")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_c")
    }

    func testThatDailyPixelWithModernPixelSuffixesWillAppendDailyAndCount() {
        let expectation = XCTestExpectation()

        updateLastFireDateToYesterday(for: .forgetAllPressedBrowsing)

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelNameSuffixes: DailyPixel.Constant.dailyPixelSuffixes,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onCountComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 2)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_daily")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_count")
    }

    func testThatDailyPixelWithDefaultPixelSuffixesWillAppendDailyAndCount() {
        let expectation = XCTestExpectation()

        updateLastFireDateToYesterday(for: .forgetAllPressedBrowsing)

        DailyPixel.fireDailyAndCount(
            pixel: .forgetAllPressedBrowsing,
            pixelFiring: PixelFiringMock.self,
            dailyPixelStore: mockStore,
            onCountComplete: { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(PixelFiringMock.allPixelsFired.count, 2)
        XCTAssertEqual(PixelFiringMock.allPixelsFired[0].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_daily")
        XCTAssertEqual(PixelFiringMock.allPixelsFired[1].pixelName, Pixel.Event.forgetAllPressedBrowsing.name + "_count")
    }

    private func updateLastFireDateToYesterday(for pixel: Pixel.Event) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        mockStore.set(yesterday, forKey: pixel.name)
    }

    private enum TestError: Error {
        case testError
    }
}
