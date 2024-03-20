//
//  NetworkProtectionVisibilityForTunnelProvider.swift
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

#if SUBSCRIPTION
import Subscription
#endif

struct NetworkProtectionVisibilityForTunnelProvider: NetworkProtectionFeatureVisibility {
    func isWaitlistBetaActive() -> Bool {
        preconditionFailure("Does not apply to Tunnel Provider")
    }

    func isWaitlistUser() -> Bool {
        preconditionFailure("Does not apply to Tunnel Provider")
    }
    
    // todo - https://app.asana.com/0/0/1206844038943626/f
    func isPrivacyProLaunched() -> Bool {
#if SUBSCRIPTION
        let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)
        let tokenStore = SubscriptionTokenKeychainStorage(keychainType: .dataProtection(.named(subscriptionAppGroup)))
        return tokenStore.accessToken != nil
#else
        false
#endif
    }
    
    // todo - https://app.asana.com/0/0/1206844038943626/f
    func shouldMonitorEntitlement() -> Bool {
        isPrivacyProLaunched()
    }
}

#endif
