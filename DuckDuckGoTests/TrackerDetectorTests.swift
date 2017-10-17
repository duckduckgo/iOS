//
//  TrackerDetectorTests.swift
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
@testable import Core

class TrackersDetectorTests: XCTestCase {
    
    private var testee: TrackerDetector!
    private var mockConifguartion: MockContentBlockerConfigurationStore!
    
    struct UrlString {
        static let tracker = "http://tracker.com"
        static let trackerSubdomain = "http://subdomin.tracker.com"
        static let differentTracker = "http://anothertracker.com"
        static let allowedTracker = "http://contenttracker.com"
        static let looksLikeATracker = "http://innocentnontracker.com"
        static let standard = "http://standard.com"
        static let document =  "http://www.wordpress.com"
    }
    
    struct Url {
        static let tracker = URL(string: UrlString.tracker)!
        static let trackerSubdomain = URL(string: UrlString.trackerSubdomain)!
        static let differentTracker = URL(string: UrlString.differentTracker)!
        static let allowedTracker = URL(string: UrlString.allowedTracker)!
        static let standard = URL(string: UrlString.standard)!
        static let looksLikeATracker = URL(string: UrlString.looksLikeATracker)!
        static let document = URL(string: UrlString.document)!
    }
    
    private func trackers() -> [Tracker] {
        return [
            Tracker(url: UrlString.tracker, parentDomain: UrlString.tracker, category: .advertising),
            Tracker(url: UrlString.differentTracker, parentDomain: UrlString.differentTracker, category: .analytics),
            Tracker(url: UrlString.allowedTracker, parentDomain: UrlString.differentTracker, category: .content)
        ]
    }
    
    override func setUp() {
        mockConifguartion = MockContentBlockerConfigurationStore()
        testee = TrackerDetector(configuration: mockConifguartion, disconnectTrackers: trackers())
    }

    func testWhenBlockerEnabledAndUrlIsTrackerThenTrackerIsBlocked() {
        let policy = testee.policy(forUrl: Url.tracker, document: Url.document)
        XCTAssertNotNil(policy.tracker)
        XCTAssertTrue(policy.block)
    }

    func testAllowedTrackerUrlThenNotBlocked() {
        let policy = testee.policy(forUrl: Url.allowedTracker, document: Url.document)
        XCTAssertNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }
    
    func testWhenNonTrackerUrlThenNotBlocked() {
        let policy = testee.policy(forUrl: Url.standard, document: Url.document)
        XCTAssertNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }
    
    func testWhenNonTrackerUrlWithSimilarEndingThenNotBlocked() {
        let policy = testee.policy(forUrl: Url.looksLikeATracker, document: Url.document)
        XCTAssertNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }
    
    func testWhenBlockerDisabledThenTrackerNotBlocked() {
        mockConifguartion.enabled = false
        let policy = testee.policy(forUrl: Url.tracker, document: Url.document)
        XCTAssertNotNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }
    
    func testWhenFirstPartyWithSameUrlThenNotBlocked() {
        let policy = testee.policy(forUrl: Url.tracker, document: Url.tracker)
        XCTAssertNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }
    
    func testWhenFirstPartySubdomainTrackerThenNotBlocked() {
        let policy = testee.policy(forUrl: Url.trackerSubdomain, document: Url.tracker)
        XCTAssertNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }
    
    func testWhenFirstPartyParentDomainTrackerThenNotBlocked() {
        let policy = testee.policy(forUrl: Url.tracker, document: Url.trackerSubdomain)
        XCTAssertNil(policy.tracker)
        XCTAssertFalse(policy.block)
    }

}
