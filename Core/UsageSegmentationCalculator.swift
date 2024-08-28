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

// TODO consider just using AtbNumeric here directly and removing it from Atb class

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
        return UsageSegmentationCalculator(installAtb: installAtb)
    }

}

final class DefaultCalculatorFactory: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return UsageSegmentationCalculator(installAtb: installAtb)
    }

}

/// This implementation is based on https://dub.duckduckgo.com/flawrence/felix-jupyter-modules/blob/master/segments_reference.py and has been written to try and 
///  closely resemble the original code as possible.
///
///  Some general terminology changes:
///  * new_set_atb => atb
///  * atb_cohort => installAtb
///
/// Commented code starting with # indicate comments copied over from the reference implementation.
///
///  The code is arranged so that the public function which is the one that matters the most is the first thing you read.  Private functions are added to the end as they are encounted during the process of coverting the Python to Swift.
///
final class UsageSegmentationCalculator: UsageSegmentationCalculating {

    enum Params {

        static let activityType = "activity_type"
        static let newSetAtb = "new_set_atb"
        static let segmentsToday = "segments_today"
        static let segmentsPreviousWeek = "segments_prev_week"
        static let segmentsPreviousMonthPrefix = "segments_prev_month_"
        static let countAsWAU = "count_as_wau"
        static let countAsMAUn = "count_as_mau_n"

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
        updateState(atb, pixelInfo: result)

        return result
    }

    /// py: 172 `get_pixel_info`
    private func getPixelInfo(_ atb: Atb, _ activityType: UsageActivityType) -> [String: String] {
        var pixel: [String: String] = [:]

        // py:174
        pixel[Params.activityType] = activityType.rawValue
        pixel[Params.newSetAtb] = atb.version

        // py:178
        pixel[Params.segmentsToday] = getSegments(atb)

        // py:182
        if previousAtb == nil {
            /*
             # It's the first day since install!
             # This is a special case (lots of initialization to do)
             # Let's handle it all in one place.
             */
            pixel[Params.countAsWAU] = "true"
            pixel[Params.countAsMAUn] = "tttt"
            return pixel
        }

        // py:190
        if countAsWAU(atb) {
            pixel[Params.countAsWAU] = "true"
        }

        // py:192
        if countsAsWAUAndActivePreviousWeek(atb) &&
            !previousWAUSegments.isEmpty {
            pixel[Params.segmentsPreviousWeek] = previousWAUSegments
        }

        // py:198
        let countAsMAUn = (0 ..< 4).map {
            countAsMAU($0, atb) ? "t" : "f"
        }.joined()

        // py:203
        if countAsMAUn != "ffff" {
            pixel[Params.countAsMAUn] = countAsMAUn
            for n in 0 ..< 4 {
                if countsAsMAUAndActivePreviousMonth(n, atb) &&
                    !previousMAUSegments[n].isEmpty {
                    pixel[Params.segmentsPreviousMonthPrefix + "\(n)"] = previousMAUSegments[n]
                }
            }
        }

        return pixel
    }

    /// py:255 `update_client`
    private func updateState(_ atb: Atb, pixelInfo: [String: String]) {
        // ignore `new_set_atb` as that's always passed in
        previousAtb = atb

        // py:261
        // # Trim history to 28d and add today
        usageHistory = usageHistory.filter {
            atb - $0 <= 28
        } + [atb]

        // py:266
        if pixelInfo[Params.countAsWAU] != nil {
            previousWAUSegments = pixelInfo.safeValue(forKey: Params.segmentsToday)
        }

        // py:269
        if let countAsMAUn = pixelInfo[Params.countAsMAUn] {
            for n in 0 ..< 4 where countAsMAUn.safeCharAt(n) == "t" {
                previousMAUSegments[n] = pixelInfo.safeValue(forKey: Params.segmentsToday)
            }
        }
    }

