//
//  AppSettings.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

enum AddressBarPosition: String, CaseIterable, CustomStringConvertible {
    case top
    case bottom

    var isBottom: Bool {
        self == .bottom
    }
    
    var description: String {
        return descriptionText
    }

    var descriptionText: String {
        switch self {
        case .top:
            return UserText.addressBarPositionTop
        case .bottom:
            return UserText.addressBarPositionBottom
        }
    }
}

protocol AppSettings: AnyObject, AppDebugSettings {
    var autocomplete: Bool { get set }
    var recentlyVisitedSites: Bool { get set }
    var currentThemeName: ThemeName { get set }
    
    var autoClearAction: AutoClearSettingsModel.Action { get set }
    var autoClearTiming: AutoClearSettingsModel.Timing { get set }

    var longPressPreviews: Bool { get set }

    var allowUniversalLinks: Bool { get set }
    
    var sendDoNotSell: Bool { get set }
    
    var currentFireButtonAnimation: FireButtonAnimationType { get set }
    var currentAddressBarPosition: AddressBarPosition { get set }
    var showFullSiteAddress: Bool { get set }

    var defaultTextZoomLevel: TextZoomLevel { get set }

    var favoritesDisplayMode: FavoritesDisplayMode { get set }
    
    var autofillCredentialsEnabled: Bool { get set }
    var autofillCredentialsSavePromptShowAtLeastOnce: Bool { get set }
    var autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary: Bool { get set }
    var autofillIsNewInstallForOnByDefault: Bool? { get set }
    func setAutofillIsNewInstallForOnByDefault()
    var autofillImportViaSyncStart: Date? { get set }
    func clearAutofillImportViaSyncStart()

    var voiceSearchEnabled: Bool { get set }

    func isWidgetInstalled() async -> Bool
    
    var autoconsentEnabled: Bool { get set }

    var crashCollectionOptInStatus: CrashCollectionOptInStatus { get set }
    var crashCollectionShouldRevertOptedInStatusTrigger: Int { get set }
    
    var duckPlayerMode: DuckPlayerMode { get set }
    var duckPlayerAskModeOverlayHidden: Bool { get set }
    var duckPlayerOpenInNewTab: Bool { get set }
    var duckPlayerNativeUI: Bool { get set }
    var duckPlayerAutoplay: Bool { get set }
}

protocol AppDebugSettings {
    var onboardingHighlightsEnabled: Bool { get set }
    var onboardingAddToDockState: OnboardingAddToDockState { get set }
}
