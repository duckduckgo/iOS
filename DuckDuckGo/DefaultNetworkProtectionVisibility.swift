//
//  DefaultNetworkProtectionVisibility.swift
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
import BrowserServicesKit
import Waitlist
import NetworkProtection
import Core
import Subscription
import Networking

struct DefaultNetworkProtectionVisibility: NetworkProtectionFeatureVisibility {
    private let userDefaults: UserDefaults
    private let oAuthClient: any OAuthClient

    init(userDefaults: UserDefaults, oAuthClient: any OAuthClient) {
        self.userDefaults = userDefaults
        self.oAuthClient = oAuthClient
    }

    var token: String? {
        return oAuthClient.currentTokensContainer?.accessToken
    }

    func shouldShowVPNShortcut() -> Bool {
        oAuthClient.isUserAuthenticated
    }
}
