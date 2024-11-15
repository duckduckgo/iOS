//
//  ThreatProtectionManager.swift
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

import Foundation
import PhishingDetection
import BrowserServicesKit

struct ThreatProtectionConfiguration {
    var revision: Int = 1686837
    var filterSetURL: URL = Bundle.main.url(forResource: "filterSet", withExtension: "json")!
    var filterSetDataSHA: String = "517e610cd7c304f91ff5aaee91d570f7b6e678dbe9744e00cdb0a3126068432f"
    var hashPrefixURL: URL = Bundle.main.url(forResource: "hashPrefixes", withExtension: "json")!
    var hashPrefixDataSHA: String = "05075ab14302a9e0329fbc0ba7e4e3118d7fa37846ec087c3942cfb1be92ffe0"
}

final class ThreatProtectionManager {
    private let detector: ThreatDetecting
    private let dataActivity: PhishingDetectionDataActivityHandling
    private let featureCheck: ThreatProtectionFeatureChecking
    private let configuration: ThreatProtectionConfiguration

    init(
        threatDetector: ThreatDetecting,
        threatDataActivity: PhishingDetectionDataActivityHandling,
        threatProtectionFeatureCheck: ThreatProtectionFeatureChecking,
        configuration: ThreatProtectionConfiguration
    ) {
        detector = threatDetector
        dataActivity = threatDataActivity
        featureCheck = threatProtectionFeatureCheck
        self.configuration = configuration
    }

    convenience init() {
        let configuration = ThreatProtectionConfiguration()
        let dataProvider = PhishingDetectionDataProvider(
            revision: configuration.revision,
            filterSetURL: configuration.filterSetURL,
            filterSetDataSHA: configuration.filterSetDataSHA,
            hashPrefixURL: configuration.hashPrefixURL,
            hashPrefixDataSHA: configuration.hashPrefixDataSHA
        )
        let dataStore = PhishingDetectionDataStore(dataProvider: dataProvider)
        let apiClient = PhishingDetectionAPIClient()
        let detector = PhishingDetector(apiClient: apiClient, dataStore: dataStore, eventMapping: ThreatProtectionEventMapper())
        let updateManager = PhishingDetectionUpdateManager(client: apiClient, dataStore: dataStore)
        let dataActivity = PhishingDetectionDataActivities(phishingDetectionDataProvider: dataProvider, updateManager: updateManager)

        self.init(
            threatDetector: detector,
            threatDataActivity: dataActivity,
            threatProtectionFeatureCheck: ThreatProtectionFeatureCheck(),
            configuration: ThreatProtectionConfiguration()
        )
    }

    deinit {
        // TODO: Stop update Tasks
    }
}

// MARK: - ThreatDetecting

extension ThreatProtectionManager: ThreatDetecting {

    func checkIsUrlMalicious(url: URL) async -> ThreatKind {
        guard featureCheck.isThreatProtectionEnabled(forDomain: url.host) else { return .none }

        return await detector.checkIsUrlMalicious(url: url)
    }

}

// MARK: - Private

private extension ThreatProtectionManager {

    func setupBindings() {
//        cancellable = detectionPreferences.$isEnabled.sink { [weak self] isEnabled in
//            self?.handleIsEnabledChange(enabled: isEnabled)
//        }
    }

    func startUpdateTasksIfEnabled() {
        // TODO: If feature is enabled startUpdateTasks()
    }

    func handleIsEnabledChange(enabled: Bool) {
        // TODO: If Enabled Start Update Task otherwise stop Update Task
    }

    func startUpdateTasks() {
        // TODO: Start Data Activities
    }

    func stopUpdateTasks() {
        // TODO: Stop Data Activities
    }

}

// MARK: - Mocking BSK Changes [To Remove]

enum ThreatKind {
    case phishing
    case malware
    case none
}

protocol ThreatDetecting {
    func checkIsUrlMalicious(url: URL) async -> ThreatKind
}

extension PhishingDetector: ThreatDetecting {

    func checkIsUrlMalicious(url: URL) async -> ThreatKind {
        return await isMalicious(url: url) ? .phishing : .none
    }

}
