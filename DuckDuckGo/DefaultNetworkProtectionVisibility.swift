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

#if NETWORK_PROTECTION

import Foundation
import BrowserServicesKit
import Waitlist
import NetworkProtection
import Core
import Subscription

struct DefaultNetworkProtectionVisibility: NetworkProtectionFeatureVisibility {
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let networkProtectionTokenStore: NetworkProtectionTokenStore
    private let networkProtectionAccessManager: NetworkProtectionAccess
    private let featureFlagger: FeatureFlagger
    private let userDefaults: UserDefaults
    private let accountManager: AccountManaging

    init(privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         networkProtectionTokenStore: NetworkProtectionTokenStore,
         networkProtectionAccessManager: NetworkProtectionAccess,
         featureFlagger: FeatureFlagger,
         userDefaults: UserDefaults = .networkProtectionGroupDefaults,
         accountManager: AccountManaging) {

        self.privacyConfigurationManager = privacyConfigurationManager
        self.networkProtectionTokenStore = networkProtectionTokenStore
        self.networkProtectionAccessManager = networkProtectionAccessManager
        self.featureFlagger = featureFlagger
        self.userDefaults = userDefaults
        self.accountManager = accountManager
    }

    var token: String? {
        if shouldMonitorEntitlement() {
            return accountManager.accessToken
        }
        return nil
    }

    func isPrivacyProLaunched() -> Bool {
        if let subscriptionOverrideEnabled = userDefaults.subscriptionOverrideEnabled {
#if ALPHA || DEBUG
            return subscriptionOverrideEnabled
#else
            return false
#endif
        }

        return AppDependencyProvider.shared.subscriptionFeatureAvailability.isFeatureAvailable
    }
    
    func shouldMonitorEntitlement() -> Bool {
        isPrivacyProLaunched()
    }

    func shouldShowThankYouMessaging() -> Bool {
        isPrivacyProLaunched() && isWaitlistUser()
    }

    func shouldKeepVPNAccessViaWaitlist() -> Bool {
        !isPrivacyProLaunched() && isWaitlistBetaActive() && isWaitlistUser()
    }

    func shouldShowVPNShortcut() -> Bool {
        if isPrivacyProLaunched() {
            return accountManager.isUserAuthenticated
        } else {
            return shouldKeepVPNAccessViaWaitlist()
        }
    }
}

#endif
