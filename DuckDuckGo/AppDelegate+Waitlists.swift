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
        checkWaitlistBackgroundTasks()

    }

#if NETWORK_PROTECTION
    private func checkNetworkProtectionWaitlist() {
        let accessController = NetworkProtectionAccessController()
        if accessController.isPotentialOrCurrentWaitlistUser {
            DailyPixel.fire(pixel: .networkProtectionWaitlistUserActive)
        }

        VPNWaitlist.shared.fetchInviteCodeIfAvailable { [weak self] error in
            guard error == nil else {

                if error == .alreadyHasInviteCode, UIApplication.shared.applicationState == .active {
                    // If the user already has an invite code but their auth token has gone missing, attempt to redeem it again.
                    let tokenStore = NetworkProtectionKeychainTokenStore()
                    let waitlistStorage = VPNWaitlist.shared.waitlistStorage
                    let configManager = ContentBlocking.shared.privacyConfigurationManager
                    let waitlistBetaActive = configManager.privacyConfig.isSubfeatureEnabled(NetworkProtectionSubfeature.waitlistBetaActive)

                    if let inviteCode = waitlistStorage.getWaitlistInviteCode(),
                       !tokenStore.isFeatureActivated,
                       waitlistBetaActive {
                        let pixel: Pixel.Event = .networkProtectionWaitlistRetriedInviteCodeRedemption

                        do {
                            if let token = try tokenStore.fetchToken() {
                                DailyPixel.fireDailyAndCount(pixel: pixel, withAdditionalParameters: [ "tokenState": "found" ])
                            } else {
                                DailyPixel.fireDailyAndCount(pixel: pixel, withAdditionalParameters: [ "tokenState": "nil" ])
                            }
                        } catch {
                            DailyPixel.fireDailyAndCount(pixel: pixel, error: error, withAdditionalParameters: [ "tokenState": "error" ])
                        }

                        self?.fetchVPNWaitlistAuthToken(inviteCode: inviteCode)
                    }
                }

                return

            }

            guard let inviteCode = VPNWaitlist.shared.waitlistStorage.getWaitlistInviteCode() else {
                return
            }

            self?.fetchVPNWaitlistAuthToken(inviteCode: inviteCode)
        }
    }
#endif

    private func checkWaitlistBackgroundTasks() {
        guard vpnFeatureVisibility.shouldKeepVPNAccessViaWaitlist() else { return }

        BGTaskScheduler.shared.getPendingTaskRequests { tasks in

#if NETWORK_PROTECTION
            let hasVPNWaitlistTask = tasks.contains { $0.identifier == VPNWaitlist.backgroundRefreshTaskIdentifier }
            if !hasVPNWaitlistTask {
                VPNWaitlist.shared.scheduleBackgroundRefreshTask()
            }
#endif
        }
    }

#if NETWORK_PROTECTION
    func fetchVPNWaitlistAuthToken(inviteCode: String) {
        Task {
            do {
                try await NetworkProtectionCodeRedemptionCoordinator().redeem(inviteCode)
                VPNWaitlist.shared.sendInviteCodeAvailableNotification()

                DailyPixel.fireDailyAndCount(pixel: .networkProtectionWaitlistNotificationShown)
            } catch {}
        }
    }
#endif

}
