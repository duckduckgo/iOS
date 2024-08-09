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
            let startDate = Date()
            let endDate = context.state.endDate
            var range: ClosedRange<Date>?

            if startDate <= endDate {
                range = startDate...endDate
            }

            return HStack {
                VPNSnoozeLiveActivityPrimaryCountdownView(snoozeActive: !context.isStale, countdownRange: range, snoozeEndDate: endDate)
                Spacer()
                VPNSnoozeLiveActivityActionView(snoozeActive: !context.isStale)
            }
            .padding()
            .activityBackgroundTint(Color.black)
        } dynamicIsland: { context in
            let startDate = Date()
            let endDate = context.state.endDate
            var range: ClosedRange<Date>?

            if startDate <= endDate {
                range = startDate...endDate
            }

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VPNSnoozeLiveActivityPrimaryCountdownView(snoozeActive: !context.isStale, countdownRange: range, snoozeEndDate: endDate)
                        .dynamicIsland(verticalPlacement: .belowIfTooWide)
                        .padding(.bottom, 15)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VPNSnoozeLiveActivityActionView(snoozeActive: !context.isStale)
                }
            } compactLeading: {
                context.isStale ? Image("vpn-on-compact") : Image("vpn-off-compact")
            } compactTrailing: {
                if let range {
                    Text(timerInterval: range, pauseTime: range.lowerBound, countsDown: true)
                        .foregroundStyle(Color(uiColor: UIColor.yellow60))
                        .frame(minWidth: 0, maxWidth: 55)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(timerInterval: endDate...Date.distantFuture, countsDown: false)
                        .foregroundStyle(Color(uiColor: UIColor.midGreen))
                        .frame(minWidth: 0, maxWidth: 55)
                        .multilineTextAlignment(.trailing)
                }
            } minimal: {
                context.isStale ? Image("vpn-on-compact") : Image("vpn-off-compact")
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

@available(iOS 17.0, *)
private struct VPNSnoozeLiveActivityPrimaryCountdownView: View {

    let snoozeActive: Bool
    let countdownRange: ClosedRange<Date>?
    let snoozeEndDate: Date

    var body: some View {
        HStack {
            if snoozeActive {
                Image("vpn-off-live-activity")
            } else {
                Image("vpn-on")
            }

            VStack(alignment: .leading) {
                if snoozeActive {
                    Text(UserText.vpnWidgetLiveActivityVPNSnoozingStatusLabel)
                        .foregroundStyle(Color.white)
                } else {
                    Text(UserText.vpnWidgetLiveActivityVPNActiveStatusLabel)
                        .foregroundStyle(Color.white)
                }

                if let countdownRange {
                    Text(timerInterval: countdownRange, pauseTime: countdownRange.lowerBound, countsDown: true)
                        .foregroundStyle(Color(uiColor: UIColor.yellow60))
                } else {
                    Text(timerInterval: snoozeEndDate...Date.distantFuture, countsDown: false)
                        .foregroundStyle(Color(uiColor: UIColor.midGreen))
                }
            }

            Spacer()
        }
    }

}

@available(iOS 17.0, *)
private struct VPNSnoozeLiveActivityActionView: View {

    let snoozeActive: Bool

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Button(intent: CancelSnoozeLiveActivityAppIntent(), label: {
                Text(snoozeActive ? UserText.vpnWidgetLiveActivityWakeUpButton : UserText.vpnWidgetLiveActivityDismissButton)
                    .font(Font.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.white)
            })
            .buttonStyle(.borderedProminent)
            .tint(Color("WidgetLiveActivityButtonColor"))

            Spacer()
        }
    }

}
