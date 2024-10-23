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

    // MARK: - Onboarding Highlights

    func testWhenIsOnboardingHighlightsLocalFlagEnabledCalledAndAppDefaultsOnboardingHiglightsEnabledIsTrueThenReturnTrue() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = true

        // WHEN
        let result = sut.isOnboardingHighlightsLocalFlagEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsOnboardingHighlightsLocalFlagEnabledCalledAndAppDefaultsOnboardingHiglightsEnabledIsFalseThenReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingHighlightsEnabled = false

        // WHEN
        let result = sut.isOnboardingHighlightsLocalFlagEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsOnboardingHighlightsFeatureFlagEnabledCalledAndFeaturFlaggerFeatureIsOnThenReturnTrue() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingHighlights]

        // WHEN
        let result = sut.isOnboardingHighlightsFeatureFlagEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsOnboardingHighlightsFeatureFlagEnabledCalledAndFeaturFlaggerFeatureIsOffThenReturnFalse() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isOnboardingHighlightsFeatureFlagEnabled

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

    // MARK: - Add to Dock

    func testWhenIsAddToDockLocalFlagEnabledCalledAndAppDefaultsOnboardingAddToDockEnabledIsTrueThenReturnTrue() {
        // GIVEN
        appSettingsMock.onboardingAddToDockEnabled = true

        // WHEN
        let result = sut.isAddToDockLocalFlagEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsAddToDockLocalFlagEnabledCalledAndAppDefaultsOnboardingAddToDockEnabledIsFalseThenReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingAddToDockEnabled = false

        // WHEN
        let result = sut.isAddToDockLocalFlagEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsAddToDockFeatureFlagEnabledCalledAndFeaturFlaggerFeatureIsOnThenReturnTrue() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [FeatureFlag.onboardingAddToDock]

        // WHEN
        let result = sut.isAddToDockFeatureFlagEnabled

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsAddToDockFeatureFlagEnabledCalledAndFeaturFlaggerFeatureIsOffThenReturnFalse() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isAddToDockFeatureFlagEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsAddToDockEnabledCalledAndLocalFlagEnabledIsFalseAndFeatureFlagIsFalseThenReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingAddToDockEnabled = false
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isAddToDockEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsAddToDockEnabledCalledAndLocalFlagEnabledIsTrueAndFeatureFlagIsFalseThenReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingAddToDockEnabled = true
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isAddToDockEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsAddToDockEnabledCalledAndLocalFlagEnabledIsFalseAndFeatureFlagEnabledIsTrueThenReturnFalse() {
        // GIVEN
        appSettingsMock.onboardingAddToDockEnabled = false
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]

        // WHEN
        let result = sut.isAddToDockEnabled

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsAddToDockEnabledAndLocalFlagEnabledIsTrueAndFeatureFlagEnabledIsTrueThenReturnTrue() {
        // GIVEN
        appSettingsMock.onboardingAddToDockEnabled = true
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]

        // WHEN
        let result = sut.isAddToDockEnabled

        // THEN
        XCTAssertTrue(result)
    }

}
