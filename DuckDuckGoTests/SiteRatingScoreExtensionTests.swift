//
//  SiteRatingScoreExtensionTests.swift
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

class SiteRatingScoreExtensionTests: XCTestCase {

    override func setUp() {
        SiteRatingCache.shared.reset()
    }
    
    func testWhenHttpsThenScoreIsZero() {
        let testee = SiteRating(url: httpsUrl)!
        XCTAssertEqual(0, testee.siteScore)
    }
    
    func testWhenHttpThenScoreIsOne() {
        let testee = SiteRating(url: httpUrl)!
        XCTAssertEqual(1, testee.siteScore)
    }
    
    func testWhenOneStandardTrackerThenScoreIsTwo() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 1)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenOneIpTrackerThenScoreIsThree() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 0, majorQty: 0, ipQty: 1)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenOneMajorTrackerThenScoreIsThree() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 0, majorQty: 1)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenTenStandardTrackersThenScoreIsTwo() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 10)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenTenTrackersIncludingMajorThenScoreIsThree() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 5, majorQty: 5)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenTenTrackersIncludingiPThenScoreIsThree() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 5, majorQty: 0, ipQty: 5)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenStandardTrackersThenScoreIsThree() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 11)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenTrackersIncludingMajorThenScoreIsFour() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 6, majorQty: 5)
        XCTAssertEqual(4, testee.siteScore)
    }
    
    func testWhenElevenTrackersIncludingiPThenScoreIsFour() {
        let testee = SiteRating(url: httpUrl)!
        addTrackers(siteRating: testee, qty: 6, majorQty: 0, ipQty: 5)
        XCTAssertEqual(4, testee.siteScore)
    }
    
    func testWhenNewRatingIsLowerThanCachedRatingThenCachedRatingIsUsed() {
        _ = SiteRatingCache.shared.add(domain: httpUrl.host!, score: 100)
        let testee = SiteRating(url: httpUrl)!
        XCTAssertEqual(100, testee.siteScore)
    }
    
    func addTrackers(siteRating: SiteRating, qty: Int, majorQty: Int = 0, ipQty : Int = 0) {
        for _ in 0..<qty {
            siteRating.trackerDetected(tracker, blocked: true)
        }
        for _ in 0..<majorQty {
            siteRating.trackerDetected(majorTracker, blocked: true)
        }
        for _ in 0..<ipQty {
            siteRating.trackerDetected(ipTracker, blocked: true)
        }
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
    
    var ipTracker: Tracker {
        return Tracker(url: "http://192.168.5.10/abcd", parentDomain: "someSmallAdNetwork.com")
    }
    
    var majorTracker: Tracker {
        return Tracker(url: "aurl.com", parentDomain: "facebook.com")
    }
}
