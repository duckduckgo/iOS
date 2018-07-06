//
//  PrivacyProtectionTrackerNetworksTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Foundation
import XCTest
@testable import DuckDuckGo
@testable import Core

class PrivacyProtectionTrackerNetworksTests: XCTestCase {

    func testWhenNetworkNotKnownSectionHasNoRows() {
        let trackers = [DetectedTracker(url: "http://tracker1.com", networkName: nil, category: nil, blocked: false): 1]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("tracker1.com", sections[0].name)
        XCTAssertEqual(0, sections[0].rows.count)
    }

    func testNetworkHasMultipleTrackersThenGroupedCorrectly() {

        let trackers = [
            DetectedTracker(url: "http://tracker1.com", networkName: "Network 1", category: nil, blocked: false): 1,
            DetectedTracker(url: "http://tracker2.com", networkName: "Network 1", category: nil, blocked: false): 1,
            DetectedTracker(url: "http://tracker3.com", networkName: "Network 2", category: nil, blocked: false): 1
        ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(2, sections.count)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual(1, sections[1].rows.count)
    }

    func testWhenMajorNetworkDetectedSectionBuiltWithRowPerUniqueMajorTracker() {

        let trackers = [
            DetectedTracker(url: "http://tracker1.com", networkName: "Major 1", category: "Category 1", blocked: true): 1,
            DetectedTracker(url: "http://tracker2.com", networkName: "Major 1", category: "Category 2", blocked: true): 1,
            DetectedTracker(url: "http://tracker3.com", networkName: "Minor", category: "Category 3", blocked: true): 1
        ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(2, sections.count)
        XCTAssertEqual("Major 1", sections[0].name)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
    }

    func testWhenMajorNetworksInTrackersThenSortedToTopOrderedByPercentage() {

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", networkName: "Minor", category: "Category 1", blocked: true): 1,
            DetectedTracker(url: "http://tracker1.com", networkName: "Major 1", category: "Category 2", blocked: true): 1,
            DetectedTracker(url: "http://tracker2.com", networkName: "Major 2", category: "Category 3", blocked: true): 1
        ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers, majorTrackerNetworksStore: MockMajorTrackerNetworkStore()).build()

        XCTAssertEqual(3, sections.count)
        XCTAssertEqual("Major 2", sections[0].name)
        XCTAssertEqual("Major 1", sections[1].name)
        XCTAssertEqual("Minor", sections[2].name)

    }

    func testWhenMajorTrackersThenDomainsAreSorted() {

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", networkName: "Major 1", category: "Category 1", blocked: true): 1,
            DetectedTracker(url: "http://tracker1.com", networkName: "Major 1", category: "Category 2", blocked: true): 1,
            DetectedTracker(url: "http://tracker2.com", networkName: "Major 1", category: "Category 3", blocked: true): 1
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers, majorTrackerNetworksStore: MockMajorTrackerNetworkStore()).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("Major 1", sections[0].name)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
        XCTAssertEqual("tracker3.com", sections[0].rows[2].name)

    }

    func testWhenMinorTrackersThenDomainsAreSorted() {

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", networkName: "Minor", category: "Category 1", blocked: true): 1,
            DetectedTracker(url: "http://tracker1.com", networkName: "Minor", category: "Category 2", blocked: true): 1,
            DetectedTracker(url: "http://tracker2.com", networkName: "Minor", category: "Category 3", blocked: true): 1
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers, majorTrackerNetworksStore: MockMajorTrackerNetworkStore()).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("Minor", sections[0].name)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
        XCTAssertEqual("tracker3.com", sections[0].rows[2].name)

    }

    func testWhenUnknownTrackerNetworkThenDomainsAreSortedAndHaveOwnSection() {

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", networkName: nil, category: "Category 1", blocked: true): 1,
            DetectedTracker(url: "http://tracker1.com", networkName: nil, category: "Category 2", blocked: true): 1,
            DetectedTracker(url: "http://tracker2.com", networkName: nil, category: "Category 3", blocked: true): 1
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers, majorTrackerNetworksStore: MockMajorTrackerNetworkStore()).build()

        XCTAssertEqual(3, sections.count)
        XCTAssertEqual("tracker1.com", sections[0].name)
        XCTAssertEqual("tracker2.com", sections[1].name)
        XCTAssertEqual("tracker3.com", sections[2].name)

    }

    func testWhenNoProtocolThenTrackerAddedByDomain() {

        let trackers = [
            DetectedTracker(url: "//tracker.com", networkName: nil, category: "Category 1", blocked: true): 1
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers, majorTrackerNetworksStore: MockMajorTrackerNetworkStore()).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("tracker.com", sections[0].name)
    }

    func testWhenNoDomainThenTrackerIgnored() {

        let trackers = [
            DetectedTracker(url: "/tracker3.js", networkName: nil, category: "Category 1", blocked: true): 1
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers, majorTrackerNetworksStore: MockMajorTrackerNetworkStore()).build()

        XCTAssertEqual(0, sections.count)
    }

}

private class MockMajorTrackerNetworkStore: MajorTrackerNetworkStore {

    let networks = [
        MajorTrackerNetwork(name: "Major 1", domain: "major1.com", percentageOfPages: 25),
        MajorTrackerNetwork(name: "Major 2", domain: "major2.com", percentageOfPages: 50)
    ]

    func network(forName name: String) -> MajorTrackerNetwork? {
        return networks.first(where: { $0.name == name })
    }

    func network(forDomain domain: String) -> MajorTrackerNetwork? {
        return networks.first(where: { $0.domain == domain })
    }

}
