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
        
        static let duckduckgo = URL(string: "http://duckduckgo.com")!
    }
    
    struct MockTracker {
        static let standard = Tracker(url: "trackerexample.com", parentDomain: "someSmallAdNetwork.com")
        static let ipTracker = Tracker(url: "http://192.168.5.10/abcd", parentDomain: "someSmallAdNetwork.com")
        static let google = Tracker(url: "trackerexample.com", parentDomain: "google.com")
    }

    fileprivate let classATOS = MockTermsOfServiceStore().add(domain: "example.com", classification: .a, score: -100)
    fileprivate let disconnectMeTrackers = ["googletracker.com": MockTracker.google]

    override func setUp() {
        SiteRatingCache.shared.reset()
    }

    func testWhenSiteIsGoogleTrackerAndHTTPSAndClassATOSScoreIsTen() {
        let networkStore = MockMajorTrackerNetworkStore().add(domain: Url.googleNetwork.host!, network: MajorTrackerNetwork(domain: "google.com", perentageOfPages: 84))
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS, majorTrackerNetworkStore: networkStore)!
        let score = testee.siteScore()
        XCTAssertEqual(10, score?.after)
        XCTAssertEqual(10, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndPositiveTOSScoreIsTwo() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: nil, score: 10))!
        let score = testee.siteScore()
        XCTAssertEqual(2, score?.after)
        XCTAssertEqual(2, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndNegativeTOSScoreIsZero() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: nil, score: -10))!
        let score = testee.siteScore()
        XCTAssertEqual(0, score?.after)
        XCTAssertEqual(0, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndClassETOSScoreIsThree() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: .e, score: 0))!
        let score = testee.siteScore()
        XCTAssertEqual(3, score?.after)
        XCTAssertEqual(3, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndClassDTOSScoreIsTwo() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: .d, score: 0))!
        let score = testee.siteScore()
        XCTAssertEqual(2, score?.after)
        XCTAssertEqual(2, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndClassCTOSScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: .c, score: 0))!
        let score = testee.siteScore()
        XCTAssertEqual(1, score?.after)
        XCTAssertEqual(1, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndClassBTOSScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: .b, score: 0))!
        let score = testee.siteScore()
        XCTAssertEqual(1, score?.after)
        XCTAssertEqual(1, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndClassATOSScoreIsZero() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: "example.com", classification: .a, score: 0))!
        let score = testee.siteScore()
        XCTAssertEqual(0, score?.after)
        XCTAssertEqual(0, score?.before)
    }

    func testWhenNoTrackersAndHTTPSAndNoTOSScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore())!
        let score = testee.siteScore()
        XCTAssertEqual(1, score?.after)
        XCTAssertEqual(1, score?.before)
    }

}

fileprivate class MockTermsOfServiceStore: TermsOfServiceStore {

    var terms = [String : TermsOfService]()

    func add(domain: String, classification: TermsOfService.Classification?, score: Int) -> MockTermsOfServiceStore {
        terms[domain] = TermsOfService(classification: classification, score: score)
        return self
    }

}

fileprivate class MockMajorTrackerNetworkStore: MajorTrackerNetworkStore {

    var networks = [String: MajorTrackerNetwork]()

    func network(forDomain domain: String) -> MajorTrackerNetwork? {
        return networks[domain]
    }

    func add(domain: String, network: MajorTrackerNetwork) -> MajorTrackerNetworkStore {
        networks[domain] = network
        return self
    }

}

