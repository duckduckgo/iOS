//
//  NetworkLeaderboardTests.swift
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

class NetworkLeaderboardTests: XCTestCase {

    override func setUp() {
        NetworkLeaderboard().reset()
    }
    
    func testWhenFirstAccessingLeaderboardThenItHasAStartDateOfToday() {
        let leaderboard = NetworkLeaderboard()
        guard let startDate = leaderboard.startDate else {
            XCTFail("No start date on leaderboard")
            return
        }

        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(startDate))
    }
    
    func testWhenPagesWithTrackersCalledThenCorrectNumberIsReturned() {
        let leaderboard = NetworkLeaderboard()
        for _ in 0 ..< 15 {
            leaderboard.incrementPagesWithTrackers()
        }
        XCTAssertEqual(15, leaderboard.pagesWithTrackers())
    }
    
    func testWhenHttpsUpgradesCalledThenCorrectNumberIsReturned() {
        let leaderboard = NetworkLeaderboard()
        for _ in 0 ..< 15 {
            leaderboard.incrementHttpsUpgrades()
        }
        XCTAssertEqual(15, leaderboard.httpsUpgrades())
    }

    func testWhenEnoughPagesVisitedAndEnoughNetworksDetectedThenShouldShow() {
        let leaderboard = NetworkLeaderboard()

        for i in 0 ..< 3 {
            leaderboard.incrementDetectionCount(forNetworkNamed: "google\(i).com")
        }

        for _ in 0 ..< 30 {
            leaderboard.incrementPagesLoaded()
        }
        
        XCTAssertEqual(30, leaderboard.pagesVisited())
        XCTAssertEqual(3, leaderboard.networksDetected().count)
        XCTAssertTrue(leaderboard.shouldShow())
    }

    func testWhenNotEnoughSitesVisitedButEnoughNetworksDetectedThenShouldNotShow() {
        let leaderboard = NetworkLeaderboard()
        for i in 0 ..< 3 {
            leaderboard.incrementDetectionCount(forNetworkNamed: "google\(i).com")
        }

        XCTAssertEqual(3, leaderboard.networksDetected().count)
        XCTAssertFalse(leaderboard.shouldShow())
    }

    func testWhenNotEnoughSitesVisitedOrNetworksDetectedThenShouldNotShow() {

        let leaderboard = NetworkLeaderboard()
        XCTAssertFalse(leaderboard.shouldShow())

    }

    func testWhenFirstSiteVisitedStartDateIsSet() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.incrementPagesLoaded()
        XCTAssertNotNil(leaderboard.startDate)
    }

    func testWhenSitesVisitedNetworksDetectedReturnsThemInOrderOfCountDescending() {
        let leaderboard = NetworkLeaderboard()
        
        leaderboard.incrementDetectionCount(forNetworkNamed: "google.com")
        leaderboard.incrementDetectionCount(forNetworkNamed: "tracker.com")
        leaderboard.incrementDetectionCount(forNetworkNamed: "google.com")

        let networks = leaderboard.networksDetected()
        XCTAssertEqual("google.com", networks[0].name)
        XCTAssertEqual(2, networks[0].detectedOnCount)

        XCTAssertEqual("tracker.com", networks[1].name)
        XCTAssertEqual(1, networks[1].detectedOnCount)

    }

    func testWhenSingleSiteVisitedAndSingleNetworkDetectedNetworkIsReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.incrementDetectionCount(forNetworkNamed: "google.com")
        let networks = leaderboard.networksDetected()
        XCTAssertEqual(1, networks.count)
        XCTAssertEqual("google.com", networks[0].name)
        XCTAssertEqual(1, networks[0].detectedOnCount)
    }
    
    func testWhenSingleSiteVisitedAndMultipleTrackersDetectedNetworkIsReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.incrementDetectionCount(forNetworkNamed: "google.com")
        
        for _ in 0 ..< 10 {
            leaderboard.incrementTrackersCount(forNetworkNamed: "google.com")
        }
        
        let networks = leaderboard.networksDetected()
        XCTAssertEqual(1, networks.count)
        XCTAssertEqual("google.com", networks[0].name)
        XCTAssertEqual(1, networks[0].detectedOnCount)
        XCTAssertEqual(10, networks[0].trackersCount)
    }

    func testWhenLeaderboardIsNewNoNetworksDetected() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertEqual([], leaderboard.networksDetected())
    }

    func testWhenLeaderboardIsNewSitesVisitedIsZero() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertEqual(0, leaderboard.pagesVisited())
    }

}
