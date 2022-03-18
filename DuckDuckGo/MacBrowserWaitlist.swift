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
import UserNotifications
import BackgroundTasks
import os

enum WaitlistInviteCodeFetchError: Error, Equatable {
    case alreadyHasInviteCode
    case notOnWaitlist
    case noCodeAvailable
    case failure(Error)
    
    static func == (lhs: WaitlistInviteCodeFetchError, rhs: WaitlistInviteCodeFetchError) -> Bool {
        switch (lhs, rhs) {
        case (.alreadyHasInviteCode, .alreadyHasInviteCode): return true
        case (.notOnWaitlist, .notOnWaitlist): return true
        case (.noCodeAvailable, .noCodeAvailable): return true
        default: return false
        }
    }
}

struct MacBrowserWaitlist {
    
    struct Constants {
        static let backgroundTaskName = "Mac Browser Waitlist Status Task"
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.macBrowserWaitlistStatus"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 12
    }
    
    static var shared = MacBrowserWaitlist()
    
    private let waitlistStorage: MacBrowserWaitlistStorage
    private let waitlistRequest: WaitlistRequest

    init(store: MacBrowserWaitlistStorage = MacBrowserWaitlistKeychainStore(),
         request: WaitlistRequest = ProductWaitlistRequest(product: .macBrowser)) {
        self.waitlistStorage = store
        self.waitlistRequest = request
    }
    
    func settingsSubtitle() -> String {
        if waitlistStorage.isInvited {
            return UserText.macWaitlistAvailableForDownload
        } else if waitlistStorage.isOnWaitlist {
            return UserText.macWaitlistSettingsOnTheList
        } else {
            return UserText.macWaitlistBrowsePrivately
        }
    }
    
    func fetchInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void) {
        let waitlistRequest = ProductWaitlistRequest(product: .macBrowser)
        
        guard waitlistStorage.getWaitlistInviteCode() == nil else {
            completion(.alreadyHasInviteCode)
            return
        }

        guard let token = waitlistStorage.getWaitlistToken(), let storedTimestamp = waitlistStorage.getWaitlistTimestamp() else {
            completion(.notOnWaitlist)
            return
        }
        
        MacBrowserWaitlist.log("Attempting to fetch invite code")
        
        waitlistRequest.getWaitlistStatus { statusResult in
            switch statusResult {
            case .success(let statusResponse):
                if statusResponse.timestamp >= storedTimestamp {
                    waitlistRequest.getInviteCode(token: token) { inviteCodeResult in
                        switch inviteCodeResult {
                        case .success(let inviteCode):
                            MacBrowserWaitlist.log("Got valid invite code")
                            waitlistStorage.store(inviteCode: inviteCode.code)
                            completion(nil)
                        case .failure(let inviteCodeError):
                            MacBrowserWaitlist.log("Error fetching invite code")
                            completion(.failure(inviteCodeError))
                        }
                    
                    }
                } else {
                    // If the user is still in the waitlist, no code is available.
                    MacBrowserWaitlist.log("No invite code available")
                    completion(.noCodeAvailable)
                }
            case .failure(let error):
                MacBrowserWaitlist.log("Error fetching waitlist status")
                completion(.failure(error))
            }
        }
    }
    
    func registerBackgroundRefreshTaskHandler() {
        MacBrowserWaitlist.log("Registering background refresh task handler")
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            MacBrowserWaitlist.log("Running background task")
            
            let waitlist = MacBrowserWaitlist.shared

            guard waitlist.waitlistStorage.isOnWaitlist else {
                task.setTaskCompleted(success: true)
                return
            }

            waitlist.fetchInviteCodeIfAvailable { error in
                guard error == nil else {
                    task.setTaskCompleted(success: false)

                    if error != .notOnWaitlist {
                        scheduleBackgroundRefreshTask()
                    }

                    return
                }
                
                sendInviteCodeAvailableNotification()
                task.setTaskCompleted(success: true)
            }
        }
    }

    func scheduleBackgroundRefreshTask() {
        guard waitlistStorage.isOnWaitlist, waitlistStorage.shouldReceiveNotifications() else {
            MacBrowserWaitlist.log("Not on the waitlist/notifications disabled - not scheduling new background refresh task")
            return
        }

        let task = BGAppRefreshTaskRequest(identifier: Constants.backgroundRefreshTaskIdentifier)
        task.earliestBeginDate = Date(timeIntervalSinceNow: Constants.minimumConfigurationRefreshInterval)

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.waitlistStatus"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.waitlistStatus"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
            MacBrowserWaitlist.log("Scheduled background task")
        } catch {
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
        #endif
    }
    
    func sendInviteCodeAvailableNotification() {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = UserText.macWaitlistAvailableNotificationTitle
        notificationContent.body = UserText.macWaitlistAvailableNotificationBody

        let notificationIdentifier = "com.duckduckgo.ios.mac-browser.invite-code-available"
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)

        UNUserNotificationCenter.current().add(request)
        
        MacBrowserWaitlist.log("Sent invite code notification")
    }
    
    // MARK: - Logging
    
    static func log(_ message: String) {
#if DEBUG
        if #available(iOS 14.0, *) {
            let waitlistLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier, category: "DDG Waitlist")
            waitlistLogger.log(level: .default, "\(message)")
        } else {
            os_log("%{public}s", log: waitlistLog, type: .debug, message)
        }
#endif
    }

}
