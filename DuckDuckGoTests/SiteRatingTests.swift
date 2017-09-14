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
    
    struct Url {
        static let noHost = URL(string: "nohost")!
        static let withHost = URL(string: "http://host")!
        static let http = URL(string: "http://example.com")!
        static let https = URL(string: "https://example.com")!
        static let tracker = "http://www.atracker.com"
        static let differentTracker = "http://www.anothertracker.com"
    }
    
    struct TrackerMock {
        static let tracker = SiteRating.Tracker(url: Url.tracker, parent: nil)
        static let differentTracker = SiteRating.Tracker(url: Url.differentTracker, parent: nil)
    }

    func testWhenUrlContainHostThenInitSucceeds() {
        let testee = SiteRating(url: Url.withHost)
        XCTAssertNotNil(testee)
    }
    
    func testWhenUrlDoesNotContainHostThenInitFails() {
        let testee = SiteRating(url: Url.noHost)
        XCTAssertNil(testee)
    }
    
    func testWhenHttpThenHttpsIsFalse() {
        let testee = SiteRating(url: Url.http)!
        XCTAssertFalse(testee.https)
    }
    
    func testWhenHttpsThenHttpsIsTrue() {
        let testee = SiteRating(url: Url.https)!
        XCTAssertTrue(testee.https)
    }
    
    func testCountsAreInitiallyZero() {
        let testee = SiteRating(url: Url.https)!
        XCTAssertEqual(testee.totalItemsDetected, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
        XCTAssertEqual(testee.totalItemsBlocked, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
    }
    
    func testWhenUniqueTrackersAreBlockedThenAllDetectionAndBlockCountsIncremenet() {
        let testee = SiteRating(url: Url.https)!
        testee.trackerDetected(TrackerMock.tracker, blocked: true)
        testee.trackerDetected(TrackerMock.differentTracker, blocked: true)
        XCTAssertEqual(testee.totalItemsDetected, 2)
        XCTAssertEqual(testee.uniqueItemsDetected, 2)
        XCTAssertEqual(testee.totalItemsBlocked, 2)
        XCTAssertEqual(testee.uniqueItemsBlocked, 2)
    }
    
    func testWhenRepeatTrackersAreBlockedThenUniqueCountsOnlyIncrementOnce() {
        let testee = SiteRating(url: Url.https)!
        testee.trackerDetected(TrackerMock.tracker, blocked: true)
        testee.trackerDetected(TrackerMock.tracker, blocked: true)
        XCTAssertEqual(testee.totalItemsDetected, 2)
        XCTAssertEqual(testee.uniqueItemsDetected, 1)
        XCTAssertEqual(testee.totalItemsBlocked, 2)
        XCTAssertEqual(testee.uniqueItemsBlocked, 1)
    }
    
    func testWhenNotBlockerThenDetectedCountsIncrementButBlockCountsDoNot() {
        let testee = SiteRating(url: Url.https)!
        testee.trackerDetected(TrackerMock.tracker, blocked: false)
        XCTAssertEqual(testee.totalItemsDetected, 1)
        XCTAssertEqual(testee.uniqueItemsDetected, 1)
        XCTAssertEqual(testee.totalItemsBlocked, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
    }
}
