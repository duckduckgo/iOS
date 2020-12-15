//
//  AppWidthObserverTests.swift
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

class AppWidthObserverTests: XCTestCase {

    func testWhenNotPadThenWillNotResizeOrReportAsLarge() {
        AppWidthObserver.shared.isPad = false
        AppWidthObserver.shared.currentWidth = 0
        XCTAssertFalse(AppWidthObserver.shared.willResize(toWidth: 10000))

        AppWidthObserver.shared.currentWidth = 10000
        XCTAssertFalse(AppWidthObserver.shared.isLargeWidth)
    }

    func testWhenResizesToSameSizeThenWillNotResize() {
        AppWidthObserver.shared.isPad = true
        AppWidthObserver.shared.currentWidth = 0
        XCTAssertTrue(AppWidthObserver.shared.willResize(toWidth: 10000))
        XCTAssertFalse(AppWidthObserver.shared.willResize(toWidth: 10000))
    }

    func testWhenInitialWidthIsLargeThenReportsAsLarge() {
        AppWidthObserver.shared.isPad = true
        AppWidthObserver.shared.currentWidth = 0
        XCTAssertTrue(AppWidthObserver.shared.willResize(toWidth: 10000))
        XCTAssertTrue(AppWidthObserver.shared.isLargeWidth)
    }

    func testWhenInitialWidthIsSmallThenReportsAsSmall() {
        AppWidthObserver.shared.isPad = true
        AppWidthObserver.shared.currentWidth = 0
        XCTAssertTrue(AppWidthObserver.shared.willResize(toWidth: 100))
        XCTAssertFalse(AppWidthObserver.shared.isLargeWidth)
    }
    
}
