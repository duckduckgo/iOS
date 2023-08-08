//
//  PrivacyConfigurationManagerMock.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Combine
import BrowserServicesKit

class PrivacyConfigurationMock: PrivacyConfiguration {

    var identifier: String = "id"

    var userUnprotectedDomains: [String] = []

    var tempUnprotectedDomains: [String] = []

    var trackerAllowlist: PrivacyConfigurationData.TrackerAllowlist = .init(entries: [:],
                                                                            state: PrivacyConfigurationData.State.enabled)

    var exceptionList: [PrivacyFeature: [String]] = [:]
    func exceptionsList(forFeature featureKey: PrivacyFeature) -> [String] {
        return exceptionList[featureKey] ?? []
    }

    var enabledFeatures: [PrivacyFeature: Set<String>] = [:]
    func isFeature(_ feature: PrivacyFeature, enabledForDomain domain: String?) -> Bool {
        return enabledFeatures[feature]?.contains(domain ?? "") ?? false
    }

    var enabledFeaturesForVersions: [PrivacyFeature: Set<String>] = [:]
    func isEnabled(featureKey: PrivacyFeature, versionProvider: AppVersionProvider) -> Bool {
        return enabledFeaturesForVersions[featureKey]?.contains(versionProvider.appVersion() ?? "") ?? false
    }

    var enabledSubfeaturesForVersions: [String: Set<String>] = [:]
    func isSubfeatureEnabled(_ subfeature: any PrivacySubfeature, versionProvider: AppVersionProvider, randomizer: (Range<Double>) -> Double) -> Bool {
        return enabledSubfeaturesForVersions[subfeature.rawValue]?.contains(versionProvider.appVersion() ?? "") ?? false
    }

    var protectedDomains = Set<String>()
    func isProtected(domain: String?) -> Bool {
        return protectedDomains.contains(domain ?? "")
    }

    var tempUnprotected = Set<String>()
    func isTempUnprotected(domain: String?) -> Bool {
        return tempUnprotected.contains(domain ?? "")
    }

    func isInExceptionList(domain: String?, forFeature featureKey: PrivacyFeature) -> Bool {
        return exceptionList[featureKey]?.contains(domain ?? "") ?? false
    }

    var settings: [PrivacyFeature: PrivacyConfigurationData.PrivacyFeature.FeatureSettings] = [:]
    func settings(for feature: PrivacyFeature) -> PrivacyConfigurationData.PrivacyFeature.FeatureSettings {
        return settings[feature] ?? [:]
    }

    var userUnprotected = Set<String>()
    func userEnabledProtection(forDomain domain: String) {
        userUnprotected.remove(domain)
    }

    func userDisabledProtection(forDomain domain: String) {
        userUnprotected.insert(domain)
    }

    func isUserUnprotected(domain: String?) -> Bool {
        return userUnprotected.contains(domain ?? "")
    }

}

class PrivacyConfigurationManagerMock: PrivacyConfigurationManaging {
    var embeddedConfigData: BrowserServicesKit.PrivacyConfigurationManager.ConfigurationData {
        fatalError("not implemented")
    }

    var fetchedConfigData: BrowserServicesKit.PrivacyConfigurationManager.ConfigurationData? {
        fatalError("not implemented")
    }

    var currentConfig: Data {
        Data()
    }

    var updatesSubject = PassthroughSubject<Void, Never>()
    var updatesPublisher: AnyPublisher<Void, Never> {
        updatesSubject.eraseToAnyPublisher()
    }

    var privacyConfig: PrivacyConfiguration = PrivacyConfigurationMock()

    var reloadFired = [(etag: String?, data: Data?)]()
    var reloadResult: PrivacyConfigurationManager.ReloadResult = .embedded
    func reload(etag: String?, data: Data?) -> PrivacyConfigurationManager.ReloadResult {
        reloadFired.append((etag, data))
        return reloadResult
    }

}
