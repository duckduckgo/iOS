//
//  TabSwitcherOpenDailyPixelTests.swift
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

import XCTest
import Core
@testable import DuckDuckGo

final class TabSwitcherOpenDailyPixelTests: XCTestCase {
    func testPopulatesParameters() {
        let tabs = [Tab(), Tab(), Tab()]
        let pixel = TabSwitcherOpenDailyPixel()

        let parameters = pixel.parameters(with: tabs)

        XCTAssertNotNil(parameters[ParameterName.tabCount])
        XCTAssertNotNil(parameters[ParameterName.newTabCount])
    }

    func testIncludesProperCountsForParameters() {
        let tabs = [Tab(), Tab(), .mock()]
        let pixel = TabSwitcherOpenDailyPixel()

        let parameters = pixel.parameters(with: tabs)

        XCTAssertEqual(parameters[ParameterName.tabCount], "2-5")
        XCTAssertEqual(parameters[ParameterName.newTabCount], "2-10")
    }

    func testBucketsAggregation() {
        let bucketValues = [
            1...1: "1",
            2...5: "2-5",
            6...10: "6-10",
            11...20: "11-20",
            21...40: "21-40",
            41...60: "41-60",
            61...80: "61-80",
            81...90: "81+",
            501...504: "81+"]

        for bucket in bucketValues {
            for value in bucket.key {
                let tabs = Array(repeating: Tab.mock(), count: value)

                let countParameter = TabSwitcherOpenDailyPixel().parameters(with: tabs)[ParameterName.tabCount]

                XCTAssertEqual(countParameter, bucket.value)
            }
        }
    }

    func testNewTabBucketsAggregation() {
        let bucketValues = [
            0...1: "0-1",
            2...10: "2-10",
            11...20: "11+"]

        for bucket in bucketValues {
            for value in bucket.key {
                let tabs = Array(repeating: Tab(), count: value)

                let countParameter = TabSwitcherOpenDailyPixel().parameters(with: tabs)[ParameterName.newTabCount]

                XCTAssertEqual(countParameter, bucket.value)
            }
        }
    }

    // - MARK: Inactive tabs aggregation tests

    func testTabsWithoutLastVisitValueArentIncludedInBuckets() throws {
        let tabs = [Tab.mock(), .mock()]

        let parameters = TabSwitcherOpenDailyPixel().parameters(with: tabs)

        try testBucketParameters(parameters, expectedCount: 0)
    }

    func testEdgeCaseBucketParameterForInactiveTabs() throws {
        let now = Date()

        let tabs: [Tab] = [
            .mock(lastViewedDate: now.daysAgo(7)),
            .mock(lastViewedDate: now.daysAgo(14)),
            .mock(lastViewedDate: now.daysAgo(21)),
            .mock(lastViewedDate: now.daysAgo(22))
        ]

        let pixelParametersForSecondInterval = TabSwitcherOpenDailyPixel().parameters(with: tabs, referenceDate: now)

        try testBucketParameters(pixelParametersForSecondInterval, expectedCount: 1)
    }

    func testBucketParametersForInactiveTabs() throws {
        let now = Date()

        let tabsSecondInterval = Tab.stubCollectionForSecondInterval(baseDate: now)
        let parametersForSecondInterval = TabSwitcherOpenDailyPixel().parameters(with: tabsSecondInterval, referenceDate: now)

        let tabsThirdInterval = Tab.stubCollectionForThirdInterval(baseDate: now)
        let parametersForThirdInterval = TabSwitcherOpenDailyPixel().parameters(with: tabsThirdInterval, referenceDate: now)

        try testBucketParameters(parametersForSecondInterval, expectedCount: 5)
        try testBucketParameters(parametersForThirdInterval, expectedCount: 6)
    }

    func testBucketNamingForInactiveTabs() throws {
        let now = Date()
        let expectedBuckets = [
            0...0: "0",
            1...5: "1-5",
            6...10: "6-10",
            11...20: "11-20",
            21...40: "21+"
        ]

        // How many days need to pass for each interval bucket
        let parameterDaysOffsetMapping = [
            ParameterName.tabActive7dCount: 0,
            ParameterName.tabInactive1wCount: 8,
            ParameterName.tabInactive2wCount: 15,
            ParameterName.tabInactive3wCount: 22
        ]

        for bucket in expectedBuckets {
            let count = bucket.key.lowerBound

            for parameter in parameterDaysOffsetMapping {
                let daysOffset = parameter.value
                // Create tabs based on expected count for bucket, using proper days offset
                let tabs = Array(repeating: Tab.mock(lastViewedDate: now.daysAgo(daysOffset)), count: count)

                let parameters = TabSwitcherOpenDailyPixel().parameters(with: tabs, referenceDate: now)

                XCTAssertEqual(parameters[parameter.key], bucket.value, "Failed for bucket: \(bucket.key) with parameter: \(parameter.key)")
            }
        }
    }

