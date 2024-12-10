//
//  TabSwitcherOpenDailyPixel.swift
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

struct TabSwitcherOpenDailyPixel {
    /// Returns parameters with buckets for respective tabs statistics.
    /// - Parameters:
    ///     - tabs: Tabs to be included in the statistics
    ///     - referenceDate: Date to be used as a reference for calculating inactive tabs. Required for testing.
    func parameters(with tabs: [Tab], referenceDate: Date = .now) -> [String: String] {
        var parameters = [String: String]()

        parameters[ParameterName.tabCount] = tabCountBucket(for: tabs)
        parameters[ParameterName.newTabCount] = newTabCountBucket(for: tabs)
        parameters[ParameterName.tabActive7dCount] = bucketForInactiveTabs(tabs, within: (-7)..., from: referenceDate)
        parameters[ParameterName.tabInactive1wCount] = bucketForInactiveTabs(tabs, within: (-14)...(-8), from: referenceDate)
        parameters[ParameterName.tabInactive2wCount] = bucketForInactiveTabs(tabs, within: (-21)...(-15), from: referenceDate)
        parameters[ParameterName.tabInactive3wCount] = bucketForInactiveTabs(tabs, within: ...(-22), from: referenceDate)

        return parameters
    }

    private func tabCountBucket(for tabs: [Tab]) -> String? {
        let count = tabs.count

        switch count {
        case 0: return nil
        case 1...1: return "1"
        case 2...5: return "2-5"
        case 6...10: return "6-10"
        case 11...20: return "11-20"
        case 21...40: return "21-40"
        case 41...60: return "41-60"
        case 61...80: return "61-80"
        default: return "81+"
        }

    }

    private func bucketForInactiveTabs<Range: RangeExpression>(_ tabs: [Tab], within daysInterval: Range, from referenceDate: Date) -> String? where Range.Bound == Int {
        let dateInterval = AbsoluteDateInterval(daysInterval: daysInterval, basedOn: referenceDate)

        let matchingTabsCount = tabs.count {
            guard let lastViewedDate = $0.lastViewedDate else { return false }

            return dateInterval.contains(lastViewedDate)
        }

        switch matchingTabsCount {
        case 0: return "0"
        case 1...5: return "1-5"
        case 6...10: return "6-10"
        case 11...20: return "11-20"
        default: return "21+"
        }
    }

    private func newTabCountBucket(for tabs: [Tab]) -> String? {
        let count = tabs.count { $0.link == nil }

        switch count {
        case 0...1: return "0-1"
        case 2...10: return "2-10"
        default: return "11+"
        }
    }

    private enum ParameterName {
        static let tabCount = "tab_count"
        static let newTabCount = "new_tab_count"

        static let tabActive7dCount = "tab_active_7d"
        static let tabInactive1wCount = "tab_inactive_1w"
        static let tabInactive2wCount = "tab_inactive_2w"
        static let tabInactive3wCount = "tab_inactive_3w"
    }
}

private extension TimeInterval {
    static let dayInterval: TimeInterval = 86400
}

private struct AbsoluteDateInterval<R: RangeExpression> where R.Bound == Int {
    private let lowerBoundDate: Date
    private let upperBoundDate: Date

    init(daysInterval: R, basedOn referenceDate: Date) {
        switch daysInterval {
        case let daysRange as ClosedRange<R.Bound>:
            self.lowerBoundDate = referenceDate.addingTimeInterval(Double(daysRange.lowerBound) * .dayInterval)
            self.upperBoundDate = referenceDate.addingTimeInterval(Double(daysRange.upperBound) * .dayInterval)

        case let daysRange as PartialRangeThrough<R.Bound>:
            self.lowerBoundDate = Date.distantPast
            self.upperBoundDate = referenceDate.addingTimeInterval(Double(daysRange.upperBound) * .dayInterval)

        case let daysRange as PartialRangeFrom<R.Bound>:
            self.lowerBoundDate = referenceDate.addingTimeInterval(Double(daysRange.lowerBound) * .dayInterval)
            self.upperBoundDate = Date.distantFuture

        default:
            fatalError("\(R.self) is not supported")
        }
    }

    func contains(_ date: Date) -> Bool {
        lowerBoundDate...upperBoundDate ~= date
    }
}
