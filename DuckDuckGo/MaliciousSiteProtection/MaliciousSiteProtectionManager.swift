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

extension MaliciousSiteProtectionFeatureFlags: MaliciousSiteProtectionFeatureFlagger {

    init(
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
        privacyConfigManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager
    ) {
        self.init(privacyConfigManager: privacyConfigManager, isMaliciousSiteProtectionEnabled: {
            featureFlagger.isFeatureOn(.maliciousSiteProtection)
        })
    }

}

final class MaliciousSiteProtectionManager: MaliciousSiteDetecting {

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
