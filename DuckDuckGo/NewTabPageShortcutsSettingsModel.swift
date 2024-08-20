//
//  NewTabPageShortcutsSettingsModel.swift
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
import Core
import BrowserServicesKit

typealias NewTabPageShortcutsSettingsModel = NewTabPageSettingsModel<NewTabPageShortcut, NewTabPageShortcutsSettingsStorage>

extension NewTabPageShortcutsSettingsModel {
    convenience init(storage: NewTabPageShortcutsSettingsStorage = NewTabPageShortcutsSettingsStorage(),
                     featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
                     pixelFiring: PixelFiring.Type = Pixel.self) {
        self.init(settingsStorage: storage,
                  onItemEnabled: { Self.onEnabled($0, isEnabled: $1, pixelFiring: pixelFiring) },
                  onItemReordered: nil,
                  visibilityFilter: { shortcut in
            switch shortcut {
            case .aiChat, .bookmarks, .downloads, .settings:
                return true
            case .passwords:
                return featureFlagger.isFeatureOn(.autofillAccessCredentialManagement)
            }
        })
    }
    
    private static func onEnabled(_ shortcut: SettingItem, isEnabled: Bool, pixelFiring: PixelFiring.Type) {
        if isEnabled {
            pixelFiring.fire(.newTabPageCustomizeShortcutAdded(shortcut.nameForPixel), withAdditionalParameters: [:])
        } else {
            pixelFiring.fire( .newTabPageCustomizeShortcutRemoved(shortcut.nameForPixel), withAdditionalParameters: [:])
        }
    }
}
