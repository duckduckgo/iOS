//
//  ContentBlockerTests.swift
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

class ContentBlockerTests: XCTestCase {

    private var testee: ContentBlocker!
    private var mockConifguartion: MockContentBlockerConfigurationStore!

    struct UrlString {
        static let tracker = "http://www.atracker.com"
        static let trackerWithPath = "http://www.atracker.com/aPath"
        static let trackerWithAnotherPath = "http://www.atracker.com/anotherPath"
        static let differentTracker = "http://www.anothertracker.com"
        static let standard =  "http://www.facebook.com/path"
        static let document =  "http://www.wordpress.com"
    }
    
    struct Url {
        static let tracker = URL(string: UrlString.tracker)!
        static let trackerWithPath = URL(string: UrlString.trackerWithPath)!
        static let trackerWithAntotherPath = URL(string: UrlString.trackerWithAnotherPath)!
        static let differentTracker = URL(string: UrlString.differentTracker)!
        static let standard = URL(string: UrlString.standard)!
        static let document = URL(string: UrlString.document)!
    }
    
    private func trackers() -> [Tracker] {
        return [
            Tracker(url: UrlString.tracker, parentDomain: UrlString.tracker),
            Tracker(url: UrlString.differentTracker, parentDomain: UrlString.differentTracker)
        ]
    }

    override func setUp() {
        mockConifguartion = MockContentBlockerConfigurationStore()
        mockConifguartion.trackers = trackers()
        testee = ContentBlocker(configuration: mockConifguartion)
    }

    func testCountsAreInitiallyZero() {
        XCTAssertEqual(testee.totalItemsDetected, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
        XCTAssertEqual(testee.totalItemsBlocked, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
    }
    
    func testWhenEnabledThenEnabledIsTrue() {
        testee.enabled = true
        XCTAssertTrue(testee.enabled)
    }

    func testWhenDisbaledThenEnabledIsFalse() {
        testee.enabled = false
        XCTAssertFalse(testee.enabled)
    }
    
    func testWhenTrackerUrlThenBlocked() {
        XCTAssertTrue(testee.block(url: Url.tracker, forDocument: Url.document))
    }
    
    func testWhenBlockerDisabledThenNotBlocked() {
        mockConifguartion.enabled = false
        XCTAssertFalse(testee.block(url: Url.tracker, forDocument: Url.document))
    }

    func testWhenDomainAddedToWhitelistThenNoTrackersBlocked() {
        testee.whitelist(true, domain: Url.document.host!)
        XCTAssertFalse(testee.block(url: Url.tracker, forDocument: Url.document))
    }
    
    func testWhenDomainWhitelistedThenEnabledForDomainIsFalse() {
        let domain = Url.document.host!
        testee.whitelist(true, domain: domain)
        XCTAssertFalse(testee.enabled(forDomain: domain))
    }

    func testWhenDomainRemovedFromWhitelistThenEnabledIsTrue() {
        let domain = Url.document.host!
        testee.whitelist(true, domain: domain)
        testee.whitelist(false, domain: domain)
        XCTAssertTrue(testee.enabled(forDomain: domain))
    }
    
    func testWhenDomainRemovedFromWhitelistThenTrackersBlocked() {
        let domain = Url.document.host!
        testee.whitelist(true, domain: domain)
        testee.whitelist(false, domain: Url.document.host!)
        XCTAssertTrue(testee.block(url: Url.tracker, forDocument: Url.document))
    }
    
    func testWhenFirstPartyUrlThenNotBlocked() {
        XCTAssertFalse(testee.block(url: Url.tracker, forDocument: Url.tracker))
    }
    
    func testWhenNonTrackerUrlThenNotBlocked() {
        XCTAssertFalse(testee.block(url: Url.standard, forDocument: Url.document))
    }

    func testWhenUniqueTrackersAreBlockedThenAllDetectionAndBlockCountsIncremenet() {
        XCTAssertTrue(testee.block(url: Url.tracker, forDocument: Url.document))
        XCTAssertTrue(testee.block(url: Url.differentTracker, forDocument: Url.document))
        XCTAssertEqual(testee.totalItemsDetected, 2)
        XCTAssertEqual(testee.uniqueItemsDetected, 2)
        XCTAssertEqual(testee.totalItemsBlocked, 2)
        XCTAssertEqual(testee.uniqueItemsBlocked, 2)
    }

    func testWhenRepeatTrackersAreBlockedThenUniqueCountsOnlyIncrementOnce() {
        XCTAssertTrue(testee.block(url: Url.tracker, forDocument: Url.document))
        XCTAssertTrue(testee.block(url: Url.tracker, forDocument: Url.document))
        XCTAssertEqual(testee.totalItemsDetected, 2)
        XCTAssertEqual(testee.uniqueItemsDetected, 1)
        XCTAssertEqual(testee.totalItemsBlocked, 2)
        XCTAssertEqual(testee.uniqueItemsBlocked, 1)
    }
    
    func testWhenTrackersWithSameDomainAreBlockedThenUniqueCountsOnlyIncrementOnce() {
        XCTAssertTrue(testee.block(url: Url.trackerWithPath, forDocument: Url.document))
        XCTAssertTrue(testee.block(url: Url.trackerWithAntotherPath, forDocument: Url.document))
        XCTAssertEqual(testee.totalItemsDetected, 2)
        XCTAssertEqual(testee.uniqueItemsDetected, 1)
        XCTAssertEqual(testee.totalItemsBlocked, 2)
        XCTAssertEqual(testee.uniqueItemsBlocked, 1)
    }
    
    func testWhenBlockerDisabledThenDetectedCountsIncrementButBlockCountsDoNot() {
        mockConifguartion.enabled = false
        XCTAssertFalse(testee.block(url: Url.tracker, forDocument: Url.document))
        XCTAssertEqual(testee.totalItemsDetected, 1)
        XCTAssertEqual(testee.uniqueItemsDetected, 1)
        XCTAssertEqual(testee.totalItemsBlocked, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
    }
    
    func testResetClearsCounts() {
        testWhenUniqueTrackersAreBlockedThenAllDetectionAndBlockCountsIncremenet()
        testee.resetMonitoring()
        XCTAssertEqual(testee.totalItemsDetected, 0)
        XCTAssertEqual(testee.uniqueItemsDetected, 0)
        XCTAssertEqual(testee.totalItemsBlocked, 0)
        XCTAssertEqual(testee.uniqueItemsBlocked, 0)
    }
}
