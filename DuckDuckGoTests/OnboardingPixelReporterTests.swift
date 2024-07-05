//
//  OnboardingPixelReporterTests.swift
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

final class OnboardingPixelReporterTests: XCTestCase {
    private var sut: OnboardingPixelReporter!
    private var store: OnboardingPixelReporterStoreMock!

    override func setUpWithError() throws {
        store = OnboardingPixelReporterStoreMock()
        sut = OnboardingPixelReporter(store: store, pixel: OnboardingPixelFireMock.self)
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        OnboardingPixelFireMock.tearDown()
        store = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenTrackOnboardingIntroImpressionThenOnboardingIntroShownEventFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroShownUnique
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackOnboardingIntroImpression()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_preonboarding_intro_shown_unique")
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackOnboardingIntroImpressionAndPixelHasAlreadyFiredThenPixelDoesNotFire() {
        // GIVEN
        store.hasFiredIntroScreenShownPixel = true
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackOnboardingIntroImpression()

        // THEN
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])
    }

    func testWhenOnboardingIntroShownPixelFiresThenStoreIsUpdated() {
        // GIVEN
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])
        XCTAssertFalse(store.hasFiredIntroScreenShownPixel)

        // WHEN
        sut.trackOnboardingIntroImpression()

        // THEN
        XCTAssertTrue(store.hasFiredIntroScreenShownPixel)
    }

    func testWhenTrackBrowserComparisonImpressionThenOnboardingIntroComparisonChartShownEventFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroComparisonChartShownUnique
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackBrowserComparisonImpression()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_preonboarding_comparison_chart_shown_unique")
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackBrowserComparisonImpressionAndPixelHasAlreadyFiredThenPixelDoesNotFire() {
        // GIVEN
        store.hasFiredComparisonChartShownPixel = true
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackBrowserComparisonImpression()

        // THEN
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])
    }

    func testWhenOnboardingIntroComparisonChartShownPixelFiresThenStoreIsUpdated() {
        // GIVEN
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])
        XCTAssertFalse(store.hasFiredComparisonChartShownPixel)

        // WHEN
        sut.trackBrowserComparisonImpression()

        // THEN
        XCTAssertTrue(store.hasFiredComparisonChartShownPixel)
    }

    func testWhenTrackChooseBrowserCTAActionThenOnboardingIntroChooseBrowserCTAPressedEventFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroChooseBrowserCTAPressed
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackChooseBrowserCTAAction()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_preonboarding_choose_browser_pressed")
        XCTAssertEqual(OnboardingPixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

}
