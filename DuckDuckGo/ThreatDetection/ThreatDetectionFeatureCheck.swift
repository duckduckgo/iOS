//
//  ThreatDetectionFeatureCheck.swift
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

// MARK: - Interfaces

/// A type that determines whether threat detection settings are enabled.
protocol ThreatDetectionSettingsChecking {
    /// A Boolean value indicating whether threat detection settings are enabled, allowing the user to enable / disable the feature in the App Settings.
    /// - Returns: `true` if threat detection settings are enabled; otherwise, `false`.
    var isThreatDetectionSettingsEnabled: Bool { get }
}

protocol ThreatDetectionFeatureChecking {
    /// A Boolean value indicating whether threat detection is enabled.
    /// - Returns: `true` if threat detection is enabled; otherwise, `false`.
    var isThreatDetectionEnabled: Bool { get }

    /// Checks if threat detection is enabled for a specific domain.
    /// - Parameter domain: The domain to check for threat detection.
    /// - Returns: `true` if threat detection is enabled for the specified domain; otherwise, `false`.
    func isThreatDetectionEnabled(forDomain domain: String?) -> Bool
}

// MARK: - Implementation

final class ThreatDetectionFeatureCheck {
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

// MARK: - ThreatDetectionFeatureChecking

extension ThreatDetectionFeatureCheck: ThreatDetectionFeatureChecking {

    var isThreatDetectionEnabled: Bool {
        featureFlagger.isFeatureOn(.threatDetectionErrorPage)
    }

    func isThreatDetectionEnabled(forDomain domain: String?) -> Bool {
        privacyConfigManager.privacyConfig.isFeature(.phishingDetection, enabledForDomain: domain) && isThreatDetectionEnabled
    }

}

// MARK: - ThreatDetectionPreferencesChecking

extension ThreatDetectionFeatureCheck: ThreatDetectionSettingsChecking {

    var isThreatDetectionSettingsEnabled: Bool {
        featureFlagger.isFeatureOn(.threatDetectionPreferences)
    }

}
