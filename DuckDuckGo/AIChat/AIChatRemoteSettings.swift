//
//  AIChatRemoteSettings.swift
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
import AIChat
import Foundation

/// This struct serves as a wrapper for PrivacyConfigurationManaging, enabling the retrieval of data relevant to AIChat.
/// It also fire pixels when necessary data is missing.
struct AIChatRemoteSettings: AIChatRemoteSettingsProvider {
    enum SettingsValue: String {
        case aiChatURL

        var defaultValue: String {
            switch self {
            case .aiChatURL: return "https://duckduckgo.com/?q=DuckDuckGo+AI+Chat&ia=chat&duckai=4"
            }
        }
    }

    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private var settings: PrivacyConfigurationData.PrivacyFeature.FeatureSettings {
        privacyConfigurationManager.privacyConfig.settings(for: .aiChat)
    }

    init(privacyConfigurationManager: PrivacyConfigurationManaging) {
        self.privacyConfigurationManager = privacyConfigurationManager
    }

    // MARK: - Public

    var aiChatURL: URL {
        guard let url = URL(string: getSettingsData(.aiChatURL)) else {
            return URL(string: SettingsValue.aiChatURL.defaultValue)!
        }
        return url
    }

    var isAIChatEnabled: Bool {
        privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .aiChat)
    }

    // browsingToolbarShortcut
    var isBrowsingToolbarShortcutEnabled: Bool {
        privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(AIChatSubfeature.toolbarShortcut)
    }

    // addressBarShortcut
    var isAddressBarShortcutEnabled: Bool {
        privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(AIChatSubfeature.applicationMenuShortcut)
    }

    // MARK: - Private

    private func getSettingsData(_ value: SettingsValue) -> String {
        if let value = settings[value.rawValue] as? String {
            return value
        } else {
            Logger.aiChat.debug("No remote settings found \(value.rawValue)")
            // PixelKit.fire(GeneralPixel.aichatNoRemoteSettingsFound(value), includeAppVersionParameter: true)
            return value.defaultValue
        }
    }
}
