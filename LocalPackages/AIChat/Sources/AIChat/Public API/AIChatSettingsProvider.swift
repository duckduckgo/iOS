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
    /// The URL used to open AI Chat in `AIChatViewController`.
    var aiChatURL: URL { get }

    /// User settings state for AI Chat
    var isAIChatUserSettingsEnabled: Bool { get }

    /// Remote feature flag state for AI Chat
    var isAIChatFeatureEnabled: Bool { get }

    /// Remote feature flag for AI Chat shortcut in browsing menu
    var isAIChatBrowsingToolbarShortcutFeatureEnabled: Bool { get }

    /// Update user settings state for AI Chat
    func enableAIChatUserSettings(enable: Bool)
}
