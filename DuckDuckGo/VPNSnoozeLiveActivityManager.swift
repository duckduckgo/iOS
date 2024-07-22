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

@available(iOS 17.0, *)
final class VPNSnoozeLiveActivityManager: ObservableObject {
    static let shared = VPNSnoozeLiveActivityManager()

    func start(endDate: Date) async {
        await cancelAllRunningActivities()
        await startNewLiveActivity(endDate: endDate)
    }

    private func startNewLiveActivity(endDate: Date) async {
        guard Activity<VPNSnoozeActivityAttributes>.activities.isEmpty else {
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
            print("DEBUG: Failed to start activity with error: \(error.localizedDescription)")
        }
    }

    func cancelAllRunningActivities() async {
        for activity in Activity<VPNSnoozeActivityAttributes>.activities {
            let initialContentState = VPNSnoozeActivityAttributes.ContentState(endDate: Date())

            await activity.end(
                ActivityContent(state: initialContentState, staleDate: Date()),
                dismissalPolicy: .immediate
            )
        }
    }

}
