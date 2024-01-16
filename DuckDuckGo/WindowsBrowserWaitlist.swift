//
//  WindowsBrowserWaitlist.swift
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

final class WindowsBrowserWaitlist: Waitlist {
    static let identifier: String = "windows"
    static let apiProductName: String = "windowsbrowser"
    static let downloadURL: URL = URL.windows

    static let shared: WindowsBrowserWaitlist = .init()

    static let backgroundTaskName = "Windows Browser Waitlist Status Task"
    static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.windowsBrowserWaitlistStatus"
    static let notificationIdentifier = "com.duckduckgo.ios.windows-browser.invite-code-available"
    static let inviteAvailableNotificationTitle = UserText.windowsWaitlistAvailableNotificationTitle
    static let inviteAvailableNotificationBody = UserText.waitlistAvailableNotificationBody

    var isAvailable: Bool {
        isFeatureEnabled
    }

    var isWaitlistRemoved: Bool = false
    let waitlistStorage: WaitlistStorage
    let waitlistRequest: WaitlistRequest

    init(store: WaitlistStorage, request: WaitlistRequest, privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.waitlistStorage = store
        self.waitlistRequest = request

        isFeatureEnabled = privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .windowsWaitlist)
        isWaitlistRemoved = privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .windowsDownloadLink)

        isFeatureEnabledCancellable = privacyConfigurationManager.updatesPublisher
            .map { [weak privacyConfigurationManager] in
                privacyConfigurationManager?.privacyConfig.isEnabled(featureKey: .windowsWaitlist) == true
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFeatureEnabled, onWeaklyHeld: self)

        isWaitlistRemovedCancellable = privacyConfigurationManager.updatesPublisher
            .map { [weak privacyConfigurationManager] in
                privacyConfigurationManager?.privacyConfig.isEnabled(featureKey: .windowsDownloadLink) == true
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isWaitlistRemoved, onWeaklyHeld: self)
    }

    convenience init(store: WaitlistStorage, request: WaitlistRequest) {
        self.init(store: store, request: request, privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager)
    }

    var settingsSubtitle: String {
        if isWaitlistRemoved {
            return UserText.windowsWaitlistBrowsePrivately
        }
        
        if waitlistStorage.isInvited {
            return UserText.waitlistDownloadAvailable
        }
        
        if waitlistStorage.isOnWaitlist {
            return UserText.waitlistOnTheList
        }
        
        return UserText.windowsWaitlistBrowsePrivately
    }

    // MARK: -

    private var isFeatureEnabled: Bool = false
    private var modeCancellable: AnyCancellable?
    private var isFeatureEnabledCancellable: AnyCancellable?
    private var isWaitlistRemovedCancellable: AnyCancellable?
}

extension WaitlistViewModel.ViewCustomAction {
    static var openMacBrowserWaitlist = WaitlistViewModel.ViewCustomAction(identifier: "openMacBrowserWaitlist")
}
