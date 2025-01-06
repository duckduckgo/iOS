//
//  TokenBackgroundRefreshTask.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import BackgroundTasks
import Subscription
import Core

class TokenBackgroundRefreshTask {

    private let taskName = "Refresh authentication token"
    private let taskIdentifier = "com.duckduckgo.app.backgroundTokenRefresh"
    private let minimumConfigurationRefreshInterval: TimeInterval = TimeInterval.days(7)
    private let subscriptionManager: SubscriptionManager

    init(subscriptionManager: SubscriptionManager) {
        self.subscriptionManager = subscriptionManager
    }

    func registerBackgroundRefreshTaskHandler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { [weak self] task in

            guard let self else {
                Logger.subscription.fault("Failed to refresh token, self is nil")
                task.setTaskCompleted(success: false)
                return
            }

            guard self.subscriptionManager.isUserAuthenticated else {
                task.setTaskCompleted(success: true)
                self.scheduleTask()
                return
            }

            self.handle(task: task)
        }
    }

    func handle(task: BGTask) {
        Logger.subscription.log("Token background refresh task started")

        scheduleTask()

        let refreshStartDate = Date()
        task.expirationHandler = {
            Logger.subscription.error("Background refresh task expired")
            task.setTaskCompleted(success: false)
        }

        Task {  [weak self] in
            guard let self else {
                Logger.subscription.fault("Failed to refresh token, self is nil")
                task.setTaskCompleted(success: false)
                return
            }
            do {
                try await self.subscriptionManager.getTokenContainer(policy: .localForceRefresh)
                Logger.subscription.log("Token background refresh task completed successfully in \(Date().timeIntervalSince(refreshStartDate)) seconds")
                task.setTaskCompleted(success: true)
            } catch {
                Logger.subscription.error("Failed to refresh token: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }

    func scheduleTask() {
        let task = BGProcessingTaskRequest(identifier: taskIdentifier)
        task.requiresNetworkConnectivity = true
        task.earliestBeginDate = Date(timeIntervalSinceNow: minimumConfigurationRefreshInterval)

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.backgroundTokenRefresh"]
        //
        // Task expiration can be simulated similarly:
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.duckduckgo.app.backgroundTokenRefresh"]

        #if !targetEnvironment(simulator)
        do {
            try BGTaskScheduler.shared.submit(task)
            Logger.subscription.debug("Token background refresh task scheduled")
        } catch {
            Logger.subscription.error("Failed to schedule token background refresh task: \(error)")
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
        #endif
    }
}
