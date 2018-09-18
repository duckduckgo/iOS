//
//  PrivacyProtectionTrackerNetworksTests.swift
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
@testable import DuckDuckGo

class SiteRatingPrivacyProtectionExtensionTests: XCTestCase {

    struct Constants {

        static let pageURL = URL(string: "https://example.com")!
        static let majorTracker = DisconnectMeTracker(url: Constants.pageURL.absoluteString, networkName: "major")

    }

    func testMultipleMajorNetworksBlockedReturnsPluralText() {
        let rating = SiteRating(url: Constants.pageURL,
                                disconnectMeTrackers: [: ],
                                termsOfServiceStore: MockTermsOfServiceStore(),
                                prevalenceStore: MockPrevalenceStore(prevalences: [:], major: false))
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "major1", category: nil, blocked: true))
        rating.trackerDetected(DetectedTracker(url: "otherurl", networkName: "major2", category: nil, blocked: true))
        XCTAssertTrue(rating.majorNetworksBlockedText().contains("Trackers Blocked"))
    }

    func testMultipleMajorNetworksDetectedReturnsPluralText() {
        let rating = SiteRating(url: Constants.pageURL,
                                disconnectMeTrackers: [: ],
                                termsOfServiceStore: MockTermsOfServiceStore(),
                                prevalenceStore: MockPrevalenceStore(prevalences: [:], major: false))
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "major1", category: nil, blocked: false))
        rating.trackerDetected(DetectedTracker(url: "otherurl", networkName: "major2", category: nil, blocked: false))
        XCTAssertTrue(rating.majorNetworksDetectedText().contains("Trackers Found"))
    }

    func testMultipleNetworksBlockedReturnsPluralText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor1", category: nil, blocked: true))
        rating.trackerDetected(DetectedTracker(url: "otherurl", networkName: "minor2", category: nil, blocked: true))
        XCTAssertTrue(rating.networksBlockedText().contains("Trackers Blocked"))
    }

    func testMultipleNetworksDetectedReturnsPluralText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor1", category: nil, blocked: false))
        rating.trackerDetected(DetectedTracker(url: "otherurl", networkName: "minor2", category: nil, blocked: false))
        XCTAssertTrue(rating.networksDetectedText().contains("Trackers Found"))
    }

    func testSingleMajorNetworkBlockedReturnsSinglularText() {
        let rating = SiteRating(url: Constants.pageURL,
                                disconnectMeTrackers: [ Constants.pageURL.host!: Constants.majorTracker],
                                termsOfServiceStore: MockTermsOfServiceStore(),
                                prevalenceStore: MockPrevalenceStore(prevalences: [ "major": 100.0 ], major: true))
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "major", category: nil, blocked: true))
        XCTAssertTrue(rating.majorNetworksBlockedText().contains("Tracker Blocked"))
    }

    func testSingleMajorNetworkDetectedReturnsSinglularText() {
        let rating = SiteRating(url: Constants.pageURL,
                                disconnectMeTrackers: [ Constants.pageURL.host!: Constants.majorTracker],
                                termsOfServiceStore: MockTermsOfServiceStore(),
                                prevalenceStore: MockPrevalenceStore(prevalences: [ "major": 100.0 ], major: true))
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "major", category: nil, blocked: false))
        XCTAssertTrue(rating.majorNetworksDetectedText().contains("Tracker Found"))
    }

    func testSingleNetworkBlockedReturnsSinglularText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor", category: nil, blocked: true))
        XCTAssertTrue(rating.networksBlockedText().contains("Tracker Blocked"))
    }

    func testSingleNetworkDetectedReturnsSinglularText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor", category: nil, blocked: false))
        XCTAssertTrue(rating.networksDetectedText().contains("Tracker Found"))
    }

}

private struct MockPrevalenceStore: PrevalenceStore {

    var prevalences: [String: Double]
    var major: Bool

    func isMajorNetwork(named: String?) -> Bool {
        return major
    }
    
}

private class MockTermsOfServiceStore: TermsOfServiceStore {

    var terms = [String: TermsOfService]()

}
