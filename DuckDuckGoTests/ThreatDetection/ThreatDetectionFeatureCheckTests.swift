//
//  ThreatDetectionFeatureCheckTests.swift
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

import Testing
import BrowserServicesKit
@testable import DuckDuckGo

@Suite("Threat Detection - Feature Flags", .serialized)
final class ThreatDetectionFeatureCheckTests {
    private var sut: ThreatDetectionFeatureCheck!
    private var featureFlaggerMock: MockFeatureFlagger!
    private var configurationManagerMock: PrivacyConfigurationManagerMock!

    init() async throws {
        featureFlaggerMock = MockFeatureFlagger()
        configurationManagerMock = PrivacyConfigurationManagerMock()
        sut = ThreatDetectionFeatureCheck(featureFlagger: featureFlaggerMock, privacyConfigManager: configurationManagerMock)
    }

    deinit {
        featureFlaggerMock = nil
        configurationManagerMock = nil
        sut = nil
    }

    // MARK: - Web Error Page

    @Test("Check Threat Detection Enabled")
    func whenThreatDetectionEnabled_AndFeatureFlagIsOn_ThenReturnTrue() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]

        // WHEN
        let result = sut.isThreatDetectionEnabled

        // THEN
        #expect(result)
    }

    @Test("Check Threat Detection Disabled")
    func whenThreatDetectionEnabled_AndFeatureFlagIsOff_ThenReturnFalse() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isThreatDetectionEnabled

        // THEN
        #expect(!result)
    }

    @Test("Check Threat Detection Enabled For Domain")
    func whenThreatDetectionEnabledForDomain_AndFeatureIsAvailableForDomain_ThenReturnTrue() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.phishingDetection: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatDetectionEnabled(forDomain: domain)

        // THEN
        #expect(result)
    }

    @Test("Check Threat Detection Disabled For Domain When Domain Is Not Available")
    func whenThreatDetectionCalledEnabledForDomain_AndFeatureIsNotAvailableForDomain_ThenReturnFalse() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.phishingDetection: []]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatDetectionEnabled(forDomain: domain)

        // THEN
        #expect(!result)
    }

    @Test("Check Threat Detection Disabled For Domain When Error Page Feature Flag Is Off")
    func whenThreatDetectionEnabledForDomain_AndPrivacyConfigFeatureFlagIsOn_AndThreatDetectionSubFeatureIsOff_ThenReturnTrue() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.phishingDetection: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatDetectionEnabled(forDomain: domain)

        // THEN
        #expect(!result)
    }

    @Test("Check Threat Detection Disabled For Domain When Master Feature Flag Is Off")
    func whenThreatDetectionEnabledForDomain_AndPrivacyConfigFeatureFlagIsOff_ThenReturnFalse() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.adClickAttribution: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatDetectionEnabled(forDomain: domain)

        // THEN
        #expect(!result)
    }

    // MARK: - Settings

    @Test("Check Threat Detection Settings Enabled")
    func whenIsThreatDetectionSettingsEnabled_AndThreatDetectionPreferencesIsOn_ThenReturnTrue() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionPreferences]

        // WHEN
        let result = sut.isThreatDetectionSettingsEnabled

        // THEN
        #expect(result)
    }

    @Test("Check Threat Detection Settings Disabled")
    func whenIsThreatDetectionSettingsEnabled_AndThreatDetectionPreferencesIsOff_ThenReturnFalse() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isThreatDetectionSettingsEnabled

        // THEN
        #expect(!result)
    }
}
