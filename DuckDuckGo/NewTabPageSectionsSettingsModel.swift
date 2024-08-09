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
    convenience init(storage: NewTabPageSectionsSettingsStorage = NewTabPageSectionsSettingsStorage(),
                     pixelFiring: PixelFiring.Type = Pixel.self) {
        self.init(settingsStorage: storage,
                  onItemEnabled: { Self.onEnabled($0, isEnabled: $1, pixelFiring: pixelFiring) },
                  onItemReordered: { Self.onReordered(pixelFiring: pixelFiring) })
    }

    private static func onEnabled(_ section: SettingItem, isEnabled: Bool, pixelFiring: PixelFiring.Type) {
        if isEnabled {
            pixelFiring.fire(.newTabPageCustomizeSectionOn(section.nameForPixel), withAdditionalParameters: [:])
        } else {
            pixelFiring.fire(.newTabPageCustomizeSectionOff(section.nameForPixel), withAdditionalParameters: [:])
        }
    }

    private static func onReordered(pixelFiring: PixelFiring.Type) {
        pixelFiring.fire(.newTabPageSectionReordered, withAdditionalParameters: [:])
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
