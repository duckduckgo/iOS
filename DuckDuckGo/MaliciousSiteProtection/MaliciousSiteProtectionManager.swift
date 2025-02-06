//
//  MaliciousSiteProtectionManager.swift
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
import MaliciousSiteProtection
import Common
import Core

typealias MaliciousSiteProtectionManaging = MaliciousSiteDetecting & MaliciousSiteProtectionDatasetsFetching

final class MaliciousSiteProtectionManager {
    private let detector: MaliciousSiteDetecting
    private let dataFetcher: MaliciousSiteProtectionDatasetsFetching
    private let preferencesManager: MaliciousSiteProtectionPreferencesReading
    private let maliciousSiteProtectionFeatureFlagger: MaliciousSiteProtectionFeatureFlagger

    init(
        dataFetcher: MaliciousSiteProtectionDatasetsFetching,
        api: MaliciousSiteProtectionAPI,
        dataManager: MaliciousSiteProtection.DataManager,
        detector: MaliciousSiteProtection.MaliciousSiteDetecting? = nil,
        preferencesManager: MaliciousSiteProtectionPreferencesReading,
        maliciousSiteProtectionFeatureFlagger: MaliciousSiteProtectionFeatureFlagger
    ) {
        self.dataFetcher = dataFetcher
        self.preferencesManager = preferencesManager
        self.maliciousSiteProtectionFeatureFlagger = maliciousSiteProtectionFeatureFlagger
        self.detector = detector ?? MaliciousSiteDetector(
            apiEnvironment: api.environment,
            service: api.service,
            dataManager: dataManager,
            eventMapping: MaliciousSiteProtectionEventMapper.debugEvents
        )
    }
}

// MARK: - MaliciousSiteProtectionDatasetsFetching

extension MaliciousSiteProtectionManager: MaliciousSiteProtectionDatasetsFetching {

    func startFetching() {
        dataFetcher.startFetching()
    }
    
    func registerBackgroundRefreshTaskHandler() {
        dataFetcher.registerBackgroundRefreshTaskHandler()
    }
    
}

// MARK: - MaliciousSiteDetecting

extension MaliciousSiteProtectionManager: MaliciousSiteDetecting {

    func evaluate(_ url: URL) async -> ThreatKind? {
        guard
            maliciousSiteProtectionFeatureFlagger.shouldDetectMaliciousThreat(forDomain: url.host),
            preferencesManager.isMaliciousSiteProtectionOn
        else {
            return .none
        }

        return await detector.evaluate(url)
    }

}

// MARK: - Configuration

extension MaliciousSiteProtectionManager {
    
    static func fileName(for dataType: MaliciousSiteProtection.DataManager.StoredDataType) -> String {
        switch (dataType, dataType.threatKind) {
        case (.hashPrefixSet, .phishing): "phishingHashPrefixes.json"
        case (.filterSet, .phishing): "phishingFilterSet.json"
        case (.hashPrefixSet, .malware): "malwareHashPrefixes.json"
        case (.filterSet, .malware): "malwareFilterSet.json"
        }
    }
    
}
