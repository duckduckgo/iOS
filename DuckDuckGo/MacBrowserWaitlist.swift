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
import UserNotifications

enum WaitlistInviteCodeFetchError: Error {
    case alreadyHasInviteCode
    case notOnWaitlist
    case noCodeAvailable
    case failure(Error)
}

struct MacBrowserWaitlist {
    
    static let downloadURL = URL(string: "https://duckduckgo.com/mac")!
    static let downloadURLString: String = {
        downloadURL.absoluteString
    }()
    
    static func settingsSubtitle() -> String {
        let store = MacBrowserWaitlistKeychainStore()
        
        if store.isInvited {
            return "Available for download on Mac"
        } else if store.isOnWaitlist {
            return "You're on the list!"
        } else {
            return "Browse privately with our app for Mac"
        }
    }
    
    static func fetchInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void) {
        let browserWaitlistStorage = MacBrowserWaitlistKeychainStore()
        let waitlistRequest = WaitlistRequest(product: .macBrowser)
        
        guard browserWaitlistStorage.getWaitlistInviteCode() == nil else {
            completion(.alreadyHasInviteCode)
            return
        }

        guard let token = browserWaitlistStorage.getWaitlistToken(), let storedTimestamp = browserWaitlistStorage.getWaitlistTimestamp() else {
            completion(.notOnWaitlist)
            return
        }
        
        waitlistRequest.getWaitlistStatus { statusResult in
            switch statusResult {
            case .success(let statusResponse):
                if statusResponse.timestamp >= storedTimestamp {
                    waitlistRequest.getInviteCode(token: token) { inviteCodeResult in
                        switch inviteCodeResult {
                        case .success(let inviteCode):
                            browserWaitlistStorage.store(inviteCode: inviteCode.code)
                            completion(nil)
                        case .failure(let inviteCodeError):
                            completion(.failure(inviteCodeError))
                        }
                    
                    }
                } else {
                    // If the user is still in the waitlist, no code is available.
                    completion(.noCodeAvailable)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func sendInviteCodeAvailableNotification() {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = UserText.macBrowserWaitlistAvailableNotificationTitle
        notificationContent.body = UserText.macBrowserWaitlistAvailableNotificationBody

        let notificationIdentifier = "com.duckduckgo.ios.mac-browser.invite-code-available"
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

}
