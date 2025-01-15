//
//  AppConfigurationURLProviderTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

final class AppConfigurationURLProviderTests: XCTestCase {
    private var mockPrivacyConfigurationManager: MockPrivacyConfigurationManager!
    private var mockFeatureFlagger: MockFeatureFlaggerMockSettings!
    private var urlProvider: AppConfigurationURLProvider!
    let controlURL = "control/url.json"
    let treatmentURL = "treatment/url.json"

    override func setUp() {
        super.setUp()
        mockPrivacyConfigurationManager = MockPrivacyConfigurationManager()
        mockFeatureFlagger = MockFeatureFlaggerMockSettings()
        urlProvider = AppConfigurationURLProvider(privacyConfigurationManager: mockPrivacyConfigurationManager, featureFlagger: mockFeatureFlagger)
    }

    override func tearDown() {
        urlProvider = nil
        mockPrivacyConfigurationManager = nil
        mockFeatureFlagger = nil
        super.tearDown()
    }

    func testTrackerDataURL_forControlCohort_returnsControlUrl() {
        // GIVEN
        mockFeatureFlagger.mockCohorts = [
            TdsExperimentType(rawValue: 0)!.subfeature.rawValue: TdsNextExperimentFlag.Cohort.control]
        let privacyConfig = MockPrivacyConfiguration()
        privacyConfig.subfeatureSettings = "{ \"controlUrl\": \"\(controlURL)\", \"treatmentUrl\": \"\(treatmentURL)\"}"
        mockPrivacyConfigurationManager.privacyConfig = privacyConfig

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url.absoluteString, URL.staticBase + "/trackerblocking/" + controlURL)
    }

    func testTrackerDataURL_forTreatmentCohort_returnsTreatmentUrl() {
        // GIVEN
        mockFeatureFlagger.mockCohorts = [
            TdsExperimentType(rawValue: 0)!.subfeature.rawValue: TdsNextExperimentFlag.Cohort.treatment]
        let privacyConfig = MockPrivacyConfiguration()
        privacyConfig.subfeatureSettings = "{ \"controlUrl\": \"\(controlURL)\", \"treatmentUrl\": \"\(treatmentURL)\"}"
        mockPrivacyConfigurationManager.privacyConfig = privacyConfig

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url.absoluteString, URL.staticBase + "/trackerblocking/" + treatmentURL)
    }

    func testTrackerDataURL_ifNoSettings_returnsDefaultURL() {
        // GIVEN
        mockFeatureFlagger.mockCohorts = [
            TdsExperimentType(rawValue: 0)!.subfeature.rawValue: TdsNextExperimentFlag.Cohort.treatment]
        let privacyConfig = MockPrivacyConfiguration()
        mockPrivacyConfigurationManager.privacyConfig = privacyConfig

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url, URL.trackerDataSet)
    }

    func testTrackerDataURL_ifNoCohort_returnsDefaultURL() {
        // GIVEN
        let privacyConfig = MockPrivacyConfiguration()
        privacyConfig.subfeatureSettings = "{ \"controlUrl\": \"\(controlURL)\", \"treatmentUrl\": \"\(treatmentURL)\"}"
        mockPrivacyConfigurationManager.privacyConfig = privacyConfig

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url, URL.trackerDataSet)
    }

    func test_trackerDataURL_returnsFirstAvailableCohortURL() {
        // GIVEN: Multiple experiments, only the second one has a valid cohort.
        let firstExperimentControlURL = "first-control.json"
        let secondExperimentTreatmentURL = "second-treatment.json"
        let thirdExperimentTreatmentURL = "third-treatment.json"
        let privacyConfig = MockPrivacyConfigurationMockSubfeatureSettings()
        privacyConfig.mockSettings = [
            TdsExperimentType(rawValue: 0)!.subfeature.rawValue: """
            {
                "controlUrl": "\(firstExperimentControlURL)",
                "treatmentUrl": "first-treatment.json"
            }
            """,
            TdsExperimentType(rawValue: 1)!.subfeature.rawValue: """
            {
                "controlUrl": "second-control.json",
                "treatmentUrl": "\(secondExperimentTreatmentURL)"
            }
            """,
            TdsExperimentType(rawValue: 2)!.subfeature.rawValue: """
            {
                "controlUrl": "third-control.json",
                "treatmentUrl": "\(thirdExperimentTreatmentURL)"
            }
            """
        ]
        mockPrivacyConfigurationManager.privacyConfig = privacyConfig
        mockFeatureFlagger.mockCohorts = [
            TdsExperimentType(rawValue: 1)!.subfeature.rawValue: TdsNextExperimentFlag.Cohort.treatment,
            TdsExperimentType(rawValue: 2)!.subfeature.rawValue: TdsNextExperimentFlag.Cohort.treatment
        ]

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url.absoluteString, URL.staticBase + "/trackerblocking/" + secondExperimentTreatmentURL)
    }

}

