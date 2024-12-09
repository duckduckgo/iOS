//
//  AIChatSettingsProvider.swift
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

public protocol AIChatSettingsProvider {
    /// The URL used to open AI Chat in the `AIChatViewController`.
    var aiChatURL: URL { get }

    /// The user settings state for the AI Chat browsing address bar.
    var isAIChatAddressBarUserSettingsEnabled: Bool { get }

    /// The user settings state for the AI Chat browsing menu icon.
    var isAIChatBrowsingMenuUserSettingsEnabled: Bool { get }

    /// The remote feature flag state for AI Chat.
    var isAIChatFeatureEnabled: Bool { get }

    /// The remote feature flag for the AI Chat shortcut in the browsing menu.
    var isAIChatBrowsingMenubarShortcutFeatureEnabled: Bool { get }

    /// The remote feature flag for the AI Chat shortcut in the address bar.
    var isAIChatAddressBarShortcutFeatureEnabled: Bool { get }

    /// Updates the user settings state for the AI Chat browsing menu.
    func enableAIChatBrowsingMenuUserSettings(enable: Bool)

    /// Updates the user settings state for the AI Chat address bar.
    func enableAIChatAddressBarUserSettings(enable: Bool)
}
