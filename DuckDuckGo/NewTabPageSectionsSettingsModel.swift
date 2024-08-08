//
//  NewTabPageSectionsSettingsModel.swift
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

typealias NewTabPageSectionsSettingsModel = NewTabPageSettingsModel<NewTabPageSection, NewTabPageSectionsSettingsStorage>

extension NewTabPageSectionsSettingsModel {
    convenience init(storage: NewTabPageSectionsSettingsStorage = NewTabPageSectionsSettingsStorage()) {
        self.init(settingsStorage: storage,
                  onItemEnabled: Self.onEnabled(_:isEnabled:),
                  onItemReordered: Self.onReordered)
    }

    private static func onEnabled(_ section: SettingItem, isEnabled: Bool) {
        if isEnabled {
            Pixel.fire(.newTabPageSectionOn(section.nameForPixel), withAdditionalParameters: [:])
        } else {
            Pixel.fire(.newTabPageSectionOff(section.nameForPixel), withAdditionalParameters: [:])
        }
    }

    private static func onReordered() {
        Pixel.fire(.newTabPageSectionReordered, withAdditionalParameters: [:])
    }
}

private extension NewTabPageSection {
    var nameForPixel: String {
        switch self {
        case .favorites: return "favorites"
        case .shortcuts: return "shortcuts"
        }
    }
}
