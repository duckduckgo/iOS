//
//  UsageSegmentationCalculator.swift
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

protocol UsageSegmentationCalculatorMaking {

    /// Creates a calculator with the provided initial state
    func make(installAtb: Atb) -> UsageSegmentationCalculating

}

/// The calculator does not store state, so to get the latest values call it for each previously seen ATB.
protocol UsageSegmentationCalculating {

    func processAtb(_ atb: Atb, forActivityType activityType: UsageActivityType) -> [String: String]?

}

final class UsageSegmentationCalculatorFactory: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return DefaultCalculator(installAtb: installAtb)
    }

}

final class DefaultCalculatorFactory: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return DefaultCalculator(installAtb: installAtb)
    }

}

/// This implementation is based on https://dub.duckduckgo.com/flawrence/felix-jupyter-modules/blob/master/segments_reference.py and has been written to try and 
///  closely resemble the original code as possible.
final class DefaultCalculator: UsageSegmentationCalculating {

    enum Params: String {

        case activityType = "activity_type"
        case newSetAtb = "new_set_atb"
        case segmentsToday = "segments_today"
        case segmentsPreviousWeek = "segments_prev_week"
        case segmentsPreviousMonthPrefix = "segments_prev_month_"
        case countAsWAU = "count_as_wau"
        case countAsMAUn = "count_as_mau_n"

    }

    let installAtb: Atb
    var usageHistory = [Atb]()
    var previousAtb: Atb?
    var previousWAUSegments = ""
    var previousMAUSegments = Array(repeating: "", count: 4)

    init(installAtb: Atb) {
        self.installAtb = installAtb
    }

    func processAtb(_ atb: Atb, forActivityType activityType: UsageActivityType) -> [String: String]? {

        /* py:233
         # Same day as previous action - not even a new DAU.
         # Nothing to report or store. Skip.
         */
        guard previousAtb != atb else { return nil }

        /* py:238
        # It's install day - report nothing, to be consistent with
        # the ATB system's DAU WAU & MAU.
        # Don't even update the client state: today does not exist.
         */
        guard installAtb != atb else { return nil }

        // py:244
        let result = getPixelInfo(atb, activityType)

        // py:247
        updateState()

        return result
    }

    private func getPixelInfo(_ atb: Atb, _ activityType: UsageActivityType) -> [String: String] {
        var pixel: [String: String] = [:]

        // py:174
        pixel[Params.activityType.rawValue] = activityType.rawValue
        pixel[Params.newSetAtb.rawValue] = atb.version

        // py:178
        pixel[Params.segmentsToday.rawValue] = getSegments(atb)

        // py:182
        if previousAtb == nil {
            /*
             # It's the first day since install!
             # This is a special case (lots of initialization to do)
             # Let's handle it all in one place.
             */
            pixel[Params.countAsWAU.rawValue] = "true"
            pixel[Params.countAsMAUn.rawValue] = "tttt"
            return pixel
        }

        // py:190
        if countAsWAU(atb) {
            pixel[Params.countAsWAU.rawValue] = "true"
        }

        // py:192
        if countsAsWAUAndActivePreviousWeek(atb) &&
            !previousWAUSegments.isEmpty {
            pixel[Params.segmentsPreviousWeek.rawValue] = previousWAUSegments
        }

        // py:198
        let countAsMAUn = (0 ..< 4).map {
            countAsMAU($0, atb) ? "t" : "f"
        }.joined()

        // py:203
        if countAsMAUn != "ffff" {
            pixel[Params.countAsMAUn.rawValue] = countAsMAUn
            for n in 0 ..< 4 {
                if countsAsMAUAndActivePreviousMonth(n, atb) &&
                    !previousMAUSegments[n].isEmpty {
                    pixel[Params.segmentsPreviousMonthPrefix.rawValue + "\(n)"] = previousMAUSegments[n]
                }
            }
        }

        return pixel
    }

    private func updateState() {
#warning("not implemented")
    }

    private func getSegments(_ atb: Atb) -> String {
#warning("not implemented")
        return ""
    }

    private func countAsWAU(_ atb: Atb) -> Bool {
#warning("not implemented")
        return false
    }

    private func countsAsWAUAndActivePreviousWeek(_ atb: Atb) -> Bool {
#warning("not implemented")
        return false
    }

    private func countAsMAU(_ n: Int, _ atb: Atb) -> Bool {
#warning("not implemented")
        return false
    }

    private func countsAsMAUAndActivePreviousMonth(_ n: Int, _ atb: Atb) -> Bool {
#warning("not implemented")
        return false
    }

}
