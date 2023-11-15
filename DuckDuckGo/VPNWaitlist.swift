//
//  VPNWaitlist.swift
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

import Foundation
import BrowserServicesKit
import Combine
import Core
import Waitlist
import NetworkProtection

final class VPNWaitlist: Waitlist {

    enum AccessType {
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

    static let identifier: String = "vpn"
    static let apiProductName: String = "networkprotection_ios"
    static let downloadURL: URL = URL.windows

    static let shared: VPNWaitlist = .init()

    static let backgroundTaskName = "VPN Waitlist Status Task"
    static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.vpnWaitlistStatus"
    static let notificationIdentifier = "com.duckduckgo.ios.vpn.invite-code-available"
    static let inviteAvailableNotificationTitle = UserText.networkProtectionWaitlistNotificationTitle
    static let inviteAvailableNotificationBody = UserText.networkProtectionWaitlistNotificationText

    var isAvailable: Bool {
        isFeatureEnabled
    }

    var isWaitlistRemoved: Bool {
        return false
    }

    @UserDefaultsWrapper(key: .networkProtectionWaitlistTermsAndConditionsAccepted, defaultValue: false)
    static var termsAndConditionsAccepted: Bool

    var networkProtectionAccessType: AccessType {
        let authTokenStore = NetworkProtectionKeychainTokenStore()

        // First, check for users who have activated the VPN via an invite code:
        if authTokenStore.isFeatureActivated && !waitlistStorage.isInvited {
            return .inviteCodeInvited
        }

        // Next, check if the waitlist is still active; if not, the user has no access.
        let isWaitlistActive = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(NetworkProtectionSubfeature.waitlistBetaActive)
        if !isWaitlistActive {
            return .none
        }

        // Next, check if a waitlist user has NetP access and whether they need to accept T&C.
        if authTokenStore.isFeatureActivated && waitlistStorage.isInvited {
            if Self.termsAndConditionsAccepted {
                return .waitlistInvited
            } else {
                return .waitlistInvitedPendingTermsAcceptance
            }
        }

        // Next, check if the user has waitlist access at all and whether they've already joined.
        let hasWaitlistAccess = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(NetworkProtectionSubfeature.waitlist)
        if hasWaitlistAccess {
            if waitlistStorage.isOnWaitlist {
                return .waitlistJoined
            } else {
                return .waitlistAvailable
            }
        }

        return .none
    }

    let waitlistStorage: WaitlistStorage
    let waitlistRequest: WaitlistRequest
    private let privacyConfigurationManager: PrivacyConfigurationManaging

    init(store: WaitlistStorage,
         request: WaitlistRequest,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.waitlistStorage = store
        self.waitlistRequest = request
        self.privacyConfigurationManager = privacyConfigurationManager

        let hasWaitlistAccess = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(NetworkProtectionSubfeature.waitlist)
        let isWaitlistActive = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(NetworkProtectionSubfeature.waitlistBetaActive)
        isFeatureEnabled = hasWaitlistAccess && isWaitlistActive
    }

    convenience init(store: WaitlistStorage, request: WaitlistRequest) {
        self.init(store: store, request: request, privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager)
    }

    var settingsSubtitle: String {
        if waitlistStorage.isInvited {
            return "Invited"
        }

        if waitlistStorage.isOnWaitlist {
            return "On waitlist"
        }

        // TODO
        return "Default text"
    }

    // MARK: -

    private var isFeatureEnabled: Bool = false
    private var modeCancellable: AnyCancellable?
    private var isFeatureEnabledCancellable: AnyCancellable?
    private var isWaitlistRemovedCancellable: AnyCancellable?

}

extension WaitlistViewModel.ViewCustomState {
    static var networkProtectionPrivacyPolicyScreen = WaitlistViewModel.ViewCustomState(identifier: "networkProtectionPrivacyPolicyScreen")
}

extension WaitlistViewModel.ViewCustomAction {
    static var openNetworkProtectionInviteCodeScreen = WaitlistViewModel.ViewCustomAction(identifier: "openNetworkProtectionInviteCodeScreen")
    static var openNetworkProtectionPrivacyPolicyScreen = WaitlistViewModel.ViewCustomAction(identifier: "openNetworkProtectionPrivacyPolicyScreen")
    static var acceptNetworkProtectionTerms = WaitlistViewModel.ViewCustomAction(identifier: "acceptNetworkProtectionTerms")
}
