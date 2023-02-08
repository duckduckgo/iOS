//
//  MacBrowserWaitlist.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Waitlist

struct MacBrowserWaitlist: WaitlistHandling {
    static let feature: WaitlistFeature = MacBrowserWaitlistFeature()

    static let shared: MacBrowserWaitlist = .init()

    static let isWaitlistRemoved = true

    static let backgroundTaskName = "Mac Browser Waitlist Status Task"
    static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.macBrowserWaitlistStatus"
    static let notificationIdentitier = "com.duckduckgo.ios.mac-browser.invite-code-available"
    static let inviteAvailableNotificationTitle = UserText.macWaitlistAvailableNotificationTitle
    static let inviteAvailableNotificationBody = UserText.waitlistAvailableNotificationBody

    let settingsSubtitle: String = UserText.macWaitlistBrowsePrivately

    let waitlistStorage: WaitlistStorage
    let waitlistRequest: WaitlistRequest

    init(store: WaitlistStorage, request: WaitlistRequest) {
        self.waitlistStorage = store
        self.waitlistRequest = request
    }
}
