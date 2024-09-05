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
        return UsageSegmentationCalculator(installAtb: installAtb)
    }

}

final class DefaultCalculatorFactory: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return UsageSegmentationCalculator(installAtb: installAtb)
    }

}

/// This implementation is based on https://dub.duckduckgo.com/flawrence/felix-jupyter-modules/blob/master/segments_reference.py and has been written to try and 
///   resemble the original code as closely as possible.
///
/// * Some general terminology changes:
///   * new_set_atb => atb
///   * atb_cohort => installAtb
///
/// * Commented code starting with # indicate comments copied over from the reference implementation.
///
/// * The code is arranged so that the public function which is the one that matters the most is the first thing you read.  Private functions are added to the end as they are encounted during the process of coverting the Python to Swift.
///
/// * It was agreed that for the purpose of comparison and calcuation that if previousAtb is nil we can use the installAtb
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
    private var usageHistory = [Atb]()
    private var previousAtb: Atb?
    private var previousWAUSegments = [String]()
    private var previousMAUSegments = Array(repeating: Array(repeating: "", count: 4), count: 4)

    init(installAtb: Atb) {
        self.installAtb = installAtb
    }

    func processAtb(_ atb: Atb, forActivityType activityType: UsageActivityType) -> [String: String]? {

        /*
         # Same day as previous action - not even a new DAU.
         # Nothing to report or store. Skip.
         */
        guard previousAtb != atb else { return nil }

        /*
        # It's install day - report nothing, to be consistent with
        # the ATB system's DAU WAU & MAU.
        # Don't even update the client state: today does not exist.
         */
        guard installAtb != atb else { return nil }

        let result = getPixelInfo(atb, activityType)

        updateState(atb, pixelInfo: result)

        return result.toStringDict()
    }

    /// `get_pixel_info`
    private func getPixelInfo(_ atb: Atb, _ activityType: UsageActivityType) -> [String: Any] {
        var pixel: [String: Any] = [:]

        pixel[Params.activityType] = activityType.rawValue
        pixel[Params.newSetAtb] = atb.version

        pixel[Params.segmentsToday] = getSegments(atb)

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

        if countAsWAU(atb) {
            pixel[Params.countAsWAU] = "true"
        }

        if countsAsWAUAndActivePreviousWeek(atb) &&
            !previousWAUSegments.isEmpty {
            pixel[Params.segmentsPreviousWeek] = previousWAUSegments
        }

        let countAsMAUn = (0 ..< 4).map {
            countAsMAU($0, atb) ? "t" : "f"
        }.joined()

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

    /// `update_client`
    private func updateState(_ atb: Atb, pixelInfo: [String: Any]) {
        previousAtb = atb

        // # Trim history to 28d and add today
        usageHistory = usageHistory.filter {
            atb - $0 <= 28
        } + [atb]

        if pixelInfo[Params.countAsWAU] != nil {
            let segments = pixelInfo[Params.segmentsToday] as? [String] ?? []
            // # Filter out segments irrelevant to wau
            previousWAUSegments = segments.filter {
                return !$0.contains("_mau") && $0 != "first_month"
            }
        }

        if let countAsMAUn = pixelInfo[Params.countAsMAUn] as? String {
            let segments = pixelInfo[Params.segmentsToday] as? [String] ?? []
            for n in 0 ..< 4 where countAsMAUn.safeCharAt(n) == "t" {
                previousMAUSegments[n] = segments.filter {
                    // # Filter out irrelevant to MAU
                    return !$0.contains("_wau") && !$0.contains("_week")
                    //  # Filter out irrelevant to _this_ MAU
                    && ($0.contains("_mau_\(n)") || !$0.contains("_mau_"))
                }
            }
        }
    }

    /// `get_segments`
    private func getSegments(_ atb: Atb) -> [String] {
        var segments: [String] = []

        if countAsWAU(atb) {
            if atb.week == installAtb.week {
                segments.append("first_week")
            } else if atb.week == installAtb.week + 1 {
                segments.append("second_week")
            } else if countsAsWAUAndActivePreviousWeek(atb) {
                segments.append("current_user_wau")
            } else {
                segments.append("reactivated_wau")
            }
        }

        if (isFirstPostInstallActivity(installAtb))
            && atb.week < installAtb.week + 4 {
            segments.append("first_month")
        } else {
            for n in 0 ..< 4 where countAsMAU(n, atb) {
                if countsAsMAUAndActivePreviousMonth(n, atb) {
                    segments.append("current_user_mau_\(n)")
                } else {
                    segments.append("reactivated_mau_\(n)")
                }
            }
        }

        if installAtb.isReturningUser
            // # ATB cohorts get generalized after 28d
            // # Hopefully this is handled elsewhere in the real code!
            && atb.ageInDays <= installAtb.ageInDays + 28 {
            segments.append("reinstaller")
        }

        if segmentRegular(atb) {
            segments.append("regular")
        }

        if segmentIntermittent(atb) {
            segments.append("intermittent")
        }

        return segments.sorted()
    }

    /// `count_as_wau`
    private func countAsWAU(_ atb: Atb) -> Bool {
        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        if isFirstPostInstallActivity(installAtb) {
            // # First post-install activity
            return true
        }

        return atb.week > (previousAtb ?? installAtb).week
    }

    /// `caw_and_active_prev_week`
    private func countsAsWAUAndActivePreviousWeek(_ atb: Atb) -> Bool {
        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        if isFirstPostInstallActivity(installAtb) {
            // # First post-install activity
            return false
        }

        if !countAsWAU(atb) {
            return false
        }

        return atb.week == (previousAtb ?? installAtb).week + 1
    }

    /// `count_as_mau`
    private func countAsMAU(_ n: Int, _ atb: Atb) -> Bool {
        assert(n < 4)

        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        if isFirstPostInstallActivity(installAtb) {
            // # First post-install activity
            return true
        }

        // note that in python // means "floor division" which is the equivalent of doing integer division in Swift
        return (atb.week - n) / 4 > ((previousAtb ?? installAtb).week - n) / 4
    }

    /// `cam_and_active_prev_month`
    private func countsAsMAUAndActivePreviousMonth(_ n: Int, _ atb: Atb) -> Bool {
        assert(n < 4)

        if atb == installAtb {
            // # Install day - this code should not be running! Report nothing.
            assertionFailure("See comment")
            return false
        }

        if isFirstPostInstallActivity(installAtb) {
            // # First post-install activity
            return false
        }

        if !countAsMAU(n, atb) {
            return false
        }

        // note that in python // means "floor division" which is the equivalent of doing integer division in Swift
        return (atb.week - n) / 4 == ((previousAtb ?? installAtb).week - n) / 4 + 1
    }

    /// `segment_regular`
    private func segmentRegular(_ atb: Atb) -> Bool {
        return relevantHistoryNums(atb).count >= 14
    }

    /// `segment_intermittent`
    private func segmentIntermittent(_ atb: Atb) -> Bool {
        let today = atb.ageInDays
        let history = relevantHistoryNums(atb)

        if history.count >= 14 {
            return false
        }

        let rollingWeeksActive = Set(history.map { (today - $0 - 1) / 7 })

        return rollingWeeksActive.count == 4
    }

    /// `relevant_history_nums`
    private func relevantHistoryNums(_ atb: Atb) -> [Int] {
        let installDay = installAtb.ageInDays
        let today = atb.ageInDays
        let history = usageHistory.map { $0.ageInDays }
        return Set(history.filter {
            $0 < today && $0 >= today - 29 && $0 > installDay
        }).sorted()
    }

    private func isFirstPostInstallActivity(_ installAtb: Atb) -> Bool {
        return previousAtb == nil || previousAtb == installAtb
    }
}

private extension Dictionary where Key == String, Value == Any {
    
    func toStringDict() -> [String: String] {
        var dict: [String: String] = [:]

        self.forEach { entry in
            if let array = entry.value as? [String] {
                dict[entry.key] = array.joined(separator: ",")
            } else if let string = entry.value as? String {
                dict[entry.key] = string
            } else {
                assertionFailure("Unexpected value type")
            }
        }

        return dict
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
