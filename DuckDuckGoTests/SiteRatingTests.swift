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
    
    var testee = SiteRating()
    
    func testWhenInitalisedThenScoreIsOne() {
        XCTAssertEqual(1, testee.siteScore)
    }
    
    func testWhenHttpThenScoreIsOne() {
        testee.https = false
        XCTAssertEqual(1, testee.siteScore)
    }
    
    func testWhenHttpsThenScoreIsZero() {
        testee.https = true
        XCTAssertEqual(0, testee.siteScore)
    }
    
    func testWhenOneStandardTrackerThenScoreIsTwo() {
        testee.trackers = trackers(qty: 1)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenOneMajorTrackerThenScoreIsThree() {
        testee.trackers = trackers(qty: 0, majorQty: 1)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenTenStandardTrackersThenScoreIsTwo() {
        testee.trackers = trackers(qty: 10)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenTenTrackerIncludingMajorThenScoreIsThree() {
        testee.trackers = trackers(qty: 5, majorQty: 5)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenStandardTrackersThenScoreIsThree() {
        testee.trackers = trackers(qty: 11)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenTrackersIncludingMajorThenScoreIsFour() {
        testee.trackers = trackers(qty: 6, majorQty: 5)
        XCTAssertEqual(4, testee.siteScore)
    }
    
    func trackers(qty: Int, majorQty: Int = 0) -> [Tracker] {
        var trackers = [Tracker]()
        for _ in 0..<qty {
            trackers.append(tracker)
        }
        for _ in 0..<majorQty {
            trackers.append(majorTracker)
        }
        return trackers
    }
    
    var tracker: Tracker {
        return Tracker(url: "aurl.com", parentDomain: "someSmallAdNetwork.com")
    }
    
    var majorTracker: Tracker {
        return Tracker(url: "aurl.com", parentDomain: "facebook.com")
    }
    
}