    // MARK: - Test helper methods

    private func testBucketParameters(_ parameters: [String: String], expectedCount: Int) throws {
        let parameterNames = [
            ParameterName.tabActive7dCount,
            ParameterName.tabInactive1wCount,
            ParameterName.tabInactive2wCount,
            ParameterName.tabInactive3wCount
        ]

        let expectedBucket = try XCTUnwrap(Buckets.inactiveTabs.first { $0.key.contains(expectedCount) }).value
        for parameterName in parameterNames {
            let bucketValue = parameters[parameterName]

            XCTAssertEqual(bucketValue, expectedBucket, "Failed for parameter: \(parameterName)")
        }
    }
}

private extension Tab {
    static func mock(lastViewedDate: Date? = nil) -> Tab {
        Tab(link: Link(title: nil, url: URL("https://example.com")!), lastViewedDate: lastViewedDate)
    }

    static func stubCollectionForSecondInterval(baseDate: Date) -> [Tab] {
        [
            // MARK: First week
            .mock(lastViewedDate: baseDate),
            .mock(lastViewedDate: baseDate.daysAgo(3)),
            .mock(lastViewedDate: baseDate.daysAgo(4)),
            .mock(lastViewedDate: baseDate.daysAgo(5)),
            .mock(lastViewedDate: baseDate.daysAgo(7)),

            // MARK: >1 week
            .mock(lastViewedDate: baseDate.daysAgo(8)),
            .mock(lastViewedDate: baseDate.daysAgo(10)),
            .mock(lastViewedDate: baseDate.daysAgo(11)),
            .mock(lastViewedDate: baseDate.daysAgo(12)),
            .mock(lastViewedDate: baseDate.daysAgo(14)),

            // MARK: >2 weeks
            .mock(lastViewedDate: baseDate.daysAgo(15)),
            .mock(lastViewedDate: baseDate.daysAgo(16)),
            .mock(lastViewedDate: baseDate.daysAgo(17)),
            .mock(lastViewedDate: baseDate.daysAgo(18)),
            .mock(lastViewedDate: baseDate.daysAgo(21)),

            // MARK: >3 weeks
            .mock(lastViewedDate: baseDate.daysAgo(22)),
            .mock(lastViewedDate: baseDate.daysAgo(23)),
            .mock(lastViewedDate: baseDate.daysAgo(24)),
            .mock(lastViewedDate: baseDate.daysAgo(100)),
            .mock(lastViewedDate: Date.distantPast),
        ]
    }
    static func stubCollectionForThirdInterval(baseDate: Date) -> [Tab] {
        stubCollectionForSecondInterval(baseDate: baseDate) +
        [
            // MARK: First week
            .mock(lastViewedDate: baseDate.daysAgo(4)),

            // MARK: >1 week
            .mock(lastViewedDate: baseDate.daysAgo(14)),

            // MARK: >2 weeks
            .mock(lastViewedDate: baseDate.daysAgo(15)),

            // MARK: >3 weeks
            .mock(lastViewedDate: baseDate.daysAgo(22))
        ]
    }
}

private enum ParameterName {
    static let newTabCount = "new_tab_count"
    static let tabCount = "tab_count"

    static let tabActive7dCount = "tab_active_7d"
    static let tabInactive1wCount = "tab_inactive_1w"
    static let tabInactive2wCount = "tab_inactive_2w"
    static let tabInactive3wCount = "tab_inactive_3w"
}

private enum Buckets {
    static let inactiveTabs = [
        0...0: "0",
        1...5: "1-5",
        6...10: "6-10",
        11...20: "11-20",
        21...40: "21+"
    ]
}

private extension Date {
    func daysAgo(_ days: Int) -> Date {
        addingTimeInterval(TimeInterval(-days * 86400))
    }
}
