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
        PixelFiringMock.tearDown()
        duckPlayerOverlayPixels = DuckPlayerOverlayUsagePixels(pixelFiring: PixelFiringMock.self, timeoutInterval: 3.0)
    }

    override func tearDown() {
        PixelFiringMock.tearDown()
        duckPlayerOverlayPixels = nil
        super.tearDown()
    }
    
    // Test: Registering navigation appends URL to history
    func testRegisterNavigationAppendsURLToHistory() {
        let testURL1 = URL(string: "https://www.youtube.com/watch?v=example1")!
        let testURL2 = URL(string: "https://www.youtube.com/playlist?list=PL-gbSnmxoBbmDnoFdZY5OsSuU6kqs_07a")!
        let testURL3 = URL(string: "https://www.example.com")!
        
        // Simulate navigation actions
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL1, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL2, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL3, duckPlayerMode: .alwaysAsk)
        
        // Verify the URLs are appended in order
        XCTAssertEqual(duckPlayerOverlayPixels.navigationHistory.count, 3)
        XCTAssertEqual(duckPlayerOverlayPixels.navigationHistory[0], testURL1.forComparison())
        XCTAssertEqual(duckPlayerOverlayPixels.navigationHistory[1], testURL2.forComparison())
        XCTAssertEqual(duckPlayerOverlayPixels.navigationHistory[2], testURL3.forComparison())
    }

    // Test: Back navigation triggers duckPlayerYouTubeOverlayNavigationBack pixel
    func testBackNavigationTriggersBackPixel() {
        let firstURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        let secondURL = URL(string: "https://www.youtube.com/watch?v=example2")!
        
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: firstURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: secondURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: firstURL, duckPlayerMode: .alwaysAsk) // Simulates back navigation
        
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationBack.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired on back navigation.")
    }

    // Test: Reload navigation triggers duckPlayerYouTubeOverlayNavigationRefresh pixel
    func testReloadNavigationTriggersRefreshPixel() {
        let testURL = URL(string: "https://www.youtube.com/watch?v=XTWWSS")!
        
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL, duckPlayerMode: .alwaysAsk) // Simulates reload navigation
        
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationRefresh.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired on reload navigation.")
    }

    // Test: Forward navigation to various YouTube URLs triggers duckPlayerYouTubeNavigationWithinYouTube pixel
    func testNavigateWithinYoutubeTriggersWithinYouTubePixel() {
        let videoURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        let playlistURL = URL(string: "https://www.youtube.com/playlist?list=PL-gbSnmxoBbmDnoFdZY5OsSuU6kqs_07a")!
        
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: videoURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: playlistURL, duckPlayerMode: .alwaysAsk)
        
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeNavigationWithinYouTube.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when navigating within YouTube to a non-video URL.")
    }

    // Test: Navigating outside YouTube triggers duckPlayerYouTubeOverlayNavigationOutsideYoutube pixel
    func testNavigateOutsideYoutubeTriggersOutsideYouTubePixel() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        let outsideURL = URL(string: "https://www.example.com")!
        
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: youtubeURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: outsideURL, duckPlayerMode: .alwaysAsk)
        
        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationOutsideYoutube.name)
        XCTAssertNotNil(PixelFiringMock.lastPixelInfo, "Pixel should be fired when navigating outside YouTube.")
    }

    // Negative Test: Back navigation does not trigger within YouTube or outside YouTube pixel
    func testBackNavigationDoesNotTriggerWithinOrOutsideYouTubePixel() {
        let firstURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        let secondURL = URL(string: "https://www.youtube.com/watch?v=example2")!
        let backURL = URL(string: "https://www.youtube.com/watch?v=example1")!
        
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: firstURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: secondURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: backURL, duckPlayerMode: .alwaysAsk) // Simulates back navigation
        
        XCTAssertNotEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeNavigationWithinYouTube.name, "Within YouTube pixel should not fire on back navigation.")
        XCTAssertNotEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationOutsideYoutube.name, "Outside YouTube pixel should not fire on back navigation.")
    }

    // Negative Test: Reload navigation does not trigger within YouTube or outside YouTube pixel
    func testReloadNavigationDoesNotTriggerWithinOrOutsideYouTubePixel() {
        let testURL = URL(string: "https://www.youtube.com/watch?v=example")!
        
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL, duckPlayerMode: .alwaysAsk)
        duckPlayerOverlayPixels.handleNavigationAndFirePixels(url: testURL, duckPlayerMode: .alwaysAsk) // Simulates reload navigation
        
        XCTAssertNotEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeNavigationWithinYouTube.name, "Within YouTube pixel should not fire on reload.")
        XCTAssertNotEqual(PixelFiringMock.lastPixelName, Pixel.Event.duckPlayerYouTubeOverlayNavigationOutsideYoutube.name, "Outside YouTube pixel should not fire on reload.")
    }
}
