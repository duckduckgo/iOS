//
//  MaliciousSiteProtectionManagerTests.swift
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
import TestUtils
import Foundation
import MaliciousSiteProtection
@testable import DuckDuckGo

@Suite("Malicious Site Protection - Manager Unit Tests", .serialized)
final class MaliciousSiteProtectionManagerTests {
    private var sut: MaliciousSiteProtectionManager!
    private var apiService: MockAPIService!
    private var mockDetector: MockMaliciousSiteDetector!
    private var mockDataProvider: MockMaliciousSiteDataProvider!
    private var dataManager: MaliciousSiteProtection.DataManager!
    private var preferencesManager: MockMaliciousSiteProtectionPreferencesManager!
    private var featureFlags: MockMaliciousSiteProtectionFeatureFlags!

    init() {
        preferencesManager = MockMaliciousSiteProtectionPreferencesManager()
        featureFlags = MockMaliciousSiteProtectionFeatureFlags()
        setupSUT()
    }

    @Test("Start Update Task on Init when Feature Enabled and Preferences Enabled")
    func whenInitialized_AndFeatureEnabled_AndPreferencesEnabled_ThenStartUpdateTask() async throws {
        // GIVEN
        featureFlags.isMaliciousSiteProtectionEnabled = true
        preferencesManager.isEnabled = true

        // WHEN
        setupSUT()

        // THEN
        #expect(sut.isBackgroundUpdatesEnabled)
    }

    @Test("Do not Start Update Task on Init when Preferences Disabled")
    func whenInitialized_AndFeatureEnabled_AndPreferencesDisabled_ThenDoNotStartUpdateTask() async throws {
        // GIVEN
        featureFlags.isMaliciousSiteProtectionEnabled = true
        preferencesManager.isEnabled = false

        // WHEN
        setupSUT()

        // THEN
        #expect(!sut.isBackgroundUpdatesEnabled)
        #expect(!mockDataProvider.didLoadHashPrefixes)
        #expect(!mockDataProvider.didLoadFilterSet)
    }

    @Test("Do not Start Update Task on Init when Feature Disabled")
    func whenInitialized_AndFeatureDisabled_ThenDoNotStartUpdateTask() async throws {
        // GIVEN
        featureFlags.isMaliciousSiteProtectionEnabled = false
        preferencesManager.isEnabled = true

        // WHEN
        setupSUT()

        // THEN
        #expect(!sut.isBackgroundUpdatesEnabled)
    }

    @Test("Start Update Task When Preferences Become Enabled")
    func whenPreferencesEnabledThenStartUpdateTask() async throws {
        // GIVEN
        featureFlags.isMaliciousSiteProtectionEnabled = true
        preferencesManager.isEnabled = false
        setupSUT()
        #expect(!sut.isBackgroundUpdatesEnabled)

        // WHEN
        preferencesManager.isEnabled = true

        // TRUE
        #expect(sut.isBackgroundUpdatesEnabled)
    }

    @Test("Stop Update Task When Preferences Become Disabled")
    func whenPreferencesDisabledThenStopUpdateTask() async throws {
        featureFlags.isMaliciousSiteProtectionEnabled = true
        setupSUT()
        preferencesManager.isEnabled = true
        #expect(sut.isBackgroundUpdatesEnabled)

        // WHEN
        preferencesManager.isEnabled = false

        // TRUE
        #expect(!sut.isBackgroundUpdatesEnabled)
    }

    @Test(
        "No Threat Detected when Feature is disabled",
        arguments: [
            "https://phishing.com",
            "https://malware.com",
        ]
    )
    func whenFeatureIsDisabledThenThreatIsNotDetected(path: String) async throws {
        // GIVEN
        featureFlags.isMaliciousSiteProtectionEnabled = false
        let url = try #require(URL(string: path))

        // WHEN
        let result = await sut.evaluate(url)

        // THEN
        #expect(result == nil)
    }

    @Test(
        "No Threat Detected When Domain Should Not Be Checked",
        arguments: [
            "https://phishing.com",
            "https://malware.com",
        ]
    )
    func whenEvaluateURL_AndShouldNotDetectMaliciousThreatForDomain_ThenReturnNil(path: String) async throws {
        // GIVEN
        preferencesManager.isEnabled = true
        featureFlags.shouldDetectMaliciousThreatForDomainResult = false
        let url = try #require(URL(string: path))

        // WHEN
        let result = await sut.evaluate(url)

        // THEN
        #expect(result == nil)
    }

    @Test(
        "No Threat Detected When Preferences is Disabled",
        arguments: [
            "https://phishing.com",
            "https://malware.com",
        ]
    )
    func whenEvaluateURL_AndPreferenceDisabled_ThenReturnNil(path: String) async throws {
        // GIVEN
        preferencesManager.isEnabled = false
        featureFlags.shouldDetectMaliciousThreatForDomainResult = true
        let url = try #require(URL(string: path))

        // WHEN
        let result = await sut.evaluate(url)

        // THEN
        #expect(result == nil)
    }

    @Test(
        "Evaluate URL returns Right Threat",
        arguments: [
            (path: "https://phishing.com", threat: ThreatKind.phishing),
            (path: "https://malware.com", threat: .malware),
            (path: "https://trusted.com", threat: nil)
        ]
    )
    func urlReturnsRightThreat(threatInfo: (path: String, threat: ThreatKind?)) async throws {
        // GIVEN
        preferencesManager.isEnabled = true
        featureFlags.isMaliciousSiteProtectionEnabled = true
        featureFlags.shouldDetectMaliciousThreatForDomainResult = true
        let url = try #require(URL(string: threatInfo.path))

        // WHEN
        let result = await sut.evaluate(url)

        // THEN
        #expect(result == threatInfo.threat)
    }

}

extension MaliciousSiteProtectionManagerTests {

    func setupSUT() {
        apiService = MockAPIService(requestHandler: { _ in
            .failure(CancellationError())
        })
        let mockFileStore = MockMaliciousSiteFileStore()
        mockDataProvider = MockMaliciousSiteDataProvider()
        dataManager = MaliciousSiteProtection.DataManager(
            fileStore: mockFileStore,
            embeddedDataProvider: mockDataProvider,
            fileNameProvider: { _ in "file.json" }
        )
        sut = MaliciousSiteProtectionManager(
            apiService: apiService,
            dataManager: dataManager,
            detector: MockMaliciousSiteDetector(),
            preferencesManager: preferencesManager,
            maliciousSiteProtectionFeatureFlagger: featureFlags
        )
    }
}
