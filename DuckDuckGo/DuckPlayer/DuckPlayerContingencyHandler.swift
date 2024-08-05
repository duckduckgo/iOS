//
//  DuckPlayerContingencyHandler.swift
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

protocol DuckPlayerContingencyHandler {
    var shouldDisplayContingencyMessage: Bool { get }
    var learnMoreURL: URL? { get }
}

struct DefaultDuckPlayerContingencyHandler: DuckPlayerContingencyHandler {
    private let privacyConfigurationManager: PrivacyConfigurationManaging

    var shouldDisplayContingencyMessage: Bool {
        learnMoreURL != nil && !isDuckPlayerFeatureEnabled
    }

    private var isDuckPlayerFeatureEnabled: Bool {
        privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .duckPlayer)
    }

    var learnMoreURL: URL? {
        let settings = privacyConfigurationManager.privacyConfig.settings(for: .duckPlayer)
        guard let link = settings[.duckPlayerDisabledHelpPageLink] as? String,
        let pageLink = URL(string: link) else { return nil }
        return pageLink
    }

    internal init(privacyConfigurationManager: any PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.privacyConfigurationManager = privacyConfigurationManager
    }
}

// MARK: - Settings key for Dictionary extension

private enum SettingsKey: String {
    case duckPlayerDisabledHelpPageLink
}

private extension Dictionary where Key == String {
    subscript(key: SettingsKey) -> Value? {
        return self[key.rawValue]
    }
}
