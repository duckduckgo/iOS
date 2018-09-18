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
        GradeCache.shared.reset()
    }

    func testWhenUrlBelongsToMajorNetworkThenIsMajorNetworkReturnsTrue() {
        let mockPrevalenceStore = MockPrevalenceStore(prevalences: ["TrickyAds": 100.0], major: true)
        
        let disconnectMeTrackers = [Url.http.host!: DisconnectMeTracker(url: Url.http.absoluteString,
                                                                           networkName: "TrickyAds",
                                                                           category: .social ) ]
        
        let testee = SiteRating(url: Url.http,
                                disconnectMeTrackers: disconnectMeTrackers,
                                termsOfServiceStore: classATOS,
                                prevalenceStore: mockPrevalenceStore)
        
        XCTAssertTrue(testee.isMajorTrackerNetwork)
    }
    
    func testWhenNetworkNameAndCategoryExistsForUppercasedDomainTheyAreReturned() {
        let disconnectMeTrackers = ["sometracker.com": DisconnectMeTracker(url: Url.http.absoluteString,
                                                                           networkName: "TrickyAds",
                                                                           category: .social ) ]
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "SOMETRACKER.com")
        XCTAssertEqual("TrickyAds", nameAndCategory.networkName)
        XCTAssertEqual("Social", nameAndCategory.category)
    }

    func testWhenNetworkNameAndCategoryExistsForDomainTheyAreReturned() {
        let disconnectMeTrackers = ["sometracker.com": DisconnectMeTracker(url: Url.http.absoluteString,
                                                                           networkName: "TrickyAds",
                                                                           category: .social ) ]
        let testee = SiteRating(url: Url.googleNetwork, disconnectMeTrackers: disconnectMeTrackers, termsOfServiceStore: classATOS)
        let nameAndCategory = testee.networkNameAndCategory(forDomain: "sometracker.com")
        XCTAssertEqual("TrickyAds", nameAndCategory.networkName)
        XCTAssertEqual("Social", nameAndCategory.category)
    }

    func testWhenWorseScoreIsCachedForBeforeScoreItIsUsed() {
        let scores = Grade.Scores(site: Grade.Score(grade: .d, httpsScore: 0, privacyScore: 0, score: 66, trackerScore: 0),
                                  enhanced: Grade.Score(grade: .a, httpsScore: 0, privacyScore: 0, score: 0, trackerScore: 0))
        
        _ = GradeCache.shared.add(url: Url.https, scores: scores)

        let testee = SiteRating(url: Url.https, termsOfServiceStore: MockTermsOfServiceStore())
        let site = testee.scores.site
        XCTAssertEqual(66, site.score)
    }

}

private class MockTermsOfServiceStore: TermsOfServiceStore {

    var terms = [String: TermsOfService]()

    func add(domain: String,
             classification: TermsOfService.Classification?,
             score: Int,
             goodReasons: [String] = [],
             badReasons: [String] = []) -> MockTermsOfServiceStore {
        
        terms[domain] = TermsOfService(classification: classification, score: score, goodReasons: goodReasons, badReasons: badReasons)
        return self
    }

}

private struct MockPrevalenceStore: PrevalenceStore {

    var prevalences: [String: Double]
    var major: Bool

    func isMajorNetwork(named: String?) -> Bool {
        return major
    }
    
}
