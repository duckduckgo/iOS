//
//  OnboardingManagerTests.swift
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

final class OnboardingManagerTests: XCTestCase {
    private var sut: OnboardingManager!
    private var appSettingsMock: AppSettingsMock!
    private var featureFlaggerMock: MockFeatureFlagger!
    private var variantManagerMock: MockVariantManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        appSettingsMock = AppSettingsMock()
        featureFlaggerMock = MockFeatureFlagger()
        variantManagerMock = MockVariantManager()
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock)
    }

    override func tearDownWithError() throws {
        appSettingsMock = nil
        featureFlaggerMock = nil
        variantManagerMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenIsLocalFlagEnabledIsCalledAndAppDefaultsOnboardingHiglightsEnabledIsTrueThenReturnTrue() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = true

        // WHEN
        let result = sut.isLocalFlagEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsLocalFlagEnabledIsCalledAndAppDefaultsOnboardingHiglightsEnabledIsFalseThenReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = false

        // WHEN
        let result = sut.isLocalFlagEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsFeatureFlagEnabledIsCalledAndFeaturFlaggerFeatureIsOnThenReturnTrue() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingHighlights]

        // WHEN
        let result = sut.isFeatureFlagEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsFeatureFlagEnabledIsCalledAndFeaturFlaggerFeatureIsOffThenReturnFalse() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isFeatureFlagEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsOnboardingHiglightsEnabledAndIsLocalFlagEnabledIsFalseReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = false
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingHighlights]

        // WHEN
        let result = sut.isOnboardingHighlightsEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsOnboardingHiglightsEnabledAndIsFeatureFlagEnabledIsFalseReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = true
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isOnboardingHighlightsEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsOnboardingHiglightsEnabledAndIsLocalFlagEnabledIsTrueAndIsFeatureFlagEnabledIsTrueThenReturnTrue() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = true
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingHighlights]

        // WHEN
        let result = sut.isOnboardingHighlightsEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsOnboardingHiglightsEnabledAndVariantManagerSupportOnboardingHighlightsReturnTrue() {
        // GIVEN
        variantManagerMock.isSupportedBlock = { _ in true }
        appSettingsMock.onboardingHighlightsEnabled = false
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingHighlights]
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock)

        // WHEN
        let result = sut.isOnboardingHighlightsEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsOnboardingHiglightsEnabledAndVariantManagerSupportOnboardingHighlightsReturnFalse() {
        // GIVEN
        variantManagerMock.isSupportedBlock = { _ in false }
        appSettingsMock.onboardingHighlightsEnabled = false
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingHighlights]
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock)

        // WHEN
        let result = sut.isOnboardingHighlightsEnabled

        // THEN
        XCTAssertFalse(result)
    }
}
