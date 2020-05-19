//
//  DaxOnboardingTests.swift
//  UnitTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
@testable import Core

class DaxOnboardingTests: XCTestCase {
    
    struct URLs {
        
        static let example = URL(string: "https://www.example.com")!
        static let ddg = URL(string: "https://duckduckgo.com?q=test")!
        static let majorTracker = URL(string: "https://www.facebook.com")!
        static let ownedByMajorTracker = URL(string: "https://www.instagram.com")!

    }
    
    override func setUp() {
        super.setUp()
        UserDefaults.clearStandard()
    }
    
    func testWhenFirstTimeOnSiteThatIsOwnedByTrackerThenShowOwnedByMajorTrackingMessage() {
        let onboarding = DaxOnboarding()
        let siteRating = SiteRating(url: URLs.ownedByMajorTracker)
        XCTAssertEqual(DaxOnboarding.BrowsingSpec.siteOwnedByMajorTracker, onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenSecondTimeOnSiteThatIsMajorTrackerThenShowMajorTrackingMessage() {
        let onboarding = DaxOnboarding()
        let siteRating = SiteRating(url: URLs.majorTracker)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnSiteThatIsMajorTrackerThenShowMajorTrackingMessage() {
        let onboarding = DaxOnboarding()
        let siteRating = SiteRating(url: URLs.majorTracker)
        XCTAssertEqual(DaxOnboarding.BrowsingSpec.siteIsMajorTracker, onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenSecondTimeOnPageWithNoTrackersThenTrackersThenShowNothing() {
        let onboarding = DaxOnboarding()
        let siteRating = SiteRating(url: URLs.example)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnPageWithNoTrackersThenTrackersThenShowNoTrackersMessage() {
        let onboarding = DaxOnboarding()
        let siteRating = SiteRating(url: URLs.example)
        XCTAssertEqual(DaxOnboarding.BrowsingSpec.withoutTrackers, onboarding.nextBrowsingMessage(siteRating: siteRating))
    }
    
    func testWhenSecondTimeOnSearchPageThenShowNothing() {
        let onboarding = DaxOnboarding()
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
    }
    
    func testWhenFirstTimeOnSearchPageThenShowSearchPageMessage() {
        let onboarding = DaxOnboarding()
        XCTAssertEqual(DaxOnboarding.BrowsingSpec.afterSearch, onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
    }

    func testWhenDimissedThenShowNothing() {
        let onboarding = DaxOnboarding()
        onboarding.dismiss()
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }
    
    func testWhenThirdTimeOnHomeScreenAndAtLeastOneBrowsingDialogSeenThenShowNothing() {
        let onboarding = DaxOnboarding()
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertEqual(DaxOnboarding.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextHomeScreenMessage())
    }

    func testWhenSecondTimeOnHomeScreenAndAtLeastOneBrowsingDialogSeenThenShowSubsequentDialog() {
        let onboarding = DaxOnboarding()
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertEqual(DaxOnboarding.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
    }

    func testWhenSecondTimeOnHomeScreenAndNoOtherDialgosSeenThenShowNothing() {
        let onboarding = DaxOnboarding()
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextHomeScreenMessage())
    }

    func testWhenFirstTimeOnHomeScreenThenShowFirstDialog() {
        let onboarding = DaxOnboarding()
        XCTAssertEqual(DaxOnboarding.HomeScreenSpec.initial, onboarding.nextHomeScreenMessage())
    }
    
}
