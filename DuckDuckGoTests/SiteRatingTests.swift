//
//  SiteRatingTests.swift
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

class SiteRatingTests: XCTestCase {

    override func setUp() {
        SiteRatingCache.shared.reset()
    }
    
    func testWhenUrlContainHostThenInitSucceeds() {
        let testee = SiteRating(url: urlWithHost)
        XCTAssertNotNil(testee)
    }
    
    func testWhenUrlDoesNotContainHostThenInitFails() {
        let testee = SiteRating(url: urlWithoutHost)
        XCTAssertNil(testee)
    }
    
    func testWhenHttpThenScoreIsOne() {
        let testee = SiteRating(url: httpUrl)!
        XCTAssertEqual(1, testee.siteScore)
    }
    
    func testWhenHttpsThenScoreIsZero() {
        let testee = SiteRating(url: httpsUrl)!
        XCTAssertEqual(0, testee.siteScore)
    }
    
    func testWhenOneStandardTrackerThenScoreIsTwo() {
        var testee = SiteRating(url: httpUrl)!
        testee.trackers = trackers(qty: 1)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenOneMajorTrackerThenScoreIsThree() {
        var testee = SiteRating(url: httpUrl)!
        testee.trackers = trackers(qty: 0, majorQty: 1)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenTenStandardTrackersThenScoreIsTwo() {
        var testee = SiteRating(url: httpUrl)!
        testee.trackers = trackers(qty: 10)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenTenTrackerIncludingMajorThenScoreIsThree() {
        var testee = SiteRating(url: httpUrl)!
        testee.trackers = trackers(qty: 5, majorQty: 5)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenStandardTrackersThenScoreIsThree() {
        var testee = SiteRating(url: httpUrl)!
        testee.trackers = trackers(qty: 11)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenTrackersIncludingMajorThenScoreIsFour() {
        var testee = SiteRating(url: httpUrl)!
        testee.trackers = trackers(qty: 6, majorQty: 5)
        XCTAssertEqual(4, testee.siteScore)
    }
    
    func testWhenNewRatingIsLowerThanCachedRatingThenCachedRatingIsUsed() {
        let _ = SiteRatingCache.shared.register(domain: httpUrl.host!, score: 100)
        let testee = SiteRating(url: httpUrl)!
        XCTAssertEqual(100, testee.siteScore)
    }
    
    func trackers(qty: Int, majorQty: Int = 0) -> [Tracker: Int] {
        var trackers = [Tracker: Int]()
        if qty > 0 {
            trackers[tracker] = qty
        }
        if majorQty > 0 {
            trackers[majorTracker] = majorQty
        }
        return trackers
    }
    
    var urlWithoutHost: URL {
        return URL(string: "nohost")!
    }
    
    var urlWithHost: URL {
        return URL(string: "http://host")!
    }

    var httpUrl: URL {
        return URL(string: "http://example.com")!
    }

    var httpsUrl: URL {
        return URL(string: "https://example.com")!
    }
    
    var tracker: Tracker {
        return Tracker(url: "aurl.com", parentDomain: "someSmallAdNetwork.com")
    }
    
    var majorTracker: Tracker {
        return Tracker(url: "aurl.com", parentDomain: "facebook.com")
    }
}
