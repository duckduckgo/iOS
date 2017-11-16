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

    func testWhenSubsequentSiteVisitedStartDateIsUnchanged() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "duckduckgo.com")
        let startDate = leaderboard.startDate
        leaderboard.visited(domain: "example.com")
        XCTAssertEqual(startDate, leaderboard.startDate)
    }

    func testWhenFirstSiteVisitedStartDateIsSet() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "duckduckgo.com")
        XCTAssertNotNil(leaderboard.startDate)
    }

    func testWhenNoSitesVisitedStartDateIsNil() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertNil(leaderboard.startDate)
    }

    func testWhenThreeSitesVisitedAndTwoNetworkDetectedOnOneSiteOneOnAnotherPercentForNamedNetworkIs33() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "ohno.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(33, leaderboard.percentOfSitesWithNetwork(named: "tracker.com"))
    }

    func testWhenThreeSitesVisitedAndTwoNetworkDetectedOnBothOfTwoSiteNetworksDetectedAreReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "ohno.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(["google.com", "tracker.com"], leaderboard.networksDetected().sorted())
    }

    func testWhenThreeSitesVisitedAndTwoNetworkDetectedOnBothOfTwoSiteNetworkPercentIs66() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "ohno.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(66, leaderboard.percentOfSitesWithNetwork())
    }

    func testWhenThreeSitesVisitedAndTwoNetworkDetectedOnTwoSiteNetworkPercentIs66() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "ohno.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(66, leaderboard.percentOfSitesWithNetwork())
    }

    func testWhenThreeSitesVisitedAndTwoNetworkDetectedOnOneSiteNetworkPercentIs33() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "anothernonetworksdetected.com")
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(33, leaderboard.percentOfSitesWithNetwork())
    }

    func testWhenTwoSitesVisitedAndSingleNetworkDetectedOnOneSiteNetworkPercentIs50() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(50, leaderboard.percentOfSitesWithNetwork(named: "google.com"))
    }

    func testWhenTwoSitesVisitedAndSingleNetworkDetectedOnOneSitePercentIs50() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(50, leaderboard.percentOfSitesWithNetwork())
    }

    func testWhenSingleSiteVisitedAndSingleNetworkDetectedNetworkIsReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(["google.com"], leaderboard.networksDetected())
    }

    func testWhenSingleSiteVisitedAndSingleNetworkDetectedNetworkPercentIs100() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(100, leaderboard.percentOfSitesWithNetwork(named: "google.com"))
    }

    func testWhenSingleSiteVisitedAndSingleNetworkDetectedPercentIs100() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(100, leaderboard.percentOfSitesWithNetwork())
    }

    func testWhenSiteVisitedButNoNetworksDetectedPercentIsZero() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "example.com")
        XCTAssertEqual(0, leaderboard.percentOfSitesWithNetwork())
    }

    func testWhenLeaderboardIsNewNoNetworksDetected() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertEqual([], leaderboard.networksDetected())
    }

    func testWhenLeaderboardIsNewPercentIsZero() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertEqual(0, leaderboard.percentOfSitesWithNetwork())
    }

}


