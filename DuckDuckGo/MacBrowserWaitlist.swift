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
import Core
import Waitlist

struct MacBrowserWaitlist: Waitlist {

    let isAvailable: Bool = true

    static let identifier: String = "mac"
    let isWaitlistRemoved: Bool = true
    static let apiProductName: String = "macosbrowser"
    static let downloadURL: URL = URL.mac

    static let shared: MacBrowserWaitlist = .init()

    static let backgroundTaskName = "Mac Browser Waitlist Status Task"
    static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.macBrowserWaitlistStatus"
    static let notificationIdentifier = "com.duckduckgo.ios.mac-browser.invite-code-available"
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

extension WaitlistViewModel.ViewCustomAction {
    static var openWindowsBrowserWaitlist = WaitlistViewModel.ViewCustomAction(identifier: "openWindowsBrowserWaitlist")
}
