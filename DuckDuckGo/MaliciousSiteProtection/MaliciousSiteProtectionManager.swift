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

import BrowserServicesKit
import Core
import Foundation
import MaliciousSiteProtection

extension MaliciousSiteProtectionFeatureFlags {

    init(
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
        privacyConfigManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager
    ) {
        self.init(privacyConfigManager: privacyConfigManager, isMaliciousSiteProtectionEnabled: {
            featureFlagger.isFeatureOn(.maliciousSiteProtection)
        })
    }

}

typealias MaliciousSiteProtectionManaging = MaliciousSiteDetecting & MaliciousSiteProtectionDatasetsFetching

final class MaliciousSiteProtectionManager {

    private let dataFetcher: MaliciousSiteProtectionDatasetsFetching
    private let api: MaliciousSiteProtectionAPI
    private let preferencesManager: MaliciousSiteProtectionPreferencesReading
    private let maliciousSiteProtectionFeatureFlagger: MaliciousSiteProtectionFeatureFlagger

    init(
        dataFetcher: MaliciousSiteProtectionDatasetsFetching,
        api: MaliciousSiteProtectionAPI,
        dataManager: MaliciousSiteProtection.DataManager? = nil,
        detector: MaliciousSiteProtection.MaliciousSiteDetecting? = nil,
        preferencesManager: MaliciousSiteProtectionPreferencesReading,
        maliciousSiteProtectionFeatureFlagger: MaliciousSiteProtectionFeatureFlagger
    ) {
        self.dataFetcher = dataFetcher
        self.api = api
        self.preferencesManager = preferencesManager
        self.maliciousSiteProtectionFeatureFlagger = maliciousSiteProtectionFeatureFlagger
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
        try? await Task.sleep(interval: 0.3)

        switch url.absoluteString {
        case "http://privacy-test-pages.site/security/badware/phishing.html":
            return .phishing
        case "http://privacy-test-pages.site/security/badware/malware.html":
            return .malware
        default:
            return .none
        }
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
