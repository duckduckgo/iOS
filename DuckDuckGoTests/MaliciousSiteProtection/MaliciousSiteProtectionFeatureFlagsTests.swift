//
//  MaliciousSiteProtectionFeatureFlagsTests.swift
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

@Suite("Malicious Site Protection - Feature Flags", .serialized)
final class MaliciousSiteProtectionFeatureFlagsTests {
    private var sut: MaliciousSiteProtectionFeatureFlags!
    private var featureFlaggerMock: MockFeatureFlagger!
    private var configurationManagerMock: PrivacyConfigurationManagerMock!

    init() async throws {
        featureFlaggerMock = MockFeatureFlagger()
        configurationManagerMock = PrivacyConfigurationManagerMock()
        sut = MaliciousSiteProtectionFeatureFlags(featureFlagger: featureFlaggerMock, privacyConfigManager: configurationManagerMock)
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
        featureFlaggerMock.enabledFeatureFlags = [.maliciousSiteProtection]

        // WHEN
        let result = sut.isMaliciousSiteProtectionEnabled

        // THEN
        #expect(result)
    }

    @Test("Check Threat Detection Disabled")
    func whenThreatDetectionEnabled_AndFeatureFlagIsOff_ThenReturnFalse() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isMaliciousSiteProtectionEnabled

        // THEN
        #expect(!result)
    }

    @Test("Check Threat Detection Enabled For Domain")
    func whenThreatDetectionEnabledForDomain_AndFeatureIsAvailableForDomain_ThenReturnTrue() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.maliciousSiteProtection]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.maliciousSiteProtection: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.shouldDetectMaliciousThreat(forDomain: domain)

        // THEN
        #expect(result)
    }

    @Test("Check Threat Detection Disabled For Domain When Protection For Domain Is Not Enabled")
    func whenThreatDetectionCalledEnabledForDomain_AndFeatureIsNotAvailableForDomain_ThenReturnFalse() throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.maliciousSiteProtection]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.maliciousSiteProtection: []]
        let domain = "example.com"

        // WHEN
        let result = sut.shouldDetectMaliciousThreat(forDomain: domain)

        // THEN
        #expect(!result)
    }

    @Test("Check Threat Detection Disabled For Domain When Feature Flag Is Off")
    func whenThreatDetectionEnabledForDomain_AndPrivacyConfigFeatureFlagIsOn_AndThreatDetectionSubFeatureIsOff_ThenReturnTrue() throws {
        // GIVEN
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.adClickAttribution: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.shouldDetectMaliciousThreat(forDomain: domain)

        // THEN
        #expect(!result)
    }

    @Test("Feature Settings Return Remote Values")
    func whenSettingIsDefinedReturnValue() throws {
        // GIVEN
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.settings[.maliciousSiteProtection] = [
            MaliciousSiteProtectionFeatureSettings.hashPrefixUpdateFrequency.rawValue: 10,
            MaliciousSiteProtectionFeatureSettings.filterSetUpdateFrequency.rawValue: 50
        ]
        sut = MaliciousSiteProtectionFeatureFlags(featureFlagger: featureFlaggerMock, privacyConfigManager: configurationManagerMock)

        // WHEN
        let hashPrefixUpdateFrequency = sut.hashPrefixUpdateFrequency
        let filterSetUpdateFrequency = sut.filterSetUpdateFrequency

        // THEN
        #expect(hashPrefixUpdateFrequency == 10)
        #expect(filterSetUpdateFrequency == 50)
    }

    @Test("Feature Settings Return Default Values")
    func whenSettingIsNotDefinedReturnDefaultValue() throws {
        // GIVEN
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.settings[.maliciousSiteProtection] = [:]
        sut = MaliciousSiteProtectionFeatureFlags(featureFlagger: featureFlaggerMock, privacyConfigManager: configurationManagerMock)

        // WHEN
        let hashPrefixUpdateFrequency = sut.hashPrefixUpdateFrequency
        let filterSetUpdateFrequency = sut.filterSetUpdateFrequency

        // THEN
        #expect(hashPrefixUpdateFrequency == 20)
        #expect(filterSetUpdateFrequency == 720)
    }

}
