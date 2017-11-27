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
        static let google = URL(string: "https://google.com")!
        static let googlemail = URL(string: "https://googlemail.com")!
        static let tracker = "http://www.atracker.com"
        static let differentTracker = "http://www.anothertracker.com"
    }
    
    struct TrackerMock {
        static let tracker = Tracker(url: Url.tracker, networkName: Url.tracker)
        static let differentTracker = Tracker(url: Url.differentTracker, networkName: Url.differentTracker)
    }

    func testWhenAssociatedUrlHasTosThenTosReturned() {
        let tracker = Tracker(url: "googlemail.com", networkName: "Google", parentUrl: URL(string: "http://google.com"))
        let testee = SiteRating(url: Url.googlemail, disconnectMeTrackers: [tracker.url: tracker])
        XCTAssertNotNil(testee.termsOfService)
    }

    func testWhenAssociatedDomainExistsParentUrlDomainIsReturned() {
        let tracker = Tracker(url: "googlemail.com", networkName: "Google", parentUrl: URL(string: "http://google.com"))
        let testee = SiteRating(url: Url.googlemail, disconnectMeTrackers: [tracker.url: tracker])
        XCTAssertEqual("google.com", testee.associatedDomain(for: "googlemail.com"))
    }

    func testWhenUrlContainHostThenInitSucceeds() {
        let testee = SiteRating(url: Url.withHost)
        XCTAssertNotNil(testee)
    }
    
    func testWhenHttpThenHttpsIsFalse() {
        let testee = SiteRating(url: Url.http)
        XCTAssertFalse(testee.https)
    }
    
    func testWhenHttpsThenHttpsIsTrue() {
        let testee = SiteRating(url: Url.https)
        XCTAssertTrue(testee.https)
    }
    
    func testCountsAreInitiallyZero() {
        let testee = SiteRating(url: Url.https)
        XCTAssertEqual(testee.totalTrackersDetected, 0)
        XCTAssertEqual(testee.uniqueTrackersDetected, 0)
        XCTAssertEqual(testee.totalTrackersBlocked, 0)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 0)
    }
    
    func testWhenUniqueTrackersAreBlockedThenAllDetectionAndBlockCountsIncremenet() {
        let testee = SiteRating(url: Url.https)
        testee.trackerDetected(TrackerMock.tracker, blocked: true)
        testee.trackerDetected(TrackerMock.differentTracker, blocked: true)
        XCTAssertEqual(testee.totalTrackersDetected, 2)
        XCTAssertEqual(testee.uniqueTrackersDetected, 2)
        XCTAssertEqual(testee.totalTrackersBlocked, 2)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 2)
    }
    
    func testWhenRepeatTrackersAreBlockedThenUniqueCountsOnlyIncrementOnce() {
        let testee = SiteRating(url: Url.https)
        testee.trackerDetected(TrackerMock.tracker, blocked: true)
        testee.trackerDetected(TrackerMock.tracker, blocked: true)
        XCTAssertEqual(testee.totalTrackersDetected, 2)
        XCTAssertEqual(testee.uniqueTrackersDetected, 1)
        XCTAssertEqual(testee.totalTrackersBlocked, 2)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 1)
    }
    
    func testWhenNotBlockerThenDetectedCountsIncrementButBlockCountsDoNot() {
        let testee = SiteRating(url: Url.https)
        testee.trackerDetected(TrackerMock.tracker, blocked: false)
        XCTAssertEqual(testee.totalTrackersDetected, 1)
        XCTAssertEqual(testee.uniqueTrackersDetected, 1)
        XCTAssertEqual(testee.totalTrackersBlocked, 0)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 0)
    }

    func testWhenUrlHasTosThenTosReturned() {
        let testee = SiteRating(url: Url.google)
        XCTAssertNotNil(testee.termsOfService)
    }
    
    func testWhenUrlDoeNotHaveTosThenTosIsNil() {
        let testee = SiteRating(url: Url.http)
        XCTAssertNil(testee.termsOfService)
    }
    
    func testUniqueMajorTrackersDetected() {
        let tracker = Tracker(url: "googlemail.com", networkName: "Google")
        let testee = SiteRating(url: Url.googlemail, disconnectMeTrackers: [tracker.url: tracker])
        testee.trackerDetected(tracker, blocked: false)
        XCTAssertEqual(1, testee.uniqueMajorTrackerNetworksDetected)
        XCTAssertEqual(0, testee.uniqueMajorTrackerNetworksBlocked)
    }

    func testUniqueMajorTrackersBlocked() {
        let tracker = Tracker(url: "googlemail.com", networkName: "Google")
        let testee = SiteRating(url: Url.googlemail, disconnectMeTrackers: [tracker.url: tracker])
        testee.trackerDetected(tracker, blocked: true)
        XCTAssertEqual(1, testee.uniqueMajorTrackerNetworksBlocked)
    }
}
