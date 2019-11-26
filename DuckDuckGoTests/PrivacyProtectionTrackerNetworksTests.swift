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
import XCTest
@testable import DuckDuckGo
@testable import Core

class PrivacyProtectionTrackerNetworksTests: XCTestCase {
    
    func testWhenNetworkNotKnownSectionHasNoRows() {
        let trackers = [DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: nil, blocked: false)]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("tracker1.com", sections[0].name)
        XCTAssertEqual(0, sections[0].rows.count)
    }

    func testNetworkHasMultipleTrackersThenGroupedCorrectly() {
        
        let entity1 = Entity(displayName: "Entity 1", domains: nil, prevalence: 100)
        let entity2 = Entity(displayName: "Entity 2", domains: nil, prevalence: 0.01)

        let trackers = [
            DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: entity1, blocked: false),
            DetectedTracker(url: "http://tracker2.com", knownTracker: nil, entity: entity1, blocked: false),
            DetectedTracker(url: "http://tracker3.com", knownTracker: nil, entity: entity2, blocked: false)
        ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(2, sections.count)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual(1, sections[1].rows.count)
    }

    func testWhenMajorNetworkDetectedSectionBuiltWithRowPerUniqueMajorTracker() {

        let major1 = Entity(displayName: "Major 1", domains: nil, prevalence: 100)
        let major2 = Entity(displayName: "Major 2", domains: nil, prevalence: 99)

        let trackers = [
            DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: major1, blocked: true),
            DetectedTracker(url: "http://tracker2.com", knownTracker: nil, entity: major1, blocked: true),
            DetectedTracker(url: "http://tracker3.com", knownTracker: nil, entity: major2, blocked: true)
        ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(2, sections.count)
        XCTAssertEqual("Major 1", sections[0].name)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
    }

    func testWhenMajorNetworksInTrackersThenSortedToTopOrderedByPercentage() {

        let major1 = Entity(displayName: "Major 1", domains: nil, prevalence: 99)
        let major2 = Entity(displayName: "Major 2", domains: nil, prevalence: 100)
        let minor = Entity(displayName: "Minor", domains: nil, prevalence: 0.01)

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", knownTracker: nil, entity: minor, blocked: true),
            DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: major1, blocked: true),
            DetectedTracker(url: "http://tracker2.com", knownTracker: nil, entity: major2, blocked: true)
        ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(3, sections.count)
        XCTAssertEqual("Major 2", sections[0].name)
        XCTAssertEqual("Major 1", sections[1].name)
        XCTAssertEqual("Minor", sections[2].name)

    }

    func testWhenMajorTrackersThenDomainsAreSorted() {

        let major = Entity(displayName: "Major 1", domains: nil, prevalence: 100)

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", knownTracker: nil, entity: major, blocked: true),
            DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: major, blocked: true),
            DetectedTracker(url: "http://tracker2.com", knownTracker: nil, entity: major, blocked: true)
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("Major 1", sections[0].name)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
        XCTAssertEqual("tracker3.com", sections[0].rows[2].name)

    }

    func testWhenMinorTrackersThenDomainsAreSorted() {

        let minor = Entity(displayName: "Minor", domains: nil, prevalence: 0.01)

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", knownTracker: nil, entity: minor, blocked: true),
            DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: minor, blocked: true),
            DetectedTracker(url: "http://tracker2.com", knownTracker: nil, entity: minor, blocked: true)
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("Minor", sections[0].name)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
        XCTAssertEqual("tracker3.com", sections[0].rows[2].name)

    }

    func testWhenUnknownTrackerNetworkThenDomainsAreSortedAndHaveOwnSection() {

        let trackers = [
            DetectedTracker(url: "http://tracker3.com", knownTracker: nil, entity: nil, blocked: true),
            DetectedTracker(url: "http://tracker1.com", knownTracker: nil, entity: nil, blocked: true),
            DetectedTracker(url: "http://tracker2.com", knownTracker: nil, entity: nil, blocked: true)
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(3, sections.count)
        XCTAssertEqual("tracker1.com", sections[0].name)
        XCTAssertEqual("tracker2.com", sections[1].name)
        XCTAssertEqual("tracker3.com", sections[2].name)

    }

    func testWhenNoProtocolThenTrackerAddedByDomain() {

        let trackers = [
            DetectedTracker(url: "//tracker.com", knownTracker: nil, entity: nil, blocked: true)
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("tracker.com", sections[0].name)
    }

    func testWhenNoDomainThenTrackerIgnored() {

        let trackers = [
            DetectedTracker(url: "/tracker3.js", knownTracker: nil, entity: nil, blocked: true)
            ]

        let sections = SiteRatingTrackerNetworkSectionBuilder(trackers: trackers).build()

        XCTAssertEqual(0, sections.count)
    }

}
