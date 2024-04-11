//
//  AppDelegate+Waitlists.swift
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
import Core
import BackgroundTasks
import NetworkProtection
import Waitlist
import BrowserServicesKit

extension AppDelegate {

    func clearDebugWaitlistState() {
        if let inviteCode = VPNWaitlist.shared.waitlistStorage.getWaitlistInviteCode(),
           inviteCode == VPNWaitlistDebugViewController.Constants.mockInviteCode {
            let store = WaitlistKeychainStore(waitlistIdentifier: VPNWaitlist.identifier)
            store.delete(field: .inviteCode)
        }
    }

    func checkWaitlists() {

#if NETWORK_PROTECTION
        if vpnFeatureVisibility.shouldKeepVPNAccessViaWaitlist() {
            checkNetworkProtectionWaitlist()
        }
#endif
    }

#if NETWORK_PROTECTION
    private func checkNetworkProtectionWaitlist() {
        let accessController = NetworkProtectionAccessController()

        VPNWaitlist.shared.fetchInviteCodeIfAvailable { [weak self] error in
            guard error == nil else {
                return
            }

            guard let inviteCode = VPNWaitlist.shared.waitlistStorage.getWaitlistInviteCode() else {
                return
            }

            self?.fetchVPNWaitlistAuthToken(inviteCode: inviteCode)
        }
    }
#endif

#if NETWORK_PROTECTION
    func fetchVPNWaitlistAuthToken(inviteCode: String) {
        Task {
            do {
                try await NetworkProtectionCodeRedemptionCoordinator().redeem(inviteCode)
                VPNWaitlist.shared.sendInviteCodeAvailableNotification()
            } catch {}
        }
    }
#endif

}
