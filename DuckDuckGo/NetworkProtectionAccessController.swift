//
//  NetworkProtectionAccessController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import ContentBlocking
import Core
import NetworkProtection
import Waitlist

enum NetworkProtectionAccessType {
    /// Used if the user does not have waitlist feature flag access
    case none

    /// Used if the user has waitlist feature flag access, but has not joined the waitlist
    case waitlistAvailable

    /// Used if the user has waitlist feature flag access, and has joined the waitlist
    case waitlistJoined

    /// Used if the user has been invited via the waitlist, but needs to accept the Privacy Policy and Terms of Service
    case waitlistInvitedPendingTermsAcceptance

    /// Used if the user has been invited via the waitlist and has accepted the Privacy Policy and Terms of Service
    case waitlistInvited

    /// Used if the user has been invited to test Network Protection directly
    case inviteCodeInvited
}

protocol NetworkProtectionAccess {
    func networkProtectionAccessType() -> NetworkProtectionAccessType
}

struct NetworkProtectionAccessController: NetworkProtectionAccess {

    private let networkProtectionActivation: NetworkProtectionFeatureActivation
    private let networkProtectionWaitlistStorage: WaitlistStorage
    private let networkProtectionTermsAndConditionsStore: NetworkProtectionTermsAndConditionsStore
    private let featureFlagger: FeatureFlagger
    private let internalUserDecider: InternalUserDecider

    private var isUserLocaleAllowed: Bool {
        var regionCode: String?

        if #available(iOS 16.0, *) {
            regionCode = Locale.current.region?.identifier
        } else {
            regionCode = Locale.current.regionCode
        }

        return (regionCode ?? "US") == "US"
    }


    init(
        networkProtectionActivation: NetworkProtectionFeatureActivation = NetworkProtectionKeychainTokenStore(),
        networkProtectionWaitlistStorage: WaitlistStorage = WaitlistKeychainStore(waitlistIdentifier: VPNWaitlist.identifier),
        networkProtectionTermsAndConditionsStore: NetworkProtectionTermsAndConditionsStore = NetworkProtectionTermsAndConditionsUserDefaultsStore(),
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
        internalUserDecider: InternalUserDecider = AppDependencyProvider.shared.internalUserDecider
    ) {
        self.networkProtectionActivation = networkProtectionActivation
        self.networkProtectionWaitlistStorage = networkProtectionWaitlistStorage
        self.networkProtectionTermsAndConditionsStore = networkProtectionTermsAndConditionsStore
        self.featureFlagger = featureFlagger
        self.internalUserDecider = internalUserDecider
    }

    func networkProtectionAccessType() -> NetworkProtectionAccessType {
        // Only show NetP to US or internal users:
        guard isUserLocaleAllowed || internalUserDecider.isInternalUser else {
            return .none
        }

        // Check for users who have activated the VPN via an invite code:
        if networkProtectionActivation.isFeatureActivated && !networkProtectionWaitlistStorage.isInvited {
            return .inviteCodeInvited
        }

        // Check if the waitlist is still active; if not, the user has no access.
        let isWaitlistActive = featureFlagger.isFeatureOn(.networkProtectionWaitlistActive)
        if !isWaitlistActive {
            return .none
        }

        // Check if a waitlist user has NetP access and whether they need to accept T&C.
        if networkProtectionActivation.isFeatureActivated && networkProtectionWaitlistStorage.isInvited {
            if networkProtectionTermsAndConditionsStore.networkProtectionWaitlistTermsAndConditionsAccepted {
                return .waitlistInvited
            } else {
                return .waitlistInvitedPendingTermsAcceptance
            }
        }

        // Check if the user has waitlist access at all and whether they've already joined.
        let hasWaitlistAccess = featureFlagger.isFeatureOn(.networkProtectionWaitlistAccess)
        if hasWaitlistAccess {
            if networkProtectionWaitlistStorage.isOnWaitlist {
                return .waitlistJoined
            } else {
                return .waitlistAvailable
            }
        }

        return .none
    }

    func refreshNetworkProtectionAccess() {
        guard networkProtectionActivation.isFeatureActivated else {
            return
        }

        if !featureFlagger.isFeatureOn(.networkProtectionWaitlistActive) {
            networkProtectionWaitlistStorage.deleteWaitlistState()
            try? NetworkProtectionKeychainTokenStore().deleteToken()

            Task {
                let controller = NetworkProtectionTunnelController()
                await controller.stop()
                await controller.removeVPN()
            }
        }
    }

}

#endif
