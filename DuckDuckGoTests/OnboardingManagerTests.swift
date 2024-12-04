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
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock, isIphone: true)
    }

    override func tearDownWithError() throws {
        appSettingsMock = nil
        featureFlaggerMock = nil
        variantManagerMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Add to Dock

    func testWhenAddToDockLocalFlagStateCalledAndAppDefaultsOnboardingAddToDockStateIsIntroThenReturnIntro() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .intro

        // WHEN
        let result = sut.addToDockLocalFlagState

        // THEN
        XCTAssertEqual(result, .intro)
    }

    func testWhenAddToDockLocalFlagStateCalledAndAppDefaultsOnboardingAddToDockStateIsContextualThenReturnContextual() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .contextual

        // WHEN
        let result = sut.addToDockLocalFlagState

        // THEN
        XCTAssertEqual(result, .contextual)
    }

    func testWhenAddToDockLocalFlagStateCalledAndAppDefaultsOnboardingAddToDockStateIsDisabledThenReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .disabled

        // WHEN
        let result = sut.addToDockLocalFlagState

        // THEN
        XCTAssertEqual(result, .disabled)
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

    func testWhenAddToDockStateCalledAndVariantManagerSupportsAddToDockIntroThenReturnIntro() {
        // GIVEN
        variantManagerMock.isSupportedBlock = { feature in
            feature == .addToDockIntro
        }
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock, isIphone: true)


        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .intro)
    }

    func testWhenAddToDockStateCalledAndVariantManagerSupportsAddToDockContextualThenReturnContextual() {
        // GIVEN
        variantManagerMock.isSupportedBlock = { feature in
            feature == .addToDockContextual
        }
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock, isIphone: true)

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .contextual)
    }

    func testWhenAddToDockStateCalledAndVariantManagerDoesNotSupportAddToDockThenReturnDisabled() {
        // GIVEN
        variantManagerMock.isSupportedBlock = { _ in
            false
        }

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

    func testWhenAddToDockStateCalledAndLocalFlagStateIsDisabledAndFeatureFlagIsFalseThenReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .disabled
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

    func testWhenAddToDockStateCalledAndLocalFlagStateIsIntroAndFeatureFlagIsFalseThenReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .intro
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

    func testWhenAddToDockStateCalledAndLocalFlagStateIsContextualAndFeatureFlagIsFalseThenReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .contextual
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

    func testWhenAddToDockStateCalledAndLocalFlagStateIsDisabledAndFeatureFlagEnabledIsTrueThenReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .disabled
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

    func testWhenAddToDockStateAndLocalFlagStateIsIntroAndFeatureFlagEnabledIsTrueThenReturnIntro() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .intro
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .intro)
    }

    func testWhenAddToDockStateAndLocalFlagStateIsContextualAndFeatureFlagEnabledIsTrueThenReturnContextual() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .contextual
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .contextual)
    }

    func testWhenAddToDockStateAndLocalFlagStateIsIntroAndFeatureFlagsIsEnabledAndDeviceIsIpadReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .intro
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock, isIphone: false)

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

    func testWhenAddToDockStateAndLocalFlagStateIsContextualAndFeatureFlagsIsEnabledAndDeviceIsIpadReturnDisabled() {
        // GIVEN
        appSettingsMock.onboardingAddToDockState = .contextual
        featureFlaggerMock.enabledFeatureFlags = [.onboardingAddToDock]
        sut = OnboardingManager(appDefaults: appSettingsMock, featureFlagger: featureFlaggerMock, variantManager: variantManagerMock, isIphone: false)

        // WHEN
        let result = sut.addToDockEnabledState

        // THEN
        XCTAssertEqual(result, .disabled)
    }

}