    /// py:95 `get_segments`
    private func getSegments(_ atb: Atb) -> String {
        var segments: [String] = []

        // py:98
        if atb.week == installAtb.week && countAsWAU(atb) {
            segments.append("first_week")
        }

        // py:104
        if atb.week == installAtb.week + 1 {
            segments.append("second_week")
        }

        // py:110
        if atb.week < installAtb.week + 4 {
            segments.append("first_month")
        }

        // py:116
        if installAtb.isReturningUser
            // # ATB cohorts get generalized after 28d
            // # Hopefully this is handled elsewhere in the real code!
            && atb.ageInDays <= installAtb.ageInDays + 28 {
            segments.append("reinstaller")
        }

        // py:124
        if countAsWAU(atb) // TODO validate prev atb or install atb??
            && !countsAsWAUAndActivePreviousWeek(atb) // TODO validate prev atb or install atb??
            && atb.week >= installAtb.week + 2 {
            segments.append("reactivated_wau")
        }

        // py:131
        for n in 0..<4 {
            if countAsMAU(n, atb) // TODO validate prev atb or install atb??
                && !countsAsMAUAndActivePreviousMonth(n, atb)
                && atb.week >= installAtb.week + 4 {
                segments.append("reactivated_mau_\(n)")
            }
        }

        // py:139
        if segmentRegular(atb) {
            segments.append("regular")
        }

        // py:142
        if _segmentIntermittent(atb) {
            segments.append("intermittent")
        }

        // py:145
        return segments.sorted().joined(separator: ",")
    }

    /// py:48 `count_as_wau`
    private func countAsWAU(_ atb: Atb) -> Bool {
        // py:49
        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        // py:52
        if previousAtb == nil || previousAtb == installAtb {
            // # First post-install activity
            return true
        }

        // py:55 - This deviates because the python *sometimes* passes in installAtb if previousAtb is nil
        return atb.week > (previousAtb ?? installAtb).week
    }

    /// py:58 `caw_and_active_prev_week`
    private func countsAsWAUAndActivePreviousWeek(_ atb: Atb) -> Bool {
        // py:59
        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        // py: 62
        if previousAtb == nil || previousAtb == installAtb {
            // # First post-install activity
            return false
        }

        if !countAsWAU(atb) {
            return false
        }

        // py: 68 - This deviates because the python *sometimes* passes in installAtb if previousAtb is nil
        return atb.week == (previousAtb ?? installAtb).week + 1
    }

    /// py:71 `count_as_mau`
    private func countAsMAU(_ n: Int, _ atb: Atb) -> Bool {
        assert(n < 4)

        // py:73
        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        // py:76
        if previousAtb == nil || previousAtb == installAtb {
            // # First post-install activity
            return true
        }

        // py:79 - not that in python // means "floor division" which is the equivalent of doing integer devision in Swift
        return (atb.week - n) / 4 > ((previousAtb ?? installAtb).week - n) / 4
    }

    /// py: 82 `cam_and_active_prev_month`
    private func countsAsMAUAndActivePreviousMonth(_ n: Int, _ atb: Atb) -> Bool {
        assert(n < 4)

        // py:84
        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        // py:87
        if previousAtb == nil || previousAtb == installAtb {
            // # First post-install activity
            return false
        }

        // py:90
        if !countAsMAU(n, atb) {
            return false
        }

        // py:93
        return (atb.week - n) / 4 == ((previousAtb ?? installAtb).week - n) / 4 + 1
    }

    /// py: 157 `segment_regular`
    private func segmentRegular(_ atb: Atb) -> Bool {
        return relevantHistoryNums(atb).count >= 14
    }

    private func _segmentIntermittent(_ atb: Atb) -> Bool {
#warning("not implemented")
        return false
    }

    /// py: 148 `relevant_history_nums`
    private func relevantHistoryNums(_ atb: Atb) -> [Int] {
        let installDay = installAtb.ageInDays
        let today = atb.ageInDays
        let history = usageHistory.map { $0.ageInDays }
        return Set(history.filter {
            // py: 153
            $0 < today && $0 >= today - 29 && $0 > installDay
        }).sorted()
    }
}

private extension Dictionary where Key == String, Value == String {
    func safeValue(forKey key: String) -> String {
        if let value = self[key] {
            return value
        } else {
            assertionFailure("Value for key '\(key)' is nil.")
            return ""
        }
    }
}

private extension String {

    func safeCharAt(_ index: Int) -> String {
        guard self.count > index else {
            assertionFailure("index out of bounds")
            return ""
        }
        return String(self[self.index(self.startIndex, offsetBy: index)])
    }

}
