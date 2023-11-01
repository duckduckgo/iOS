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

final class VPNWaitlist: Waitlist {

    static let identifier: String = "vpn"
    static let apiProductName: String = "networkprotection_ios"
    static let downloadURL: URL = URL.windows

    static let shared: VPNWaitlist = .init()

    static let backgroundTaskName = "VPN Waitlist Status Task"
    static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.vpnWaitlistStatus"
    static let notificationIdentifier = "com.duckduckgo.ios.vpn.invite-code-available"
    static let inviteAvailableNotificationTitle = UserText.windowsWaitlistAvailableNotificationTitle
    static let inviteAvailableNotificationBody = UserText.waitlistAvailableNotificationBody

    var isAvailable: Bool {
        isFeatureEnabled
    }

    var isWaitlistRemoved: Bool {
        return false
    }

    let waitlistStorage: WaitlistStorage
    let waitlistRequest: WaitlistRequest

    init(store: WaitlistStorage,
         request: WaitlistRequest,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.waitlistStorage = store
        self.waitlistRequest = request

        isFeatureEnabled = true // privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .windowsWaitlist)

//        isFeatureEnabledCancellable = privacyConfigurationManager.updatesPublisher
//            .map { [weak privacyConfigurationManager] in
//                privacyConfigurationManager?.privacyConfig.isEnabled(featureKey: .windowsWaitlist) == true
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.isFeatureEnabled, onWeaklyHeld: self)
//
//        isWaitlistRemovedCancellable = privacyConfigurationManager.updatesPublisher
//            .map { [weak privacyConfigurationManager] in
//                privacyConfigurationManager?.privacyConfig.isEnabled(featureKey: .windowsDownloadLink) == true
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.isWaitlistRemoved, onWeaklyHeld: self)
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

        return "Default text"
    }

    // MARK: -

    private var isFeatureEnabled: Bool = false
    private var modeCancellable: AnyCancellable?
    private var isFeatureEnabledCancellable: AnyCancellable?
    private var isWaitlistRemovedCancellable: AnyCancellable?

}
