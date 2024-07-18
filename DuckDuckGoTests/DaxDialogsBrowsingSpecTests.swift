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
import PrivacyDashboard
@testable import DuckDuckGo

class DaxDialogsBrowsingSpecTests: XCTestCase {

    func testWhenSiteIsOwnedByMajorTrackerIsFormattedThenContainsNamesDomainAndPercentage() {
        let majorTracker1 = "TestTracker1"
        let domain = "testtracker.com"
        let message = DaxDialogs.BrowsingSpec.siteOwnedByMajorTracker.format(args: domain, majorTracker1).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(domain))
        XCTAssertEqual(2, message.countInstances(of: majorTracker1))
        XCTAssertTrue(message.contains("\n"))
    }
    
    func testWhenSiteIsMajorTrackerIsFormattedThenContainsNameAndDomain() {
        let majorTracker1 = "TestTracker1"
        let domain = "testtracker.com"
        let message = DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: majorTracker1, domain).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(domain))
        XCTAssertEqual(2, message.countInstances(of: majorTracker1))
        XCTAssertTrue(message.contains("\n"))
    }

    func testWhenTwoTrackersAndCountOfOneThenMessageContainsTrackersAndCount() {
        let majorTracker1 = "TestTracker1"
        let majorTracker2 = "TestTracker2"
        let count = 1
        let message = DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: count, majorTracker1, majorTracker2).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(majorTracker2))
        XCTAssertTrue(message.contains("\(count)"))
        
        // Ensure new line character is properly encoded and included in the string.
        // For the plural localizable strings created using stringsdict, we have to embed new lines directly in the plist file - '\n' chars are escaped and don't work.
        XCTAssertTrue(message.contains("\n"))
        XCTAssertFalse(message.contains("\\n"))
    }

    func testWhenTwoTrackersAndCountOfMoreThanOneThenMessageContainsTrackersAndCount() {
        let majorTracker1 = "TestTracker1"
        let majorTracker2 = "TestTracker2"
        let count = 6
        let message = DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: count, majorTracker1, majorTracker2).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(majorTracker2))
        XCTAssertTrue(message.contains("\(count)"))
        XCTAssertTrue(message.contains("\n"))
        XCTAssertFalse(message.contains("\\n"))
    }

    func testWhenTwoTrackersThenMessageContainsBothTrackers() {
        let majorTracker1 = "TestTracker1"
        let majorTracker2 = "TestTracker2"
        let message = DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, majorTracker1, majorTracker2).message
        XCTAssertTrue(message.contains(majorTracker1))
        XCTAssertTrue(message.contains(majorTracker2))
        XCTAssertTrue(message.contains("\n"))
        XCTAssertFalse(message.contains("\\n"))
    }

    func testWhenSingleTrackerThenMessageContainsTracker() {
        let majorTracker = "TestTracker"
        let message = DaxDialogs.BrowsingSpec.withOneTracker.format(args: majorTracker).message
        XCTAssertTrue(message.contains(majorTracker))
    }

}

// From: https://stackoverflow.com/a/49547114/73479
private extension String {
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
