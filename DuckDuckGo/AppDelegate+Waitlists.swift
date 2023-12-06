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

extension AppDelegate {

    func checkWaitlists() {
        checkWindowsWaitlist()

#if NETWORK_PROTECTION
        checkNetworkProtectionWaitlist()
#endif
        checkWaitlistBackgroundTasks()

    }

    private func checkWindowsWaitlist() {
        WindowsBrowserWaitlist.shared.fetchInviteCodeIfAvailable { error in
            guard error == nil else { return }
            WindowsBrowserWaitlist.shared.sendInviteCodeAvailableNotification()
        }
    }

#if NETWORK_PROTECTION
    private func checkNetworkProtectionWaitlist() {
        if AppDependencyProvider.shared.featureFlagger.isFeatureOn(.networkProtectionWaitlistAccess) {
            DailyPixel.fire(pixel: .networkProtectionWaitlistUserActive)
        }

        VPNWaitlist.shared.fetchInviteCodeIfAvailable { [weak self] error in
            guard error == nil else {
#if !DEBUG
                // If the user already has an invite code but their auth token has gone missing, attempt to redeem it again.
                let tokenStore = NetworkProtectionKeychainTokenStore()
                let waitlistStorage = VPNWaitlist.shared.waitlistStorage
                if error == .alreadyHasInviteCode,
                   let inviteCode = waitlistStorage.getWaitlistInviteCode(),
                   !tokenStore.isFeatureActivated {
                    self?.fetchVPNWaitlistAuthToken(inviteCode: inviteCode)
                }
#endif
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
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            let hasWindowsBrowserWaitlistTask = tasks.contains { $0.identifier == WindowsBrowserWaitlist.backgroundRefreshTaskIdentifier }
            if !hasWindowsBrowserWaitlistTask {
                WindowsBrowserWaitlist.shared.scheduleBackgroundRefreshTask()
            }

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

                DailyPixel.fire(pixel: .networkProtectionWaitlistNotificationShown)
            } catch {}
        }
    }
#endif

}
