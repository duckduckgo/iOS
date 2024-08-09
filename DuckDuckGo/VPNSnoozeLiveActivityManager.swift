//
//  VPNSnoozeLiveActivityManager.swift
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
import ActivityKit
import NetworkProtection

@available(iOS 17.0, *)
final class VPNSnoozeLiveActivityManager: ObservableObject {

    private let snoozeTimingStore: NetworkProtectionSnoozeTimingStore

    init(snoozeTimingStore: NetworkProtectionSnoozeTimingStore = .init(userDefaults: .networkProtectionGroupDefaults)) {
        self.snoozeTimingStore = snoozeTimingStore
    }

    func start(endDate: Date) async {
        await endSnoozeActivity()
        await startNewLiveActivity(endDate: endDate)
    }

    private func startNewLiveActivity(endDate: Date) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, Activity<VPNSnoozeActivityAttributes>.activities.isEmpty else {
            return
        }

        let attributes = VPNSnoozeActivityAttributes(endDate: endDate)
        let initialContentState = ActivityContent(
            state: VPNSnoozeActivityAttributes.ContentState(endDate: endDate),
            staleDate: endDate
        )

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: initialContentState
            )
        } catch {
            // The only possible error is when the user has disabled Live Activities for the app, which is not given any special handling
        }
    }

    func endSnoozeActivityIfNecessary() async {
        if !snoozeTimingStore.isSnoozing {
            await endSnoozeActivity()
        }
    }

    func endSnoozeActivity() async {
        for activity in Activity<VPNSnoozeActivityAttributes>.activities {
            let initialContentState = VPNSnoozeActivityAttributes.ContentState(endDate: Date())
            await activity.end(ActivityContent(state: initialContentState, staleDate: Date()), dismissalPolicy: .immediate)
        }
    }

}
