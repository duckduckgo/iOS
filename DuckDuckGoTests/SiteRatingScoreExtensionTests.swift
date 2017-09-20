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

    struct Url {
        static let http = URL(string: "http://example.com")!
        static let https = URL(string: "https://example.com")!
        static let googleNetwork = URL(string: "http://google.com")!
        static let wikipedia = URL(string: "http://wikipedia.org")!
        static let soundcloud = URL(string: "http://soundcloud.com")!
        static let delicious = URL(string: "http://delicious.com")!
    }
    
    struct MockTracker {
        static let standard = Tracker(url: "example.com", parentDomain: "someSmallAdNetwork.com")
        static let ipTracker = Tracker(url: "http://192.168.5.10/abcd", parentDomain: "someSmallAdNetwork.com")
        static let network = Tracker(url: "example.com", parentDomain: "facebook.com")
    }
    
    override func setUp() {
        SiteRatingCache.shared.reset()
    }
    
    func testWhenHttpsThenScoreIsZero() {
        let testee = SiteRating(url: Url.https)!
        XCTAssertEqual(0, testee.siteScore)
    }
    
    func testWhenHttpThenScoreIsOne() {
        let testee = SiteRating(url: Url.http)!
        XCTAssertEqual(1, testee.siteScore)
    }
    
    func testWhenUrlHasTermsClassificationOfAThenScoreIsDecrementedToZero() {
        let testee = SiteRating(url: Url.wikipedia)!
        XCTAssertEqual(0, testee.siteScore)
    }

    func testWhenUrlHasTermsHasClassificationOfBThenScoreIsUnchangedAtOne() {
        let testee = SiteRating(url: Url.soundcloud)!
        XCTAssertEqual(1, testee.siteScore)
    }
    
    func testWhenUrlHasTermsClassificationOfDThenScoreIsIncrementedToTwo() {
        let testee = SiteRating(url: Url.delicious)!
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenUrlIsInGoogleNetworkThenScoreIsSix() {
        let testee = SiteRating(url: Url.googleNetwork)!
        XCTAssertEqual(7, testee.siteScore)
    }
    
    func testWhenOneStandardTrackerThenScoreIsTwo() {
        let testee = SiteRating(url: Url.http)!
        addTrackers(siteRating: testee, qty: 1)
        XCTAssertEqual(2, testee.siteScore)
    }
    
    func testWhenOneIpTrackerThenScoreIsThree() {
        let testee = SiteRating(url: Url.http )!
        addTrackers(siteRating: testee, qty: 0, majorQty: 0, ipQty: 1)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenOneMajorTrackerThenScoreIsThree() {
        let testee = SiteRating(url: Url.http)!
        addTrackers(siteRating: testee, qty: 0, majorQty: 1)
        XCTAssertEqual(3, testee.siteScore)
    }
    
    func testWhenTenTrackersIncludingMajorThenScoreIsThree() {
        let testee = SiteRating(url: Url.http)!
        addTrackers(siteRating: testee, qty: 5, majorQty: 5)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenStandardTrackersThenScoreIsThree() {
        let testee = SiteRating(url: Url.http)!
        addTrackers(siteRating: testee, qty: 11)
        XCTAssertEqual(3, testee.siteScore)
    }

    func testWhenElevenTrackersIncludingMajorThenScoreIsFour() {
        let testee = SiteRating(url: Url.http)!
        addTrackers(siteRating: testee, qty: 6, majorQty: 5)
        XCTAssertEqual(4, testee.siteScore)
    }
    
    // Test all the adverse contions together
    func testWhenUrlIsHttpInGoogleNetworkWithElevenTrackersIncludingiPAndMajorNetworkThenScoreIsEleven() {
        let testee = SiteRating(url: Url.googleNetwork)!
        addTrackers(siteRating: testee, qty: 5, majorQty: 3, ipQty: 3)
        XCTAssertEqual(11, testee.siteScore)
    }
    
    func testWhenNewRatingIsLowerThanCachedRatingThenCachedRatingIsUsed() {
        _ = SiteRatingCache.shared.add(url: Url.http, score: 100)
        let testee = SiteRating(url: Url.http)!
        XCTAssertEqual(100, testee.siteScore)
    }
    
    func addTrackers(siteRating: SiteRating, qty: Int, majorQty: Int = 0, ipQty : Int = 0) {
        for _ in 0..<qty {
            siteRating.trackerDetected(MockTracker.standard, blocked: true)
        }
        for _ in 0..<majorQty {
            siteRating.trackerDetected(MockTracker.network, blocked: true)
        }
        for _ in 0..<ipQty {
            siteRating.trackerDetected(MockTracker.ipTracker, blocked: true)
        }
    }
}
