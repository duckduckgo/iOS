//
//  MacBrowserWaitlistViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class DeprecatedWaitlisViewModel {
    
    enum WaitlistState {
        case notJoinedQueue
        case joinedQueue
        case inBeta
    }
    
    enum WaitlistInviteCodeFetchError: Error {
        case alreadyHasInviteCode
        case notOnWaitlist
        case noCodeAvailable
        case failure(Error)
    }
    
    static var shared = DeprecatedWaitlisViewModel()
    
    static func sendInviteCodeAvailableNotification() {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = UserText.macBrowserWaitlistAvailableNotificationTitle
        notificationContent.body = UserText.macBrowserWaitlistAvailableNotificationBody

        let notificationIdentifier = "com.duckduckgo.ios.mac-browser.invite-code-available"
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

    var waitlistState: WaitlistState {
        if browserWaitlistStorage.getWaitlistTimestamp() != nil, browserWaitlistStorage.getWaitlistInviteCode() == nil {
            return .joinedQueue
        }

        if browserWaitlistStorage.getWaitlistInviteCode() != nil {
            return .inBeta
        }

        return .notJoinedQueue
    }
    
    var inviteCode: String? {
        browserWaitlistStorage.getWaitlistInviteCode()
    }
    
    private let waitlistRequest: WaitlistRequesting
    private let browserWaitlistStorage: MacBrowserWaitlistStorage
    
    init(waitlistRequest: WaitlistRequesting = WaitlistRequest(product: .macBrowser),
         waitlistStorage: MacBrowserWaitlistStorage = MacBrowserWaitlistKeychainStore()) {
        self.waitlistRequest = waitlistRequest
        self.browserWaitlistStorage = waitlistStorage
    }
    
    func joinWaitlist(completion: @escaping WaitlistJoinCompletion) {
        waitlistRequest.joinWaitlist { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let joinResponse):
                self.browserWaitlistStorage.store(waitlistToken: joinResponse.token)
                self.browserWaitlistStorage.store(waitlistTimestamp: joinResponse.timestamp)
                completion(result)
            case .failure(let joinError):
                completion(result)
            }
        }
    }
    
    func getInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void) {
        guard browserWaitlistStorage.getWaitlistInviteCode() == nil else {
            completion(.alreadyHasInviteCode)
            return
        }

        guard let token = browserWaitlistStorage.getWaitlistToken(), let storedTimestamp = browserWaitlistStorage.getWaitlistTimestamp() else {
            completion(.notOnWaitlist)
            return
        }
        
        waitlistRequest.getWaitlistStatus { [weak self] statusResult in
            guard let self = self else { return }

            switch statusResult {
            case .success(let statusResponse):
                if statusResponse.timestamp >= storedTimestamp {
                    self.waitlistRequest.getInviteCode(token: token) { [weak self] inviteCodeResult in
                        guard let self = self else { return }

                        switch inviteCodeResult {
                        case .success(let inviteCode):
                            self.browserWaitlistStorage.store(inviteCode: inviteCode.code)
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
    
}
