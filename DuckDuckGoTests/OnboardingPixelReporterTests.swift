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

    override func setUpWithError() throws {
        sut = OnboardingPixelReporter(pixel: OnboardingPixelFireMock.self, uniquePixel: OnboardingUniquePixelFireMock.self)
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        OnboardingPixelFireMock.tearDown()
        OnboardingUniquePixelFireMock.tearDown()
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenTrackOnboardingIntroImpressionThenOnboardingIntroShownEventFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroShownUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackOnboardingIntroImpression()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_preonboarding_intro_shown_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackBrowserComparisonImpressionThenOnboardingIntroComparisonChartShownEventFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroComparisonChartShownUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackBrowserComparisonImpression()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_preonboarding_comparison_chart_shown_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
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

    // MARK: - List

    func testWhenTrackSearchSuggestionSayDuckThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSearchSayDuckUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSearchSuggestionSayDuck()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_search_say_duck_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }
    
    func testWhenTrackSearchSuggestionMightyDuckThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSearchMightyDuckUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSearchSuggestionMightyDuck()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_search_mighty_duck_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSearchSuggestionWeatherThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSearchWeatherUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSearchSuggestionWeather()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_search_weather_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSearchSuggestionSurpriseMeThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSearchSurpriseMeUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSearchSuggestionSurpriseMe()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_search_surprise_me_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSiteSuggestionESPNThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSiteESPNUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSiteSuggestionESPN()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_visit_site_espn_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSiteSuggestionYahooThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSiteYahooUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSiteSuggestionYahoo()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_visit_site_yahoo_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSiteSuggestionEbayThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSiteEbayUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSiteSuggestionEbay()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_visit_site_ebay_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSiteSuggestionSurpriseMeThenExpectedEventIsCalled() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSiteSurpriseMeUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSiteSuggestionSurpriseMe()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_visit_site_surprise_me_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }
}
