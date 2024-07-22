//
//  VPNSnoozeLiveActivityWidget.swift
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
import WidgetKit
import SwiftUI

@available(iOS 17.0, *)
struct VPNSnoozeLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VPNSnoozeActivityAttributes.self) { context in
            if context.isStale {
                VPNSnoozeActivityView(text: "VPN snooze has ended")
                    .padding()
            } else {
                VPNSnoozeActivityView(text: "VPN snooze is active")
                    .padding()
            }
        } dynamicIsland: { context in
            let startDate = Date()
            let endDate = context.state.endDate
            var range: ClosedRange<Date>?

            if startDate <= endDate {
                range = startDate...endDate
            }

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VPNSnoozeActivityView(text: "VPN")
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if let range {
                        Button("Resume") {
                            print("Resume")
                        }
                    } else {
                        Button("Dismiss") {
                            print("Dismiss")
                        }
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.isStale {
                        VPNSnoozeActivityView(text: "VPN snooze has ended")
                    } else {
                        VPNSnoozeActivityView(text: "VPN snooze is active")
                    }
                }
            } compactLeading: {
                VPNSnoozeActivityView(text: "VPN")
            } compactTrailing: {
                if let range {
                    Text(timerInterval: range, pauseTime: range.lowerBound, countsDown: true)
                        .frame(minWidth: 0, maxWidth: 65)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text("X")
                }
            } minimal: {
                VPNSnoozeActivityView(text: "M")
            }
        }
    }

}

@available(iOS 17.0, *)
struct VPNSnoozeActivityView: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
        }
    }
}
