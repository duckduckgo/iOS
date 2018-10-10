//
//  DisconnectMeTrackerTests.swift
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

import XCTest
@testable import Core

class DisconnectMeTrackerTests: XCTestCase {

    struct Constants {
        static let gtmUrl = "http://www.googletagmanager.com"
        static let yahooAnswersUrl = "http://www.yahooanswers.com"
        static let googleNetwork = "Google"
        static let yahooNetwork = "Yahoo!"
    }

    func testWhenDictionaryHasTrackersCanFilterByCategory() {
        let trackers = [
            "Tracker 1": DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .analytics),
            "Tracker 2": DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .advertising),
            "Tracker 3": DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .analytics),
            "Tracker 4": DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .social)
        ]

        let filtered = trackers.filter(byCategory: [ .social, .advertising ])

        XCTAssertEqual(2, filtered.count)
        XCTAssertTrue(filtered.contains(where: { $0.value.category == .social }))
        XCTAssertTrue(filtered.contains(where: { $0.value.category == .advertising }))
    }

    func testWhenTrackersWithSameUrlAndNetworkAndCategoryThenEqualAndHashSame() {
        let lhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .social)
        let rhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .social)
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(lhs.hash, rhs.hash)
    }

    func testWhenTrackersWithSameUrlAndNetworkAndDifferentCategoryThenNotEqualAndHashNotSame() {
        let lhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork, category: .analytics)
        let rhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hash, rhs.hash)
    }

    func testWhenTrackersWithDifferentUrlAnSameNetworkThenNotEqualAndHashNotSame() {
        let lhs = DisconnectMeTracker(url: Constants.yahooAnswersUrl, networkName: Constants.googleNetwork)
        let rhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hash, rhs.hash)
    }

    func testWhenTrackersWithSameUrlAndDifferentNetworkThenNotEqualAndHashNotSame() {
        let lhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork)
        let rhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.yahooNetwork)
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs.hash, rhs.hash)
    }

    func testWhenTrackersWithSameUrlAndNetworkThenEqualAndHashSame() {
        let lhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork)
        let rhs = DisconnectMeTracker(url: Constants.gtmUrl, networkName: Constants.googleNetwork)
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(lhs.hash, rhs.hash)
    }

}
