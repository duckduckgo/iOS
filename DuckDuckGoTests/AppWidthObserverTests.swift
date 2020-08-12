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

    func testWhenNotInExperimentAndInitialWidthIsLargeThenReportsAsSmall() {
        let variantManager = MockVariantManager(isSupportedReturns: false, currentVariant: nil)
        let observer = AppWidthObserver(variantManager: variantManager)
        XCTAssertTrue(observer.willResize(toWidth: 10000))
        XCTAssertFalse(observer.isLargeWidth)
    }

    func testWhenInExperimentAndResizesToSameSizeThenWillNotResize() {
        let variantManager = MockVariantManager(isSupportedReturns: true, currentVariant: nil)
        let observer = AppWidthObserver(variantManager: variantManager)
        XCTAssertTrue(observer.willResize(toWidth: 10000))
        XCTAssertFalse(observer.willResize(toWidth: 10000))
    }

    func testWhenInExperimentAndInitialWidthIsLargeThenReportsAsLarge() {
        let variantManager = MockVariantManager(isSupportedReturns: true, currentVariant: nil)
        let observer = AppWidthObserver(variantManager: variantManager)
        XCTAssertTrue(observer.willResize(toWidth: 10000))
        XCTAssertTrue(observer.isLargeWidth)
    }

    func testWhenInExperimentAndInitialWidthIsSmallThenReportsAsSmall() {
        let variantManager = MockVariantManager(isSupportedReturns: true, currentVariant: nil)
        let observer = AppWidthObserver(variantManager: variantManager)
        XCTAssertTrue(observer.willResize(toWidth: 100))
        XCTAssertFalse(observer.isLargeWidth)
    }
    
}
