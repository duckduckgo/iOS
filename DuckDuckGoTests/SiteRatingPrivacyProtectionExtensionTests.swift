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

    }

    func testMultipleNetworkBlockedReturnsPluralText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor1", category: nil, blocked: true))
        rating.trackerDetected(DetectedTracker(url: "otherurl", networkName: "minor2", category: nil, blocked: true))
        XCTAssertEqual(rating.networksBlockedText(), String(format: DuckDuckGo.UserText.privacyProtectionTrackersBlocked, 2))
    }

    func testMultipleNetworkDetectedReturnsPluralText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor1", category: nil, blocked: false))
        rating.trackerDetected(DetectedTracker(url: "otherurl", networkName: "minor2", category: nil, blocked: false))
        XCTAssertEqual(rating.networksDetectedText(), String(format: DuckDuckGo.UserText.privacyProtectionTrackersFound, 2))
    }

    func testSingleNetworkBlockedReturnsSinglularText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor", category: nil, blocked: true))
        XCTAssertEqual(rating.networksBlockedText(), DuckDuckGo.UserText.privacyProtectionTrackerBlocked)
    }

    func testSingleNetworkDetectedReturnsSinglularText() {
        let rating = SiteRating(url: Constants.pageURL)
        rating.trackerDetected(DetectedTracker(url: "someurl", networkName: "minor", category: nil, blocked: false))
        XCTAssertEqual(rating.networksDetectedText(), DuckDuckGo.UserText.privacyProtectionTrackerFound)
    }

}
