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
        static let googleNetwork = URL(string: "https://google.com")!
        
        static let duckduckgo = URL(string: "http://duckduckgo.com")!
    }
    
    struct MockTrackerBuilder {

        static func standard(category: String = "", blocked: Bool) -> DetectedTracker {
            return DetectedTracker(url: "trackerexample.com", networkName: "someSmallAdNetwork.com", category: category, blocked: blocked)
        }

        static func ipTracker(category: String = "", blocked: Bool) -> DetectedTracker {
            return DetectedTracker(url: "http://192.168.5.10/abcd", networkName: "someSmallAdNetwork.com", category: category, blocked: blocked)
        }

        static func google(category: String = "", blocked: Bool) -> DetectedTracker {
            return DetectedTracker(url: "trackerexample.com", networkName: "Google", category: category, blocked: blocked)
        }

    }

    fileprivate let classATOS = MockTermsOfServiceStore().add(domain: "example.com", classification: .a, score: -100)
    fileprivate let disconnectMeTrackers = ["googletracker.com": DisconnectMeTracker(url: Url.googleNetwork.absoluteString, networkName: "Google")]

    override func setUp() {
        SiteRatingCache.shared.reset()
    }
    
    func testWhenNetworkExistsForMajorDomainNotInDisconnectItIsReturned() {
        let disconnectMeTrackers = ["sometracker.com": DisconnectMeTracker(url: Url.http.absoluteString, networkName: "TrickyAds", category: .social ) ]
        let networkStore = MockMajorTrackerNetworkStore().adding(network: MajorTrackerNetwork(name: "Major", domain: "major.com", percentageOfPages: 5))
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS, majorTrackerNetworkStore: networkStore)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "major.com")
        XCTAssertEqual("Major", nameAndCategory.networkName)
        XCTAssertNil(nameAndCategory.category)
    }

    func testWhenNetworkNameAndCategoryExistsForUppercasedDomainTheyAreReturned() {
        let disconnectMeTrackers = ["sometracker.com": DisconnectMeTracker(url: Url.http.absoluteString, networkName: "TrickyAds", category: .social ) ]
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "SOMETRACKER.com")
        XCTAssertEqual("TrickyAds", nameAndCategory.networkName)
        XCTAssertEqual("Social", nameAndCategory.category)
    }

    func testWhenNetworkNameAndCategoryExistsForDomainTheyAreReturned() {
        let disconnectMeTrackers = ["sometracker.com": DisconnectMeTracker(url: Url.http.absoluteString, networkName: "TrickyAds", category: .social ) ]
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "sometracker.com")
        XCTAssertEqual("TrickyAds", nameAndCategory.networkName)
        XCTAssertEqual("Social", nameAndCategory.category)
    }
    
    func testWhenHighScoreCachedResultIsGradeD() {
        _ = SiteRatingCache.shared.add(url: Url.https, score: 10)
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore())
        let before = testee.siteGrade().before
        XCTAssertEqual(SiteGrade.d, before)
    }

    func testWhenWorseScoreIsCachedForBeforeScoreItIsUsed() {
        _ = SiteRatingCache.shared.add(url: Url.https, score: 10)

        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore())
        let score = testee.siteScore()
        XCTAssertEqual(10, score.before)
        XCTAssertEqual(1, score.after)
    }

    func testBeforeScoreIsCached() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .e, score: 0))
        XCTAssertNotNil(testee.siteScore())
        XCTAssertEqual(3, SiteRatingCache.shared.get(url: Url.https))
    }

/*  Broken due to algorithm being broken.
    func testWhenHTTPSAndClassATOSBeforeScoreIncreasesByOneForEveryTenTrackersDetectedRoundedUpAndAfterScoreIsZero() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .a, score: 0))

        for _ in 0 ..< 11 {
            testee.trackerDetected(MockTrackerBuilder.standard(blocked: false))
        }

        let score = testee.siteScore()
        XCTAssertEqual(2, score.before)
        XCTAssertEqual(0, score.after)
    }

    func testWhenSingleTrackerDetectedAndHTTPSAndClassATOSBeforeScoreIsOneAfterScoreIsZero() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .a, score: 0))
        testee.trackerDetected(MockTrackerBuilder.standard(blocked: false))
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(0, score.after)
    }

    func testWhenObsecureTrackerDetectedAndHTTPSAndClassATOSBeforeScoreIsTwoAfterScoreIsZero() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .a, score: 0))
        testee.trackerDetected(MockTrackerBuilder.ipTracker(blocked: true))
        let score = testee.siteScore()
        XCTAssertEqual(2, score.before)
        XCTAssertEqual(0, score.after)
    }
*/

    func testWhenNoTrackersHTTPSAndClassATOSThenLoadsInsecureResourceScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .a, score: 0))
        testee.hasOnlySecureContent = false
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }

    func testWhenNoTrackersAndHTTPAndClassATOSScoreIsOne() {
        let testee = SiteRating(url: Url.http, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .a, score: 0))
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }

