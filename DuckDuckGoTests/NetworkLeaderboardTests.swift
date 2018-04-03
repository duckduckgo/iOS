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

    func testWhenEnoughSitesVisitedAndEnoughNetworksDetectedThenShouldShow() {
        let leaderboard = NetworkLeaderboard()
        for i in 0 ... 30 {
            let domain = "www.site\(i).com"
            leaderboard.visited(domain: domain)
        }

        for i in 0 ..< 3 {
            let domain = "www.site\(i).com"
            leaderboard.network(named: "google\(i).com", detectedWhileVisitingDomain: domain)
        }
        XCTAssertEqual(31, leaderboard.sitesVisited())
        XCTAssertEqual(3, leaderboard.networksDetected().count)
        XCTAssertTrue(leaderboard.shouldShow())
    }

    func testWhenNotEnoughSitesVisitedButEnoughNetworksDetectedThenShouldNotShow() {
        let leaderboard = NetworkLeaderboard()
        for i in 0 ..< 3 {
            let domain = "www.site\(i).com"
            leaderboard.visited(domain: domain)
            leaderboard.network(named: "google\(i).com", detectedWhileVisitingDomain: domain)
        }

        XCTAssertEqual(3, leaderboard.networksDetected().count)
        XCTAssertFalse(leaderboard.shouldShow())
    }

    func testWhenEnoughSitesVisitedButNotEnoughNetworksDetectedThenShouldNotShow() {
        let leaderboard = NetworkLeaderboard()
        for i in 0 ..< 11 {
            let domain = "www.site\(i).com"
            leaderboard.visited(domain: domain)
        }
        XCTAssertEqual(11, leaderboard.sitesVisited())
        XCTAssertFalse(leaderboard.shouldShow())
    }

    func testWhenNotEnoughSitesVisitedOrNetworksDetectedThenShouldNotShow() {

        let leaderboard = NetworkLeaderboard()
        XCTAssertFalse(leaderboard.shouldShow())

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

    func testWhenSitesVisitedTotalSitesVistedReturnsCorrectNumber() {
        let leaderboard = NetworkLeaderboard()
       leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "ohno.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual(3, leaderboard.sitesVisited())
    }

    func testWhenSitesVisitedNetworksDetectedReturnsThemInOrderOfCountDescending() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "nonetworksdetected.com")
        leaderboard.visited(domain: "ohno.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "ohno.com")
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "tracker.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")

        let networks = leaderboard.networksDetected()
        XCTAssertEqual("google.com", networks[0].name)
        XCTAssertEqual(2, networks[0].detectedOnCount)

        XCTAssertEqual("tracker.com", networks[1].name)
        XCTAssertEqual(1, networks[1].detectedOnCount)

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
        XCTAssertEqual(["google.com", "tracker.com"], leaderboard.networksDetected().map( { $0.name! }).sorted())
    }

    func testWhenSingleSiteVisitedMultipleTimesAndSingleNetworkDetectedNetworkIsReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual("google.com", leaderboard.networksDetected()[0].name)
        XCTAssertEqual(1, leaderboard.networksDetected()[0].detectedOn?.count)
    }

    func testWhenSingleSiteVisitedAndSingleNetworkDetectedNetworkIsReturned() {
        let leaderboard = NetworkLeaderboard()
        leaderboard.visited(domain: "example.com")
        leaderboard.network(named: "google.com", detectedWhileVisitingDomain: "example.com")
        XCTAssertEqual("google.com", leaderboard.networksDetected()[0].name)
    }

    func testWhenLeaderboardIsNewNoNetworksDetected() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertEqual([], leaderboard.networksDetected())
    }

    func testWhenLeaderboardIsNewSitesVisitedIsZero() {
        let leaderboard = NetworkLeaderboard()
        XCTAssertEqual(0, leaderboard.sitesVisited())
    }

}


