//
//  EmailWaitlist.swift
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
import Core
import BackgroundTasks
import BrowserServicesKit

private class EmailWaitlistRequestDelegate: EmailManagerRequestDelegate {

    static var shared = EmailWaitlistRequestDelegate()

    // swiftlint:disable function_parameter_count
    func emailManager(_ emailManager: EmailManager,
                      requested url: URL,
                      method: String,
                      headers: [String: String],
                      parameters: [String: String]?,
                      httpBody: Data?,
                      timeoutInterval: TimeInterval,
                      completion: @escaping (Data?, Error?) -> Void) {
        APIRequest.request(url: url,
                           method: APIRequest.HTTPMethod(rawValue: method) ?? .post,
                           parameters: parameters,
                           headers: headers,
                           httpBody: httpBody,
                           timeoutInterval: timeoutInterval) { response, error in

            completion(response?.data, error)
        }
    }
    // swiftlint:enable function_parameter_count

}

struct EmailWaitlist {

    struct Constants {
        static let backgroundTaskName = "Waitlist Status Task"
        static let backgroundRefreshTaskIdentifier = "com.duckduckgo.app.waitlistStatus"
        static let minimumConfigurationRefreshInterval: TimeInterval = 60 * 60 * 12
    }

    static var shared = EmailWaitlist()

    let emailManager: EmailManager = {
        let emailManager = EmailManager()
        emailManager.requestDelegate = EmailWaitlistRequestDelegate.shared
        return emailManager
    }()

    /// This is a permission granted by the user when enrolling in the email waitlist. It is used to determine whether to schedule the background task.
    @UserDefaultsWrapper(key: .showWaitlistNotification, defaultValue: false)
    var showWaitlistNotification: Bool

    func registerBackgroundRefreshTaskHandler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundRefreshTaskIdentifier, using: nil) { task in
            // FIXME: Send the notification every time the task fires, used to determine how often this task runs.
            sendInviteCodeAvailableNotification()

            let emailManager = EmailManager()
            emailManager.requestDelegate = EmailWaitlistRequestDelegate.shared

            guard emailManager.isInWaitlist else {
                task.setTaskCompleted(success: true)
                return
            }

            emailManager.fetchInviteCodeIfAvailable { result in
                switch result {
                case .success:
                    sendInviteCodeAvailableNotification()
                    task.setTaskCompleted(success: true)
                case .failure:
                    scheduleBackgroundRefreshTask()

                    // Though no code was retrieved, failure is still an expected outcome and considered a success from the point of view of the task.
                    task.setTaskCompleted(success: true)
                }
            }
        }
    }

    func scheduleBackgroundRefreshTask() {
        guard emailManager.isInWaitlist else {
            return
        }

        let task = BGAppRefreshTaskRequest(identifier: Constants.backgroundRefreshTaskIdentifier)
        task.earliestBeginDate = nil // TODO: Set 12 hour delay, using nil for testing purposes.

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
        guard showWaitlistNotification else { return }

        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = UserText.emailWaitlistAvailableNotificationTitle
        notificationContent.body = UserText.emailWaitlistAvailableNotificationBody

        let notificationIdentifier = "com.duckduckgo.ios.waitlist-available"
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

}