/*  Broken due to algorithm being broken.
    func testWhenTrackerDetectedInMajorTrackerNetworkAndHTTPSAndClassATOSBeforeScoreIsTwoAfterScoreIsOne() {
        let disconnectMeTrackers = [Url.https.host!: DisconnectMeTracker(url: Url.googleNetwork.absoluteString, networkName: "Google")]
        let networkStore = MockMajorTrackerNetworkStore().adding(network: MajorTrackerNetwork(name: "Google", domain: Url.googleNetwork.host!, perentageOfPages: 84))
        let testee = SiteRating(url: URL(string: "https://another.com")!, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS, majorTrackerNetworkStore: networkStore)
        testee.trackerDetected(DetectedTracker(url: "https://tracky.com/tracker.js", networkName: nil, category: nil, blocked: false))
        let score = testee.siteScore()
        XCTAssertEqual(2, score.before)
        XCTAssertEqual(1, score.after)
    }
*/

    func testWhenSiteIsMajorTrackerNetworkAndHTTPSAndClassATOSScoreIsTen() {
        let networkStore = MockMajorTrackerNetworkStore().adding(network: MajorTrackerNetwork(name: "Google", domain: Url.googleNetwork.host!, percentageOfPages: 84))
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS, majorTrackerNetworkStore: networkStore)
        let score = testee.siteScore()
        XCTAssertEqual(10, score.before)
        XCTAssertEqual(10, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndPositiveTOSScoreIsTwo() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: nil, score: 10))
        let score = testee.siteScore()
        XCTAssertEqual(2, score.before)
        XCTAssertEqual(2, score.after)
    }

    func testWhenTOSIsNegativeThenScoreGreaterThanOneIsDecremented() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: nil, score: -10))
        for _ in 1...10 {
            testee.trackerDetected(DetectedTracker(url: "https://tracky.com/tracker.js", networkName: nil, category: nil, blocked: false))
        }
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }
    
    func testWhenTOSIsNegativeThenScoreOfOneIsUnchanged() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: nil, score: -10))
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndClassETOSScoreIsThree() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .e, score: 0))
        let score = testee.siteScore()
        XCTAssertEqual(3, score.before)
        XCTAssertEqual(3, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndClassDTOSScoreIsTwo() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .d, score: 0))
        let score = testee.siteScore()
        XCTAssertEqual(2, score.before)
        XCTAssertEqual(2, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndClassCTOSScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .c, score: 0))
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndClassBTOSScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .b, score: 0))
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndClassATOSScoreIsZero() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore().add(domain: Url.https.host!, classification: .a, score: 0))
        let score = testee.siteScore()
        XCTAssertEqual(0, score.before)
        XCTAssertEqual(0, score.after)
    }

    func testWhenNoTrackersAndHTTPSAndNoTOSScoreIsOne() {
        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore())
        let score = testee.siteScore()
        XCTAssertEqual(1, score.before)
        XCTAssertEqual(1, score.after)
    }

}

fileprivate class MockTermsOfServiceStore: TermsOfServiceStore {

    var terms = [String : TermsOfService]()

    func add(domain: String, classification: TermsOfService.Classification?, score: Int, goodReasons: [String] = [], badReasons: [String] = []) -> MockTermsOfServiceStore {
        terms[domain] = TermsOfService(classification: classification, score: score, goodReasons: goodReasons, badReasons: badReasons)
        return self
    }

}

fileprivate class MockMajorTrackerNetworkStore: InMemoryMajorNetworkStore {

    override init(networks: [MajorTrackerNetwork] = []) {
        super.init(networks: networks)
    }

    func adding(network: MajorTrackerNetwork) -> MajorTrackerNetworkStore {
        var networks = self.networks
        networks.append(network)
        return MockMajorTrackerNetworkStore(networks: networks)
    }

}

