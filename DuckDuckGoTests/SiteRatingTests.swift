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
        static let blockedTracker = DetectedTracker(url: Url.tracker, networkName: Url.tracker, category: "tracker", blocked: true)
        static let unblockedTracker = DetectedTracker(url: Url.tracker, networkName: Url.tracker, category: "tracker", blocked: false)
        static let differentTracker = DetectedTracker(url: Url.differentTracker,
                                                      networkName: Url.differentTracker,
                                                      category: "tracker",
                                                      blocked: true)
    }

    func testWhenEntityHasHighPrevalenceThenGradeSetCorrectly() {
        
        let testee = SiteRating(url: Url.googlemail, entityMapping: MockEntityMapping(entity: "Google"))
        XCTAssertEqual(10, testee.scores.site.score)
        
    }
    
    func testWhenUrlHasTosThenTosReturned() {
        let term = TermsOfService(classification: .d, score: -100, reasons: TermsOfService.Reasons(good: [], bad: [ "bad reason" ]))
        let tosdrStore = MockTermsOfServiceStore(terms: [Url.googlemail.host!: term ])
        let entityMapping = MockEntityMapping(entity: "Google")
        let privacyPractices = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMapping: entityMapping)
        let testee = SiteRating(url: Url.googlemail, entityMapping: entityMapping, privacyPractices: privacyPractices)
        XCTAssertEqual(.poor, testee.privacyPractice.summary)
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
        testee.trackerDetected(TrackerMock.blockedTracker)
        testee.trackerDetected(TrackerMock.differentTracker)
        XCTAssertEqual(testee.totalTrackersDetected, 2)
        XCTAssertEqual(testee.uniqueTrackersDetected, 2)
        XCTAssertEqual(testee.totalTrackersBlocked, 2)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 2)
    }

    func testWhenRepeatTrackersAreBlockedThenUniqueCountsOnlyIncrementOnce() {
        let testee = SiteRating(url: Url.https)
        testee.trackerDetected(TrackerMock.blockedTracker)
        testee.trackerDetected(TrackerMock.blockedTracker)
        XCTAssertEqual(testee.totalTrackersDetected, 2)
        XCTAssertEqual(testee.uniqueTrackersDetected, 1)
        XCTAssertEqual(testee.totalTrackersBlocked, 2)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 1)
    }

    func testWhenNotBlockerThenDetectedCountsIncrementButBlockCountsDoNot() {
        let testee = SiteRating(url: Url.https)
        testee.trackerDetected(TrackerMock.unblockedTracker)
        XCTAssertEqual(testee.totalTrackersDetected, 1)
        XCTAssertEqual(testee.uniqueTrackersDetected, 1)
        XCTAssertEqual(testee.totalTrackersBlocked, 0)
        XCTAssertEqual(testee.uniqueTrackersBlocked, 0)
    }

    func testWhenUrlDoeNotHaveTosThenPrivacyPracticesSummaryIsUnknown() {
        let testee = SiteRating(url: Url.http)
        XCTAssertEqual(.unknown, testee.privacyPractice.summary)
    }

    func testUniqueMajorTrackersDetected() {
        let tracker = DetectedTracker(url: "googlemail.com", networkName: "Google", category: nil, blocked: false)
        let testee = SiteRating(url: Url.googlemail, entityMapping: MockEntityMapping(entity: "Google"))
        testee.trackerDetected(tracker)
        XCTAssertEqual(1, testee.uniqueMajorTrackerNetworksDetected)
        XCTAssertEqual(0, testee.uniqueMajorTrackerNetworksBlocked)
    }

    func testUniqueMajorTrackersBlocked() {
        let tracker = DetectedTracker(url: "googlemail.com", networkName: "Google", category: nil, blocked: true)
        let testee = SiteRating(url: Url.googlemail, entityMapping: MockEntityMapping(entity: "Google"))
        testee.trackerDetected(tracker)
        XCTAssertEqual(1, testee.uniqueMajorTrackerNetworksBlocked)
    }

    func testWhenHttpsAndIsForcedThenEncryptionTypeIsForced() {
        let testee = SiteRating(url: Url.https, httpsForced: true)
        XCTAssertEqual(.forced, testee.encryptionType)
    }

    func testWhenHttpsAndNotHasOnlySecureContentAndIsForcedThenEncryptionTypeIsMixed() {
        let testee = SiteRating(url: Url.https, httpsForced: true)
        testee.hasOnlySecureContent = false
        XCTAssertEqual(.mixed, testee.encryptionType)
    }

    func testWhenHttpsAndNotHasOnlySecureContentThenEncryptionTypeIsMixed() {
        let testee = SiteRating(url: Url.https)
        testee.hasOnlySecureContent = false
        XCTAssertEqual(.mixed, testee.encryptionType)
    }

    func testWhenHttpsThenEncryptionTypeIsEncrypted() {
        let testee = SiteRating(url: Url.https)
        XCTAssertEqual(.encrypted, testee.encryptionType)
    }

    func testWhenHttpThenEncryptionTypeIsUnencrypted() {
        let testee = SiteRating(url: Url.http)
        XCTAssertEqual(.unencrypted, testee.encryptionType)
    }

}

private class MockEntityMapping: EntityMapping {
    
    private var entity: String?
    
    init(entity: String?) {
        self.entity = entity
    }
    
    override func findEntity(forURL url: URL) -> String? {
        return entity
    }
    
}

private struct MockTermsOfServiceStore: TermsOfServiceStore {
    
    var terms: [String: TermsOfService]
    
}
