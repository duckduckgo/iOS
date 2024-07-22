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

    @Environment(\.colorScheme) private var colorScheme

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VPNSnoozeActivityAttributes.self) { context in
            Group {
                if context.isStale {
                    HStack {
                        Image("vpn-off")

                        Text("VPN snooze has ended")
                            .foregroundStyle(Color(designSystemColor: .textPrimary))

                        Button(intent: CancelSnoozeLiveActivityAppIntent(), label: {
                            Text("Dismiss")
                        })
                    }
                } else if let range = self.range(from: context.state.endDate) {
                    HStack {
                        Image("vpn-off")

                        Text("Reconnecting in ")
                            .foregroundStyle(Color(designSystemColor: .textPrimary))
                        +
                        Text(timerInterval: range, pauseTime: range.lowerBound, countsDown: true)
                            .foregroundStyle(Color(uiColor: UIColor.yellow60))

                        Button(intent: CancelSnoozeLiveActivityAppIntent(), label: {
                            Text("Resume")
                        })
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color.secondary)
        } dynamicIsland: { context in
            let startDate = Date()
            let endDate = context.state.endDate
            var range: ClosedRange<Date>?

            if startDate <= endDate {
                range = startDate...endDate
            }

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("vpn-off")
                }

                DynamicIslandExpandedRegion(.center) {
                    if let range {
                        Group {
                            Text("Reconnecting in ") +
                            Text(timerInterval: range, pauseTime: range.lowerBound, countsDown: true)
                                .foregroundStyle(Color(uiColor: UIColor.yellow60))
                        }
                            .multilineTextAlignment(.center)
                    } else {
                        Text("VPN snooze has ended")
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.isStale {
                        Button(intent: CancelSnoozeLiveActivityAppIntent(), label: {
                            Text("Dismiss")
                                .frame(maxWidth: .infinity)
                        })
                    } else {
                        Button(intent: CancelSnoozeLiveActivityAppIntent(), label: {
                            Text("Resume VPN")
                                .frame(maxWidth: .infinity)
                        })
                    }
                }
            } compactLeading: {
                Image("vpn-off-compact")
            } compactTrailing: {
                if let range {
                    Text(timerInterval: range, pauseTime: range.lowerBound, countsDown: true)
                        .foregroundStyle(Color(uiColor: UIColor.yellow60))
                        .frame(minWidth: 0, maxWidth: 55)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text("0:00")
                        .foregroundStyle(Color(uiColor: UIColor.yellow60))
                        .frame(minWidth: 0, maxWidth: 55)
                        .multilineTextAlignment(.trailing)
                }
            } minimal: {
                Image("vpn-off-compact")
            }
        }
    }

    private func range(from endDate: Date) -> ClosedRange<Date>? {
        let startDate = Date()

        if startDate <= endDate {
            return startDate...endDate
        } else {
            return nil
        }
    }

}
