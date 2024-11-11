//
//  DuckPlayerOverlayUsagePixelsTests.swift
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

import XCTest
import Core
@testable import DuckDuckGo

class DuckPlayerOverlayUsagePixelsTests: XCTestCase {

    var duckPlayerOverlayPixels: DuckPlayerOverlayUsagePixels!

    override func setUp() {
        super.setUp()
        // Initialize DuckPlayerOverlayUsagePixels with a shorter timeoutInterval for testing
        PixelFiringMock.tearDown()
        duckPlayerOverlayPixels = DuckPlayerOverlayUsagePixels(pixelFiring: PixelFiringMock.self, timeoutInterval: 3.0)
    }

    override func tearDown() {
        // Clean up after each test
        PixelFiringMock.tearDown()
        duckPlayerOverlayPixels = nil
        super.tearDown()
    }

    func testRegisterNavigationAddsURLToHistory() {
        // Arrange
        let testURL = URL(string: "https://www.example.com")!

        // Act
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Assert
        XCTAssertEqual(duckPlayerOverlayPixels.navigationHistory.count, 1)
        XCTAssertEqual(duckPlayerOverlayPixels.navigationHistory.first, testURL)
    }

    func testRegisterNavigationWithNilURLDoesNotAddToHistory() {
        // Act
        duckPlayerOverlayPixels.registerNavigation(url: nil)

        // Assert
        XCTAssertTrue(duckPlayerOverlayPixels.navigationHistory.isEmpty, "Navigation history should remain empty when registering a nil URL.")
    }

    func testNavigationBackFiresPixelWhenConditionsMet() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.navigationBack(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationBack.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when conditions are met for navigationBack.")
    }

    func testNavigationBackDoesNotFirePixelWhenConditionsNotMet() {
        // Act
        duckPlayerOverlayPixels.navigationBack(duckPlayerMode: .enabled)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired when conditions are not met for navigationBack.")
    }

    func testNavigationReloadFiresPixelWhenConditionsMet() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.navigationReload(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationRefresh.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when conditions are met for navigationReload.")
    }

    func testNavigationReloadDoesNotFirePixelWhenConditionsNotMet() {
        // Act
        duckPlayerOverlayPixels.navigationReload(duckPlayerMode: .enabled)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired when conditions are not met for navigationReload.")
    }

    func testNavigationWithinYoutubeFiresPixelWhenConditionsMet() {
        // Arrange
        let previousURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        let currentURL = URL(string: "https://www.youtube.com/watch?v=example2")!
        duckPlayerOverlayPixels.registerNavigation(url: previousURL)
        duckPlayerOverlayPixels.registerNavigation(url: currentURL)

        // Act
        duckPlayerOverlayPixels.navigationWithinYoutube(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeNavigationWithinYouTube.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when conditions are met for navigationWithinYoutube.")
    }

    func testNavigationWithinYoutubeDoesNotFirePixelWhenConditionsNotMet() {
        // Arrange
        let testURL = URL(string: "https://www.example.com")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.navigationWithinYoutube(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired when conditions are not met for navigationWithinYoutube.")
    }

    func testNavigationOutsideYoutubeFiresPixelWhenConditionsMet() {
        // Arrange
        let previousURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        let currentURL = URL(string: "https://www.example.com")!
        duckPlayerOverlayPixels.registerNavigation(url: previousURL)
        duckPlayerOverlayPixels.registerNavigation(url: currentURL)

        // Act
        duckPlayerOverlayPixels.navigationOutsideYoutube(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationOutsideYoutube.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when conditions are met for navigationOutsideYoutube.")
    }

    func testNavigationOutsideYoutubeDoesNotFirePixelWhenConditionsNotMet() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.navigationOutsideYoutube(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired when conditions are not met for navigationOutsideYoutube.")
    }

    func testOverlayIdleStartsTimerAndFiresPixelAfter3Seconds() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.overlayIdle(duckPlayerMode: .alwaysAsk)

        // Simulate waiting for 3 seconds
        let expectation = XCTestExpectation(description: "Wait for the pixel to be fired after 3 seconds.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)

        // Assert
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeNavigationIdle30.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired after 3 seconds of inactivity.")
    }

    func testOverlayIdleDoesNotFirePixelWhenNavigationHistoryIsNotYouTubeWatch() {
        // Arrange
        let testURL = URL(string: "https://www.example.com")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.overlayIdle(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired if the last URL is not a YouTube watch URL.")
    }

    func testOverlayIdleDoesNotStartTimerIfModeIsNotAlwaysAsk() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.overlayIdle(duckPlayerMode: .enabled)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired if the mode is not .alwaysAsk.")
    }
    
    func testNavigationClosedFiresPixelWhenConditionsMet() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.navigationClosed(duckPlayerMode: .alwaysAsk)

        // Assert
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationClosed.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when conditions are met for navigationReload.")
    }
    
    func testNavigationClosedDoesNotFirePixelWhenConditionsNotMet() {
        // Arrange
        let testURL = URL(string: "https://www.youtube.com")!
        duckPlayerOverlayPixels.registerNavigation(url: testURL)

        // Act
        duckPlayerOverlayPixels.navigationClosed(duckPlayerMode: .enabled)

        // Assert
        XCTAssertNil(PixelFiringMock.lastPixelName, "Pixel should not be fired when conditions are not met for navigationClosed.")
    }
}
