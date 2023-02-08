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
import Core
import Waitlist

struct WindowsBrowserWaitlist: Waitlist {
    static let identifier: String = "windows"
    static let isWaitlistRemoved: Bool = false
    static let apiProductName: String = "windowsbrowser"
    static let downloadURL: URL = AppUrls().windowsBrowserDownloadURL

    static let shared: WindowsBrowserWaitlist = .init()

    static let backgroundTaskName = "Windows Browser Waitlist Status Task"
    static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.windowsBrowserWaitlistStatus"
    static let notificationIdentitier = "com.duckduckgo.ios.windows-browser.invite-code-available"
    static let inviteAvailableNotificationTitle = UserText.windowsWaitlistAvailableNotificationTitle
    static let inviteAvailableNotificationBody = UserText.waitlistAvailableNotificationBody

    let waitlistStorage: WaitlistStorage
    let waitlistRequest: WaitlistRequest

    init(store: WaitlistStorage, request: WaitlistRequest) {
        self.waitlistStorage = store
        self.waitlistRequest = request
    }

    var settingsSubtitle: String {
        if Self.isWaitlistRemoved {
            return UserText.windowsWaitlistBrowsePrivately
        }
        
        if waitlistStorage.isInvited {
            return UserText.waitlistAvailableForDownload
        }
        
        if waitlistStorage.isOnWaitlist {
            return UserText.waitlistOnTheList
        }
        
        return UserText.windowsWaitlistBrowsePrivately
    }
}
