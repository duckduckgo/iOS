//
//  DaxDialogTests.swift
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

class DaxDialogTests: XCTestCase {
    
    struct URLs {
        
        static let example = URL(string: "https://www.example.com")!
        static let ddg = URL(string: "https://duckduckgo.com?q=test")!
        static let facebook = URL(string: "https://www.facebook.com")!
        static let google = URL(string: "https://www.google.com")!
        static let ownedByFacebook = URL(string: "https://www.instagram.com")!
        static let amazon = URL(string: "https://www.amazon.com")!
        static let tracker = URL(string: "https://www.1dmp.io")!

    }

    var onboarding = DaxDialogs(settings: InMemoryDaxDialogsSettings())

    override func setUp() {
        super.setUp()
        UserDefaults.clearStandard()

        // ensure we use the embedded version
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .trackerDataSet))
    }

    func testWhenResumingRegularFlowThenNextHomeMessageIsBlankUntilBrowsingMessageShown() {
        onboarding.enableAddFavoriteFlow()
        onboarding.resumeRegularFlow()
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.google)))
        XCTAssertEqual(onboarding.nextHomeScreenMessage(), .subsequent)
    }

    func testWhenStartingAddFavoriteFlowThenNextMessageIsAddFavorite() {
        onboarding.enableAddFavoriteFlow()
        XCTAssertEqual(onboarding.nextHomeScreenMessage(), .addFavorite)
        XCTAssertTrue(onboarding.isAddFavoriteFlow)
    }

    func testWhenEachVersionOfTrackersMessageIsShownThenFormattedCorrectlyAndNotShownAgain() {

        // swiftlint:disable line_length
        let testCases = [
            (urls: [ URLs.google ], expected: DaxDialogs.BrowsingSpec.withOneTracker.format(args: "Google"), line: #line),
            (urls: [ URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMutipleTrackers.format(args: 0, "Google", "Amazon.com"), line: #line),
            (urls: [ URLs.amazon, URLs.ownedByFacebook ], expected: DaxDialogs.BrowsingSpec.withMutipleTrackers.format(args: 0, "Facebook", "Amazon.com"), line: #line),
            (urls: [ URLs.facebook, URLs.google ], expected: DaxDialogs.BrowsingSpec.withMutipleTrackers.format(args: 0, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMutipleTrackers.format(args: 1, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon, URLs.tracker ], expected: DaxDialogs.BrowsingSpec.withMutipleTrackers.format(args: 2, "Google", "Facebook"), line: #line)
        ]
        // swiftlint:enable line_length

        testCases.forEach { testCase in
            
            let onboarding = DaxDialogs(settings: InMemoryDaxDialogsSettings())
            let siteRating = SiteRating(url: URLs.example)
            
            testCase.urls.forEach { url in
                let detectedTracker = detectedTrackerFrom(url)
                siteRating.trackerDetected(detectedTracker)
            }
            
            // Assert the expected case
            XCTAssertEqual(testCase.expected, onboarding.nextBrowsingMessage(siteRating: siteRating), line: UInt(testCase.line))
            
            // Also assert the we don't see the message on subsequent calls
            XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating), line: UInt(testCase.line))
        }
        
    }

    func testWhenTrackersShownThenNoTrackersNotShown() {
        let siteRating = SiteRating(url: URLs.example)
        siteRating.trackerDetected(detectedTrackerFrom(URLs.google))
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenMajorTrackerShownThenNoTrackersNotShown() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.google)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenSearchShownThenNoTrackersIsShown() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenMajorTrackerShownThenNoTrackersIsNotShown() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.facebook)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenTrackersShownThenNoTrackersIsNotShown() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.amazon)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }
    
    func testWhenMajorTrackerShownThenOwnedByIsNotShown() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.facebook)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ownedByFacebook)))
    }

    func testWhenSecondTimeOnSiteThatIsOwnedByFacebookThenShowNothing() {
        let siteRating = SiteRating(url: URLs.ownedByFacebook)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnSiteThatIsOwnedByFacebookThenShowOwnedByMajorTrackingMessage() {
        let siteRating = SiteRating(url: URLs.ownedByFacebook)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteOwnedByMajorTracker.format(args: "instagram.com", "Facebook", 39.0),
                       onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenSecondTimeOnSiteThatIsMajorTrackerThenShowNothing() {
        let siteRating = SiteRating(url: URLs.facebook)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnFacebookThenShowMajorTrackingMessage() {
        let siteRating = SiteRating(url: URLs.facebook)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: "Facebook", URLs.facebook.host ?? ""),
                       onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnGoogleThenShowMajorTrackingMessage() {
        let siteRating = SiteRating(url: URLs.google)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: "Google", URLs.google.host ?? ""),
                       onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenSecondTimeOnPageWithNoTrackersThenTrackersThenShowNothing() {
        let siteRating = SiteRating(url: URLs.example)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnPageWithNoTrackersThenTrackersThenShowNoTrackersMessage() {
        let siteRating = SiteRating(url: URLs.example)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.withoutTrackers, onboarding.nextBrowsingMessage(siteRating: siteRating))
    }
    
    func testWhenSecondTimeOnSearchPageThenShowNothing() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
    }
    
    func testWhenFirstTimeOnSearchPageThenShowSearchPageMessage() {
        XCTAssertEqual(DaxDialogs.BrowsingSpec.afterSearch, onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
    }

    func testWhenDimissedThenShowNothing() {
        onboarding.dismiss()
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }
    
    func testWhenThirdTimeOnHomeScreenAndAtLeastOneBrowsingDialogSeenThenShowNothing() {
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextHomeScreenMessage())
    }

    func testWhenSecondTimeOnHomeScreenAndAtLeastOneBrowsingDialogSeenThenShowSubsequentDialog() {
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
    }

    func testWhenSecondTimeOnHomeScreenAndNoOtherDialgosSeenThenShowNothing() {
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextHomeScreenMessage())
    }

    func testWhenFirstTimeOnHomeScreenThenShowFirstDialog() {
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.initial, onboarding.nextHomeScreenMessage())
    }
    
    func testWhenPrimingDaxDialogForUseThenDismissedIsFalse() {
        let settings = InMemoryDaxDialogsSettings()
        settings.isDismissed = true
        
        let onboarding = DaxDialogs(settings: settings)
        onboarding.primeForUse()
        XCTAssertFalse(settings.isDismissed)
    }
    
    func testDaxDialogsDismissedByDefault() {
        XCTAssertTrue(DefaultDaxDialogsSettings().isDismissed)
    }
        
    private func detectedTrackerFrom(_ url: URL) -> DetectedTracker {
        let entity = TrackerDataManager.shared.findEntity(forHost: url.host!)
        let knownTracker = TrackerDataManager.shared.findTracker(forUrl: url.absoluteString)
        return DetectedTracker(url: url.absoluteString,
                                      knownTracker: knownTracker,
                                      entity: entity,
                                      blocked: true)
    }
}
