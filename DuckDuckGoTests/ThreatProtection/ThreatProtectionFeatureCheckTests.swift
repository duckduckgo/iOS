//
//  ThreatProtectionFeatureCheckTests.swift
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

@Suite("Threat Protection - Feature Flags")
final class ThreatProtectionFeatureCheckTests {
    private var sut: ThreatProtectionFeatureCheck!
    private var featureFlaggerMock: MockFeatureFlagger!
    private var configurationManagerMock: PrivacyConfigurationManagerMock!

    init() async throws {
        featureFlaggerMock = MockFeatureFlagger()
        configurationManagerMock = PrivacyConfigurationManagerMock()
        sut = ThreatProtectionFeatureCheck(featureFlagger: featureFlaggerMock, privacyConfigManager: configurationManagerMock)
    }

    deinit {
        featureFlaggerMock = nil
        configurationManagerMock = nil
        sut = nil
    }

    // MARK: - Web Error Page

    @Test("Check isThreatProtectionEnabled returns true when feature flag is enabled")
    func whenIsThreatProtectionCalledAndFeatureFlagIsOnThenReturnTrue() async throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]

        // WHEN
        let result = sut.isThreatProtectionEnabled

        // THEN
        #expect(result)
    }

    @Test("Check isThreatProtectionEnabled returns false when feature flag is disabled")
    func whenIsThreatProtectionCalledAndFeatureFlagIsOffThenReturnFalse() async throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isThreatProtectionEnabled

        // THEN
        #expect(!result)
    }

    @Test("Check isThreatProtectionEnabledForDomain returns true when feature flag is enabled and privacy config feature flag is enabled for domain")
    func whenIsThreatProtectionCalledForDomainAndPrivacyConfigFeatureFlagIsOnThenReturnTrue() async throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.phishingDetection: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatProtectionEnabled(forDomain: domain)

        // THEN
        #expect(result)
    }

    @Test("Check isThreatProtectionEnabledForDomain returns false when feature flag is enabled and privacy config feature flag is disabled for domain")
    func whenIsThreatProtectionCalledForDomainAndDomainFeatureIsNotAvailableForDomainThenReturnFalse() async throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.phishingDetection: []]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatProtectionEnabled(forDomain: domain)

        // THEN
        #expect(!result)
    }

    @Test("Check isThreatProtectionEnabledForDomain returns false when feature flag is disabled and privacy config feature flag is enabled for domain")
    func whenIsThreatProtectionCalledForDomainAndPrivacyConfigFeatureFlagIsOnAndThreatDetectionSubFeatureIsOffThenReturnTrue() async throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.phishingDetection: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatProtectionEnabled(forDomain: domain)

        // THEN
        #expect(!result)
    }

    @Test("Check isThreatProtectionEnabledForDomain returns false when feature flag is enabled and privacy config feature flag is disabled")
    func whenIsThreatProtectionCalledForDomainAndPrivacyConfigFeatureFlagIsOffThenReturnFalse() async throws {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionErrorPage]
        let privacyConfigMock = try #require(configurationManagerMock.privacyConfig as? PrivacyConfigurationMock)
        privacyConfigMock.enabledFeatures = [.adClickAttribution: ["example.com"]]
        let domain = "example.com"

        // WHEN
        let result = sut.isThreatProtectionEnabled(forDomain: domain)

        // THEN
        #expect(!result)
    }

    // MARK: - Settings

    @Test("Check isThreatProtectionSettingsEnabled returns true when feature flag is enabled")
    func checkThreatProtectionSettingsIsEnabled() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = [.threatDetectionPreferences]

        // WHEN
        let result = sut.isThreatProtectionSettingsEnabled

        // THEN
        #expect(result)
    }

    @Test("Check isThreatProtectionSettingsEnabled returns false when feature flag is disabled")
    func checkThreatProtectionSettingsIsDisabled() {
        // GIVEN
        featureFlaggerMock.enabledFeatureFlags = []

        // WHEN
        let result = sut.isThreatProtectionSettingsEnabled

        // THEN
        #expect(!result)
    }

}
