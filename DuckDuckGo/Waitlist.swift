//
//  Waitlist.swift
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
import UserNotifications
import BackgroundTasks
import os

enum WaitlistFeature: String {
    case macBrowser = "mac"
    case windowsBrowser = "windows"

    var isWaitlistRemoved: Bool {
        switch self {
        case .macBrowser:
            return true
        default:
            return false
        }
    }

    var apiProductName: String {
        switch self {
        case .macBrowser:
            return "macosbrowser"
        case .windowsBrowser:
            return "windowsbrowser"
        }
    }
}

protocol WaitlistConstantsProviding {
    static var feature: WaitlistFeature { get }

    static var backgroundTaskName: String { get }
    static var backgroundRefreshTaskIdentifier: String { get }
    static var minimumConfigurationRefreshInterval: TimeInterval { get }

    static var notificationIdentitier: String { get }
    static var notificationNameInviteCodeChanged: Notification.Name { get }
    static var inviteAvailableNotificationTitle: String { get }
    static var inviteAvailableNotificationBody: String { get }
}

protocol WaitlistHandling: WaitlistConstantsProviding {

    static var shared: Self { get }

    var waitlistStorage: WaitlistStorage { get }
    var waitlistRequest: WaitlistRequest { get }

    init(store: WaitlistStorage, request: WaitlistRequest)

    var settingsSubtitle: String { get }

    func fetchInviteCodeIfAvailable() async -> WaitlistInviteCodeFetchError?
    func fetchInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void)
    func registerBackgroundRefreshTaskHandler()
    func scheduleBackgroundRefreshTask()
    func sendInviteCodeAvailableNotification()
}

extension WaitlistHandling {

    init() {
        self.init(store: WaitlistKeychainStore(feature: Self.feature), request: ProductWaitlistRequest(feature: Self.feature))
    }

    func fetchInviteCodeIfAvailable() async -> WaitlistInviteCodeFetchError? {
        await withCheckedContinuation { continuation in
            fetchInviteCodeIfAvailable { error in
                continuation.resume(returning: error)
            }
        }
    }

    func fetchInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void) {
        guard waitlistStorage.getWaitlistInviteCode() == nil else {
            completion(.alreadyHasInviteCode)
            return
        }

        guard let token = waitlistStorage.getWaitlistToken(), let storedTimestamp = waitlistStorage.getWaitlistTimestamp() else {
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
                            waitlistStorage.store(inviteCode: inviteCode.code)
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

    func registerBackgroundRefreshTaskHandler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundRefreshTaskIdentifier, using: nil) { task in
            let waitlist = Self.shared

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
        guard waitlistStorage.isOnWaitlist else {
            return
        }

        let task = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshTaskIdentifier)
        task.earliestBeginDate = Date(timeIntervalSinceNow: Self.minimumConfigurationRefreshInterval)

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
        } catch {
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
        #endif
    }

    func sendInviteCodeAvailableNotification() {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = Self.inviteAvailableNotificationTitle
        notificationContent.body = Self.inviteAvailableNotificationBody

        let notificationIdentifier = Self.notificationIdentitier
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

}

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
