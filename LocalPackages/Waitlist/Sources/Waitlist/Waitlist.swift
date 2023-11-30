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
import UserNotifications
import BackgroundTasks

public protocol WaitlistConstants {
    static var identifier: String { get }
    static var apiProductName: String { get }
    static var downloadURL: URL { get }

    static var backgroundTaskName: String { get }
    static var backgroundRefreshTaskIdentifier: String { get }
    static var minimumConfigurationRefreshInterval: TimeInterval { get }

    static var notificationIdentifier: String { get }
    static var inviteAvailableNotificationTitle: String { get }
    static var inviteAvailableNotificationBody: String { get }
}

public extension WaitlistConstants {
    static var minimumConfigurationRefreshInterval: TimeInterval { 60 * 60 * 12 }
}

public protocol Waitlist: WaitlistConstants {

    static var shared: Self { get }

    var isAvailable: Bool { get }
    var isWaitlistRemoved: Bool { get }

    var waitlistStorage: WaitlistStorage { get }
    var waitlistRequest: WaitlistRequest { get }

    init(store: WaitlistStorage, request: WaitlistRequest)

    var settingsSubtitle: String { get }

    func fetchInviteCodeIfAvailable() async -> WaitlistInviteCodeFetchError?
    func fetchInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void)
    func registerBackgroundRefreshTaskHandler()
    func scheduleBackgroundRefreshTask()
    func sendInviteCodeAvailableNotification()

    var onBackgroundTaskSubmissionError: ((Error) -> Void)? { get }
}

public enum WaitlistInviteCodeFetchError: Error, Equatable {
    case waitlistInactive
    case alreadyHasInviteCode
    case notOnWaitlist
    case noCodeAvailable
    case failure(Error)

    public static func == (lhs: WaitlistInviteCodeFetchError, rhs: WaitlistInviteCodeFetchError) -> Bool {
        switch (lhs, rhs) {
        case (.alreadyHasInviteCode, .alreadyHasInviteCode): return true
        case (.notOnWaitlist, .notOnWaitlist): return true
        case (.noCodeAvailable, .noCodeAvailable): return true
        default: return false
        }
    }
}

public extension Waitlist {

    func fetchInviteCodeIfAvailable() async -> WaitlistInviteCodeFetchError? {
        await withCheckedContinuation { continuation in
            fetchInviteCodeIfAvailable { error in
                continuation.resume(returning: error)
            }
        }
    }

    func fetchInviteCodeIfAvailable(completion: @escaping (WaitlistInviteCodeFetchError?) -> Void) {
        guard isAvailable else {
            completion(.waitlistInactive)
            return
        }
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
        guard isAvailable, waitlistStorage.isOnWaitlist else {
            return
        }

        let task = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshTaskIdentifier)
        task.earliestBeginDate = Date(timeIntervalSinceNow: Self.minimumConfigurationRefreshInterval)

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.windowsBrowserWaitlistStatus"]
        //
        // Task expiration can be simulated similarly:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.windowsBrowserWaitlistStatus"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
        } catch {
            onBackgroundTaskSubmissionError?(error)
        }
        #endif
    }

    func sendInviteCodeAvailableNotification() {
        guard isAvailable else {
            return
        }

        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = Self.inviteAvailableNotificationTitle
        notificationContent.body = Self.inviteAvailableNotificationBody

        let notificationIdentifier = Self.notificationIdentifier
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

}
