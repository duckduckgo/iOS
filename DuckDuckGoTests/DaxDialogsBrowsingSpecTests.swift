//
//  DaxDialogsBrowsingSpecTests.swift
//  UnitTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class DaxDialogsBrowsingSpecTests: XCTestCase {
    
    func testWhenSiteIsOwnedByMajorTrackerIsFormattedThenContainsNamesDomainAndPercentage() {
        let majorTracker1 = "TestTracker1"
        let domain = "testtracker.com"
        let percent = 34.3
        let message = DaxDialogs.BrowsingSpec.siteOwnedByMajorTracker.format(args: domain, majorTracker1, percent).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains("34%"))
        XCTAssertTrue(message.contains(domain))
        XCTAssertEqual(3, message.countInstances(of: majorTracker1))
    }
    
    func testWhenSiteIsMajorTrackerIsFormattedThenContainsNameAndPercentage() {
        let majorTracker1 = "TestTracker1"
        let percent = 34.3
        let message = DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: majorTracker1, percent).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains("34%"))
        XCTAssertEqual(2, message.countInstances(of: majorTracker1))
    }
    
    func testWhenTwoMajorTrackersWithNoOthersTrackersIsFormattedThenContainsTrackerNamesAndCount() {
        let majorTracker1 = "TestTracker1"
        let majorTracker2 = "TestTracker2"
        let count = 6
        let message = DaxDialogs.BrowsingSpec.withTwoMajorTrackersAndOthers.format(args: majorTracker1, majorTracker2, count).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(majorTracker2))
        XCTAssertTrue(message.contains("\(count)"))
    }

    func testWhenTwoMajorTrackersWithNoOtherTrackersIsFormattedThenContainsTrackerNames() {
        let majorTracker1 = "TestTracker1"
        let majorTracker2 = "TestTracker2"
        let message = DaxDialogs.BrowsingSpec.withTwoMajorTrackers.format(args: majorTracker1, majorTracker2).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(majorTracker2))
    }

    func testWhenOneMajorTrackerWithOtherTrackersIsFormattedThenContainsTrackerNamesAndCount() {
        let majorTracker = "TestTracker"
        let count = 4
        let message = DaxDialogs.BrowsingSpec.withOneMajorTrackerAndOthers.format(args: majorTracker, count).message
        XCTAssertTrue(message.contains(majorTracker))
        XCTAssertTrue(message.contains("\(count)"))
    }

    func testWhenOneMajorTrackerWithNoOtherTrackersIsFormattedThenContainsTrackerName() {
        let majorTracker = "TestTracker"
        let message = DaxDialogs.BrowsingSpec.withOneMajorTracker.format(args: majorTracker).message
        XCTAssertTrue(message.contains(majorTracker))
    }
    
}

// From: https://stackoverflow.com/a/49547114/73479
fileprivate extension String {
    func countInstances(of stringToFind: String) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }
}
