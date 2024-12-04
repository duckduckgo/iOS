//
//  AIChatSettings.swift
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
import Core

/// This struct serves as a wrapper for PrivacyConfigurationManaging, enabling the retrieval of data relevant to AIChat.
/// It also fire pixels when necessary data is missing.
struct AIChatSettings: AIChatSettingsProvider {
    enum SettingsValue: String {
        case aiChatURL

        var defaultValue: String {
            switch self {
            case .aiChatURL: return "https://duckduckgo.com/?q=DuckDuckGo+AI+Chat&ia=chat&duckai=4"
            }
        }
    }

    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private var remoteSettings: PrivacyConfigurationData.PrivacyFeature.FeatureSettings {
        privacyConfigurationManager.privacyConfig.settings(for: .aiChat)
    }
    private let internalUserDecider: InternalUserDecider
    private let userDefaults: UserDefaults

    init(privacyConfigurationManager: PrivacyConfigurationManaging, internalUserDecider: InternalUserDecider, userDefaults: UserDefaults = .standard) {
        self.internalUserDecider = internalUserDecider
        self.privacyConfigurationManager = privacyConfigurationManager
        self.userDefaults = userDefaults
    }

    // MARK: - Public

    var aiChatURL: URL {
        guard let url = URL(string: getSettingsData(.aiChatURL)) else {
            return URL(string: SettingsValue.aiChatURL.defaultValue)!
        }
        return url
    }

    var isAIChatBrowsingMenuUserSettingsEnabled: Bool {
        userDefaults.showAIChatBrowsingMenu
    }

    var isAIChatAddressBarUserSettingsEnabled: Bool {
        userDefaults.showAIChatAddressBar
    }

    var isAIChatFeatureEnabled: Bool {
        privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .aiChat) || internalUserDecider.isInternalUser
    }

    var isAIChatAddressBarShortcutFeatureEnabled: Bool {
        return isFeatureEnabled(for: .addressBarShortcut)
    }

    var isAIChatBrowsingToolbarShortcutFeatureEnabled: Bool {
        return isFeatureEnabled(for: .browsingToolbarShortcut)
    }


    func enableAIChatBrowsingMenuUserSettings(enable: Bool) {
        userDefaults.showAIChatBrowsingMenu = enable
    }

    func enableAIChatAddressBarUserSettings(enable: Bool) {
        userDefaults.showAIChatAddressBar = enable
    }

    // MARK: - Private

    private func isFeatureEnabled(for subfeature: AIChatSubfeature) -> Bool {
        let isSubfeatureFlagEnabled = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(subfeature)
        let isInternalUser = internalUserDecider.isInternalUser
        return (isSubfeatureFlagEnabled || isInternalUser) && isAIChatBrowsingMenuUserSettingsEnabled
    }
    
    private func getSettingsData(_ value: SettingsValue) -> String {
        if let value = remoteSettings[value.rawValue] as? String {
            return value
        } else {
            Pixel.fire(pixel: .aiChatNoRemoteSettingsFound(settings: value.rawValue))
            return value.defaultValue
        }
    }
}

private extension UserDefaults {
    enum Keys {
        static let showAIChatBrowsingMenu = "aichat.settings.showAIChatBrowsingMenu"
        static let showAIChatAddressBar = "aichat.settings.showAIChatAddressBar"
    }

    static let showAIChatBrowsingMenuDefaultValue = true
    static let showAIChatAddressBarDefaultValue = true

    @objc dynamic var showAIChatBrowsingMenu: Bool {
        get {
            value(forKey: Keys.showAIChatBrowsingMenu) as? Bool ?? Self.showAIChatBrowsingMenuDefaultValue
        }

        set {
            guard newValue != showAIChatBrowsingMenu else { return }
            set(newValue, forKey: Keys.showAIChatBrowsingMenu)
        }
    }

    @objc dynamic var showAIChatAddressBar: Bool {
        get {
            value(forKey: Keys.showAIChatAddressBar) as? Bool ?? Self.showAIChatAddressBarDefaultValue
        }

        set {
            guard newValue != showAIChatAddressBar else { return }
            set(newValue, forKey: Keys.showAIChatAddressBar)
        }
    }
}
