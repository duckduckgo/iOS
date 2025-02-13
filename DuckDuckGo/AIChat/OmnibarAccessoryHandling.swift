//
//  OmnibarAccessoryHandling.swift
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
import AIChat
import BrowserServicesKit

protocol OmnibarAccessoryHandling {
    func omnibarAccessory(for url: URL?) -> OmniBar.AccessoryType
}

struct OmnibarAccessoryHandler: OmnibarAccessoryHandling {
    let settings: AIChatSettingsProvider
    let featureFlagger: FeatureFlagger

    func omnibarAccessory(for url: URL?) -> OmniBar.AccessoryType {
        guard settings.isAIChatFeatureEnabled,
              settings.isAIChatAddressBarUserSettingsEnabled else {
            return .share
        }

        if featureFlagger.isFeatureOn(.aiChatNewTabPage) {
            return (url?.isDuckDuckGoSearch == false) ? .share : .chat
        }

        return (url?.isDuckDuckGoSearch == true) ? .chat : .share
    }
}
