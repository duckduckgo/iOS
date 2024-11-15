//
//  ThreatProtectionFeatureCheck.swift
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

protocol ThreatProtectionFeatureChecking {
    var isThreatProtectionEnabled: Bool { get }

    func isThreatProtectionEnabled(forDomain domain: String?) -> Bool
}

final class ThreatProtectionFeatureCheck {
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

// MARK: - ThreatProtectionFeatureChecking

extension ThreatProtectionFeatureCheck: ThreatProtectionFeatureChecking {

    var isThreatProtectionEnabled: Bool {
        featureFlagger.isFeatureOn(.threatDetectionErrorPage)
    }

    func isThreatProtectionEnabled(forDomain domain: String?) -> Bool {
        privacyConfigManager.privacyConfig.isFeature(.phishingDetection, enabledForDomain: domain) && isThreatProtectionEnabled
    }

}
