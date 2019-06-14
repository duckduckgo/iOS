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

    func testWhenEnoughPagesVisitedAndEnoughNetworksDetectedThenShouldShow() {
        let leaderboard = NetworkLeaderboard()
        
        for _ in 0 ..< 11 {
            for i in 0 ..< 3 {
                leaderboard.incrementCount(forNetworkNamed: "google\(i).com")
            }
        }
        
        XCTAssertEqual(33, leaderboard.pagesVisited())
        XCTAssertEqual(3, leaderboard.networksDetected().count)
        XCTAssertTrue(leaderboard.shouldShow())
    }

    func testWhenNotEnoughSitesVisitedButEnoughNetworksDetectedThenShouldNotShow() {
        let leaderboard = NetworkLeaderboard()
        for i in 0 ..< 3 {
            leaderboard.incrementCount(forNetworkNamed: "google\(i).com")
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
        leaderboard.pageVisited()
        XCTAssertNotNil(leaderboard.startDate)
    }

    func testWhenNoSitesVisitedStartDateIsNil() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertNil(leaderboard.startDate)
    }

    func testWhenSitesVisitedTotalSitesVistedReturnsCorrectNumber() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.incrementCount(forNetworkNamed: "Network 1")
        leaderboard.incrementCount(forNetworkNamed: "Network 2")
        leaderboard.incrementCount(forNetworkNamed: "Network 1")
        XCTAssertEqual(3, leaderboard.pagesVisited())
    }

    func testWhenSitesVisitedNetworksDetectedReturnsThemInOrderOfCountDescending() {
        let leaderboard = NetworkLeaderboard()
        
        leaderboard.incrementCount(forNetworkNamed: "google.com")
        leaderboard.incrementCount(forNetworkNamed: "tracker.com")
        leaderboard.incrementCount(forNetworkNamed: "google.com")

        let networks = leaderboard.networksDetected()
        XCTAssertEqual("google.com", networks[0].name)
        XCTAssertEqual(2, networks[0].detectedOnCount)

        XCTAssertEqual("tracker.com", networks[1].name)
        XCTAssertEqual(1, networks[1].detectedOnCount)

    }

    func testWhenSingleSiteVisitedAndSingleNetworkDetectedNetworkIsReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.incrementCount(forNetworkNamed: "google.com")
        let networks = leaderboard.networksDetected()
        XCTAssertEqual(1, networks.count)
        XCTAssertEqual("google.com", networks[0].name)
        XCTAssertEqual(1, networks[0].detectedOnCount)
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
