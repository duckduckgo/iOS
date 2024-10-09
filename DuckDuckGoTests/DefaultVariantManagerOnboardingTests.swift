//
//  DefaultVariantManagerOnboardingTests.swift
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
import BrowserServicesKit
@testable import Core
@testable import DuckDuckGo

final class DefaultVariantManagerOnboardingTests: XCTestCase {

    // MARK: - Is New Intro Flow

    func testWhenIsNewIntroFlow_AndFeatureIsNewOnboardingIntro_ThenReturnTrue() {
        // GIVEN
        let sut = makeVariantManager(features: [.newOnboardingIntro])

        // WHEN
        let result = sut.isNewIntroFlow

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsNewIntroFlow_AndFeaturesContainNewOnboardingIntroHighlights_ThenReturnTrue() {
        // GIVEN
        let sut = makeVariantManager(features: [.newOnboardingIntroHighlights])

        // WHEN
        let result = sut.isNewIntroFlow

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsNewIntroFlow_AndFeaturesDoNotContainNewOnboardingIntroOrNewOnboardingIntroHighlights_ThenReturnFalse() {
        // GIVEN
        let sut = makeVariantManager(features: [.contextualDaxDialogs])

        // WHEN
        let result = sut.isNewIntroFlow

        // THEN
        XCTAssertFalse(result)
    }

    // MARK: - Is Onboarding Highlights

    func testWhenIsOnboardingHighlights_AndFeaturesContainOnboardingHighlights_ThenReturnTrue() {
        // GIVEN
        let sut = makeVariantManager(features: [.newOnboardingIntroHighlights])

        // WHEN
        let result = sut.isOnboardingHighlightsExperiment

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsOnboardingHighlights_AndFeaturesDoNotContainOnboardingHighlights_ThenReturnFalse() {
        // GIVEN
        let sut = makeVariantManager(features: [.newOnboardingIntro, .contextualDaxDialogs])

        // WHEN
        let result = sut.isOnboardingHighlightsExperiment

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsOnboardingHighlights_AndFeaturesIsEmpty_ThenReturnFalse() {
        // GIVEN
        let sut = makeVariantManager(features: [])

        // WHEN
        let result = sut.isOnboardingHighlightsExperiment

        // THEN
        XCTAssertFalse(result)
    }

    // MARK: - Is Contextual Dax Dialogs Enabled

    func testWhenIsContextualDaxDialogsEnabled_AndFeaturesContainContextualDaxDialogs_ThenReturnTrue() {
        // GIVEN
        let sut = makeVariantManager(features: [.contextualDaxDialogs])

        // WHEN
        let result = sut.isContextualDaxDialogsEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsContextualDaxDialogsEnabled_AndFeaturesDoNotContainContextualDaxDialogs_ThenReturnFalse() {
        // GIVEN
        let sut = makeVariantManager(features: [.newOnboardingIntro, .newOnboardingIntroHighlights])

        // WHEN
        let result = sut.isContextualDaxDialogsEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsContextualDaxDialogsEnabled_AndFeaturesIsEmpty_ThenReturnFalse() {
        // GIVEN
        let sut = makeVariantManager(features: [])

        // WHEN
        let result = sut.isContextualDaxDialogsEnabled

        // THEN
        XCTAssertFalse(result)
    }

}

// MARK: Helpers

private extension DefaultVariantManagerOnboardingTests {

    func makeVariantManager(features: [FeatureName]) -> DefaultVariantManager {
        let mockStatisticStore = MockStatisticsStore()
        mockStatisticStore.variant = #function
        let variantManager = DefaultVariantManager(
            variants: [VariantIOS(name: #function, weight: 1, isIncluded: VariantIOS.When.always, features: features)],
            storage: mockStatisticStore,
            rng: MockVariantRNG(returnValue: 500),
            returningUserMeasurement: MockReturningUserMeasurement(),
            variantNameOverride: MockVariantNameOverride()
        )
        variantManager.assignVariantIfNeeded { _ in }
        return variantManager
    }

}
