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
    private static let suiteName = "testing_onboarding_pixel_store"
    private var sut: OnboardingPixelReporter!
    private var statisticsStoreMock: MockStatisticsStore!
    private var now: Date!
    private var userDefaultsMock: UserDefaults!

    override func setUpWithError() throws {
        statisticsStoreMock = MockStatisticsStore()
        statisticsStoreMock.atb = "TESTATB"
        now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        userDefaultsMock = UserDefaults(suiteName: Self.suiteName)
        sut = OnboardingPixelReporter(pixel: OnboardingPixelFireMock.self, uniquePixel: OnboardingUniquePixelFireMock.self, statisticsStore: statisticsStoreMock, calendar: calendar, dateProvider: { self.now }, userDefaults: userDefaultsMock)
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        OnboardingPixelFireMock.tearDown()
        OnboardingUniquePixelFireMock.tearDown()
        statisticsStoreMock = nil
        now = nil
        userDefaultsMock.removePersistentDomain(forName: Self.suiteName)
        userDefaultsMock = nil
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

    // MARK: - Custom Interactions

    func testWhenTrackCustomSearchIsCalledThenSearchCustomFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSearchCustomUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackCustomSearch()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_search_custom_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackCustomSiteIsCalledThenSiteCustomFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingContextualSiteCustomUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackCustomSite()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_onboarding_visit_site_custom_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackSecondVisitIsCalledAndStoreDoesNotContainPixelThenPixelIsNotFired() {
        // GIVEN
        XCTAssertNil(userDefaultsMock.value(forKey: "com.duckduckgo.ios.site-visited"))
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSecondSiteVisit()

        // THEN
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])
    }

    func testWhenTrackSecondVisitIsCalledThenFiresOnlyOnSecondTime() {
        // GIVEN
        let key = "com.duckduckgo.ios.site-visited"
        userDefaultsMock.set(true, forKey: key)
        XCTAssertTrue(userDefaultsMock.bool(forKey: key))
        let expectedPixel = Pixel.Event.onboardingContextualSecondSiteVisitUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackSecondSiteVisit()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_second_sitevisit_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackPrivacyDashboardOpenedForFirstTimeThenPrivacyDashboardFirstTimeOpenedPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.privacyDashboardFirstTimeOpenedUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackPrivacyDashboardOpenedForFirstTime()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, "m_privacy_dashboard_first_time_used_unique")
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion])
    }

    func testWhenTrackPrivacyDashboardOpenedForFirstTimeThenFromOnboardingParameterIsSetToTrue() {
        // GIVEN
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])

        // WHEN
        sut.trackPrivacyDashboardOpenedForFirstTime()

        // THEN
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams["from_onboarding"], "true")
    }

    func testWhenTrackPrivacyDashboardOpenedForFirstTimeThenDaysSinceInstallParameterIsSet() {
        // GIVEN
        let installDate = Date(timeIntervalSince1970: 1722348000) // 30th July 2024 GMT
        now = Date(timeIntervalSince1970: 1722607200) // 1st August 2024 GMT
        statisticsStoreMock.installDate = installDate
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])

        // WHEN
        sut.trackPrivacyDashboardOpenedForFirstTime()

        // THEN
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams["daysSinceInstall"], "3")
    }

    // MARK: - Dax Dialogs

    func testWhenTrackScreenImpressionIsCalledThenPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.daxDialogsSerpUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackScreenImpression(event: expectedPixel)

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhentrackEndOfJourneyDialogCTAActionIsCalledThenDaxDialogsEndOfJourneyDismissedPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.daxDialogsEndOfJourneyDismissed
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackEndOfJourneyDialogCTAAction()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    // Enqueuing / Dequeuing Pixels

    func testWhenPixelIsFiredAndAndATBIsNotAvailableAndPixelNeedsATBThenEnqueuePixel() throws {
        // GIVEN
        statisticsStoreMock.atb = nil
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])
        XCTAssertTrue(sut.enqueuedPixels.isEmpty)

        // WHEN
        sut.trackOnboardingIntroImpression()

        // THEN
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])
        XCTAssertEqual(sut.enqueuedPixels.count, 1)
        let enqueuedPixel = try XCTUnwrap(sut.enqueuedPixels.first)
        XCTAssertEqual(enqueuedPixel.event, .onboardingIntroShownUnique)
        XCTAssertTrue(enqueuedPixel.unique)
        XCTAssertTrue(enqueuedPixel.additionalParameters.isEmpty)
        XCTAssertEqual(enqueuedPixel.includedParameters, [.appVersion, .atb])

    }

    func testWhenPixelIsFiredAndAndATBIsNotAvailableAndPixelDoesNotNeedATBThenFirePixel() {
        // GIVEN
        statisticsStoreMock.atb = nil
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedParams, [:])
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])
        XCTAssertTrue(sut.enqueuedPixels.isEmpty)

        // WHEN
        sut.trackPrivacyDashboardOpenedForFirstTime()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, .privacyDashboardFirstTimeOpenedUnique)
        XCTAssertNotNil(OnboardingUniquePixelFireMock.capturedParams)
        XCTAssertNotNil(OnboardingUniquePixelFireMock.capturedIncludeParameters)
        XCTAssertTrue(sut.enqueuedPixels.isEmpty)
    }

    func testWhenFireEnqueuedPixelIsCalledThenFireEnqueuedPixels() {
        // GIVEN
        statisticsStoreMock.atb = nil
        sut.trackOnboardingIntroImpression()
        sut.trackBrowserComparisonImpression()
        XCTAssertEqual(sut.enqueuedPixels.count, 2)
        XCTAssertTrue(OnboardingUniquePixelFireMock.capturedPixelEventHistory.isEmpty)

        // WHEN
        sut.fireEnqueuedPixelsIfNeeded()

        // THEN
        XCTAssertEqual(sut.enqueuedPixels.count, 0)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEventHistory.count, 2)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEventHistory[0], .onboardingIntroShownUnique)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEventHistory[1], .onboardingIntroComparisonChartShownUnique)
    }

    // MARK: - Onboarding Intro Highglights Experiment

    func testWhenTrackChooseAppIconImpressionIsCalledThenOnboardingIntroChooseIconImpressionUniquePixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroChooseAppIconImpressionUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackChooseAppIconImpression()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion])
    }

    func testWhenTrackChooseNonDefaultAppIconIsCalledThenOnboardingIntroChooseCustomIconColorPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroChooseCustomAppIconColorCTAPressed
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackChooseCustomAppIconColor()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion])
    }

    func testWhenTrackAddressBarPositionSelectionImpressionIsCalledThenOnboardingIntroChooseAddressBarImpressionUniquePixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroChooseAddressBarImpressionUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackAddressBarPositionSelectionImpression()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion])
    }

    func testWhenTrackChooseBottomAddressBarPositionIsCalledThenOnboardingIntroBottomAddressBarSelectedFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingIntroBottomAddressBarSelected
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackChooseBottomAddressBarPosition()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion])
    }

    // MARK: Add To Dock Experiment

    func testWhenTrackAddToDockPromoImpressionsIsCalledThenOnboardingAddToDockPromoImpressionsPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingAddToDockPromoImpressionsUnique
        XCTAssertFalse(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertNil(OnboardingUniquePixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackAddToDockPromoImpression()

        // THEN
        XCTAssertTrue(OnboardingUniquePixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingUniquePixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackAddToDockPromoShowTutorialCTAActionIsCalledThenOnboardingAddToDockPromoShowTutorialCTAPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingAddToDockPromoShowTutorialCTATapped
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackAddToDockPromoShowTutorialCTAAction()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackAddToDockPromoDismissCTAActionThenOnboardingAddToDockPromoDismissCTAPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingAddToDockPromoDismissCTATapped
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackAddToDockPromoDismissCTAAction()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

    func testWhenTrackAddToDockTutorialDismissCTAActionIsCalledThenonboardingAddToDockTutorialDismissCTAPixelFires() {
        // GIVEN
        let expectedPixel = Pixel.Event.onboardingAddToDockTutorialDismissCTATapped
        XCTAssertFalse(OnboardingPixelFireMock.didCallFire)
        XCTAssertNil(OnboardingPixelFireMock.capturedPixelEvent)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [])

        // WHEN
        sut.trackAddToDockTutorialDismissCTAAction()

        // THEN
        XCTAssertTrue(OnboardingPixelFireMock.didCallFire)
        XCTAssertEqual(OnboardingPixelFireMock.capturedPixelEvent, expectedPixel)
        XCTAssertEqual(expectedPixel.name, expectedPixel.name)
        XCTAssertEqual(OnboardingPixelFireMock.capturedIncludeParameters, [.appVersion, .atb])
    }

}
