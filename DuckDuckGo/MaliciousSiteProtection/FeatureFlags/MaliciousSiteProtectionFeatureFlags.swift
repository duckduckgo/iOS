//
//  MaliciousSiteProtectionFeatureFlags.swift
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
import BrowserServicesKit
import Core

protocol MaliciousSiteProtectionFeatureFlagger {
    /// A Boolean value indicating whether malicious site protection is enabled.
    /// - Returns: `true` if malicious site protection is enabled; otherwise, `false`.
    var isMaliciousSiteProtectionEnabled: Bool { get }

    /// Checks if should detect malicious threats for a specific domain.
    /// - Parameter domain: The domain to check for malicious threat.
    /// - Returns: `true` if should check for malicious threats for the specified domain; otherwise, `false`.
    func shouldDetectMaliciousThreat(forDomain domain: String?) -> Bool
}

final class MaliciousSiteProtectionFeatureFlags {
    private let featureFlagger: FeatureFlagger
    private let privacyConfigManager: PrivacyConfigurationManaging

    init(
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
        privacyConfigManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager
    ) {
        self.featureFlagger = featureFlagger
        self.privacyConfigManager = privacyConfigManager
    }
}

// MARK: - MaliciousSiteProtectionFeatureFlagger

extension MaliciousSiteProtectionFeatureFlags: MaliciousSiteProtectionFeatureFlagger {

    var isMaliciousSiteProtectionEnabled: Bool {
        featureFlagger.isFeatureOn(.maliciousSiteProtection)
    }

    func shouldDetectMaliciousThreat(forDomain domain: String?) -> Bool {
        privacyConfigManager.privacyConfig.isFeature(.maliciousSiteProtection, enabledForDomain: domain)
    }

}