private class MockPrivacyConfigurationMockSubfeatureSettings: PrivacyConfiguration {

    func isSubfeatureEnabled(_ subfeature: any PrivacySubfeature, versionProvider: AppVersionProvider, randomizer: (Range<Double>) -> Double) -> Bool {
        false
    }

    func stateFor(_ subfeature: any PrivacySubfeature, versionProvider: AppVersionProvider, randomizer: (Range<Double>) -> Double) -> PrivacyConfigurationFeatureState {
        return .disabled(.disabledInConfig)
    }

    var identifier: String = "MockPrivacyConfiguration"
    var version: String? = "1234567890"
    var userUnprotectedDomains: [String] = []
    var tempUnprotectedDomains: [String] = []
    var trackerAllowlist: PrivacyConfigurationData.TrackerAllowlist = .init(entries: [:],
                                                                            state: PrivacyConfigurationData.State.enabled)
    var mockSettings: [String: String] = [:]
    func exceptionsList(forFeature featureKey: PrivacyFeature) -> [String] { [] }
    var isFeatureKeyEnabled: ((PrivacyFeature, AppVersionProvider) -> Bool)?
    func isEnabled(featureKey: PrivacyFeature, versionProvider: AppVersionProvider) -> Bool {
        isFeatureKeyEnabled?(featureKey, versionProvider) ?? true
    }
    func stateFor(featureKey: PrivacyFeature, versionProvider: AppVersionProvider) -> PrivacyConfigurationFeatureState {
        return .disabled(.disabledInConfig)
    }

    func stateFor(subfeatureID: SubfeatureID, parentFeatureID: ParentFeatureID, versionProvider: AppVersionProvider, randomizer: (Range<Double>) -> Double) -> PrivacyConfigurationFeatureState {
        return .disabled(.disabledInConfig)
    }

    func cohorts(for subfeature: any PrivacySubfeature) -> [PrivacyConfigurationData.Cohort]? {
        return nil
    }

    func cohorts(subfeatureID: SubfeatureID, parentFeatureID: ParentFeatureID) -> [PrivacyConfigurationData.Cohort]? {
        return nil
    }

    func isFeature(_ feature: PrivacyFeature, enabledForDomain: String?) -> Bool { true }
    func isProtected(domain: String?) -> Bool { true }
    func isUserUnprotected(domain: String?) -> Bool { false }
    func isTempUnprotected(domain: String?) -> Bool { false }
    func isInExceptionList(domain: String?, forFeature featureKey: PrivacyFeature) -> Bool { false }
    func settings(for feature: PrivacyFeature) -> PrivacyConfigurationData.PrivacyFeature.FeatureSettings {
        [:] }
    func settings(for subfeature: any BrowserServicesKit.PrivacySubfeature) -> PrivacyConfigurationData.PrivacyFeature.SubfeatureSettings? {
        return mockSettings[subfeature.rawValue] ?? nil
    }
    func userEnabledProtection(forDomain: String) {}
    func userDisabledProtection(forDomain: String) {}
}

private class MockFeatureFlaggerMockSettings: FeatureFlagger {
    var internalUserDecider: InternalUserDecider = DefaultInternalUserDecider(store: MockInternalUserStoring())
    var localOverrides: FeatureFlagLocalOverriding?
    var mockCohorts: [String: any FlagCohort] = [:]

    var isFeatureOn = true
    func isFeatureOn<Flag: FeatureFlagDescribing>(for featureFlag: Flag, allowOverride: Bool) -> Bool {
        return isFeatureOn
    }

    func getCohortIfEnabled(_ subfeature: any PrivacySubfeature) -> CohortID? {
        return nil
    }

    func getCohortIfEnabled<Flag>(for featureFlag: Flag) -> (any FlagCohort)? where Flag: FeatureFlagExperimentDescribing {
        return mockCohorts[featureFlag.rawValue]
    }

    func getAllActiveExperiments() -> Experiments {
        return [:]
    }
}
