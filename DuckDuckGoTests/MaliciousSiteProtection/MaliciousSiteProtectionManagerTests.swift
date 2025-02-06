//
//  MaliciousSiteProtectionManagerTests.swift
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

import Testing
import Foundation
import MaliciousSiteProtection
@testable import DuckDuckGo

@Suite("Malicious Site Protection - Manager", .serialized)
final class MaliciousSiteProtectionManagerTests {
    private var sut: MaliciousSiteProtectionManager!
    private var mockDetector: MockMaliciousSiteDetector!
    private var dataFetcherMock: MockMaliciousSiteProtectionDataFetcher!
    private var dataManager: MaliciousSiteProtection.DataManager!
    private var preferencesManagerMock: MockMaliciousSiteProtectionPreferencesManager!
    private var featureFlaggerMock: MockMaliciousSiteProtectionFeatureFlags!

    init() {
        dataManager = MaliciousSiteProtection.DataManager(
            fileStore: MockMaliciousSiteFileStore(),
            embeddedDataProvider: nil,
            fileNameProvider: { _ in "file.json" }
        )
        mockDetector = MockMaliciousSiteDetector()
        dataFetcherMock = MockMaliciousSiteProtectionDataFetcher()
        preferencesManagerMock = MockMaliciousSiteProtectionPreferencesManager()
        featureFlaggerMock = MockMaliciousSiteProtectionFeatureFlags()
        sut = MaliciousSiteProtectionManager(
            dataFetcher: dataFetcherMock,
            api: MaliciousSiteProtectionAPI(),
            dataManager: dataManager,
            detector: mockDetector,
            preferencesManager: preferencesManagerMock,
            maliciousSiteProtectionFeatureFlagger: featureFlaggerMock
        )
    }

    @Test("Start Fetching Datasets Asks DatasetsFetcher To Fetch Data")
    func whenStartFetchingDatasetsIsCalledThenItAsksDataFetcherToFetchData() {
        // GIVEN
        #expect(!dataFetcherMock.didCallStartFetching)

        // WHEN
        sut.startFetching()

        // THEN
        #expect(dataFetcherMock.didCallStartFetching)
    }

    @Test("Register Background Tasks Asks DatasetsFetcher to Register Background Tasks")
    func whenRegisterBackgroundTasksIsCalledThenItAsksDataFetcherToRegisterBackgroundTasks() {
        // GIVEN
        #expect(!dataFetcherMock.didCallRegisterBackgroundRefreshTaskHandler)

        // WHEN
        sut.registerBackgroundRefreshTaskHandler()

        // THEN
        #expect(dataFetcherMock.didCallRegisterBackgroundRefreshTaskHandler)
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
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = false
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
        preferencesManagerMock.isMaliciousSiteProtectionOn = true
        featureFlaggerMock.shouldDetectMaliciousThreatForDomainResult = false
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
        preferencesManagerMock.isMaliciousSiteProtectionOn = false
        featureFlaggerMock.shouldDetectMaliciousThreatForDomainResult = true
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
        preferencesManagerMock.isMaliciousSiteProtectionOn = true
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        featureFlaggerMock.shouldDetectMaliciousThreatForDomainResult = true
        let url = try #require(URL(string: threatInfo.path))

        // WHEN
        let result = await sut.evaluate(url)

        // THEN
        #expect(result == threatInfo.threat)
    }
}
