//
//  AIChatRemoteSettingsProvider.swift
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

public protocol AIChatRemoteSettingsProvider {
    /// The URL used to open AI Chat in `AIChatViewController`.
    var aiChatURL: URL { get }

    /// Indicates if AI Chat parent feature is enabled.
    var isAIChatEnabled: Bool { get }

    /// Indicates if the AI Chat shortcut sub-feature is enabled in the browsing toolbar.
    var isBrowsingToolbarShortcutEnabled: Bool { get }

    /// Indicates if the AI Chat shortcut sub-feature is enabled in the address bar.
    var isAddressBarShortcutEnabled: Bool { get }
}
