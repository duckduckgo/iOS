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
                /// https://app.asana.com/0/1208541424548398/1208567543352020/f
            case .aiChatURL: return "https://duckduckgo.com/?q=DuckDuckGo+AI+Chat&ia=chat&duckai=4"
            }
        }
    }

    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private var remoteSettings: PrivacyConfigurationData.PrivacyFeature.FeatureSettings {
        privacyConfigurationManager.privacyConfig.settings(for: .aiChat)
    }
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

    init(privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         userDefaults: UserDefaults = .standard,
         notificationCenter: NotificationCenter = .default) {
        self.privacyConfigurationManager = privacyConfigurationManager
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
    }

    // MARK: - Public

    var aiChatURL: URL {
        guard let url = URL(string: getSettingsData(.aiChatURL)) else {
            return URL(string: SettingsValue.aiChatURL.defaultValue)!
        }
        return url
    }

    var isAIChatBrowsingMenuUserSettingsEnabled: Bool {
        userDefaults.showAIChatBrowsingMenu && isAIChatBrowsingMenubarShortcutFeatureEnabled
    }

    var isAIChatAddressBarUserSettingsEnabled: Bool {
        userDefaults.showAIChatAddressBar && isAIChatAddressBarShortcutFeatureEnabled
    }

    var isAIChatFeatureEnabled: Bool {
        privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .aiChat)
    }

    var isAIChatAddressBarShortcutFeatureEnabled: Bool {
        return isFeatureEnabled(for: .addressBarShortcut)
    }

    var isAIChatBrowsingMenubarShortcutFeatureEnabled: Bool {
        return isFeatureEnabled(for: .browsingToolbarShortcut)
    }

    func enableAIChatBrowsingMenuUserSettings(enable: Bool) {
        userDefaults.showAIChatBrowsingMenu = enable
        triggerSettingsChangedNotification()
    }

    func enableAIChatAddressBarUserSettings(enable: Bool) {
        userDefaults.showAIChatAddressBar = enable
        triggerSettingsChangedNotification()
    }

    // MARK: - Private

    private func triggerSettingsChangedNotification() {
        notificationCenter.post(name: .aiChatSettingsChanged, object: nil)
    }

    private func isFeatureEnabled(for subfeature: AIChatSubfeature) -> Bool {
        return privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(subfeature)
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

public extension NSNotification.Name {
    static let aiChatSettingsChanged = Notification.Name("com.duckduckgo.aichat.settings.changed")
}
