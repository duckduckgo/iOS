//
//  BrowserComparisonModelTests.swift
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
@testable import DuckDuckGo

final class BrowserComparisonModelTests: XCTestCase {
    private var onboardingManager: OnboardingManagerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        onboardingManager = OnboardingManagerMock()
    }

    override func tearDownWithError() throws {
        onboardingManager = nil
        try super.tearDownWithError()
    }

    func testWhenIsNotHighlightsThenBrowserComparisonFeaturePrivateSearchIsCorrect() throws {
        // GIVEN
        try [false, true].forEach { isOnboardingHighlightsEnabled in
            onboardingManager.isOnboardingHighlightsEnabled = isOnboardingHighlightsEnabled
            BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

            // WHEN
            let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .privateSearch })?.type.title)

            // THEN
            XCTAssertEqual(result, UserText.DaxOnboardingExperiment.BrowsersComparison.Features.privateSearch)
        }
    }

    func testWhenIsNotHighlightsThenBrowserComparisonFeatureBlockThirdPartyTrackersIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = false
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockThirdPartyTrackers })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.DaxOnboardingExperiment.BrowsersComparison.Features.trackerBlockers)
    }

    func testWhenIsHighlightsThenBrowserComparisonFeatureBlockThirdPartyTrackersIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockThirdPartyTrackers })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.trackerBlockers)
    }

    func testWhenIsNotHighlightsThenBrowserComparisonFeatureBlockCookiePopupsIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = false
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockCookiePopups })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.DaxOnboardingExperiment.BrowsersComparison.Features.cookiePopups)
    }

    func testWhenIsHighlightsThenBrowserComparisonFeatureBlockCookiePopupsIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockCookiePopups })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.cookiePopups)
    }

    func testWhenIsNotHighlightsThenBrowserComparisonFeatureBlockCreepyAdsIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = false
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockCreepyAds })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.DaxOnboardingExperiment.BrowsersComparison.Features.creepyAds)
    }

    func testWhenIsHighlightsThenBrowserComparisonFeatureBlockCreepyAdsIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .blockCreepyAds })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.creepyAds)
    }

    func testWhenIsNotHighlightsThenBrowserComparisonFeatureEraseBrowsingDataIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = false
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .eraseBrowsingData })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.DaxOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData)
    }

    func testWhenIsHighlightsThenBrowserComparisonFeatureEraseBrowsingDataIsCorrect() throws {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        BrowsersComparisonModel.PrivacyFeature.FeatureType.onboardingManager = onboardingManager

        // WHEN
        let result = try XCTUnwrap(BrowsersComparisonModel.privacyFeatures.first(where: { $0.type == .eraseBrowsingData })?.type.title)

        // THEN
        XCTAssertEqual(result, UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData)
    }

}
