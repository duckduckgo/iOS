//
//  AppSettingsMock.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Bookmarks
import Foundation
@testable import DuckDuckGo

class AppSettingsMock: AppSettings {
    var isSyncBookmarksPaused: Bool = false

    var isSyncCredentialsPaused: Bool = false

    var currentAddressBarPosition: DuckDuckGo.AddressBarPosition = .top

    var showFullSiteAddress: Bool = false
    
    var autofillCredentialsEnabled: Bool = false
    
    var autofillCredentialsSavePromptShowAtLeastOnce: Bool = false
    
    var autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary: Bool = false

    var autofillIsNewInstallForOnByDefault: Bool?

    func setAutofillIsNewInstallForOnByDefault() { }

    var autocomplete: Bool = true

    var currentThemeName: DuckDuckGo.ThemeName = .systemDefault

    var autoClearAction: DuckDuckGo.AutoClearSettingsModel.Action = .clearData

    var autoClearTiming: DuckDuckGo.AutoClearSettingsModel.Timing = .delay15min

    var longPressPreviews: Bool = false

    var allowUniversalLinks: Bool = false

    var sendDoNotSell: Bool = true

    var currentFireButtonAnimation: DuckDuckGo.FireButtonAnimationType = .fireRising

    var textSize: Int = 14

    var favoritesDisplayMode: FavoritesDisplayMode = .displayNative(.mobile)

    var autofill: Bool = false

    var voiceSearchEnabled: Bool = false

    var widgetInstalled: Bool = false
    func isWidgetInstalled() async -> Bool {
        widgetInstalled
    }
    
    var autoconsentPromptSeen = true
    var autoconsentEnabled = true
}
