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
import BrowserServicesKit
import TrackerRadarKit
import ContentBlocking
import PrivacyDashboard

private struct MockEntityProvider: EntityProviding {
    
    func entity(forHost host: String) -> Entity? {
        let mapper = ["www.example.com": ("https://www.example.com", [], 1.0),
                      "www.facebook.com": ("Facebook", [], 4.0),
                      "www.google.com": ("Google", [], 5.0),
                      "www.instagram.com": ("Facebook", ["facebook.com"], 4.0),
                      "www.amazon.com": ("Amazon.com", [], 3.0),
                      "www.1dmp.io": ("https://www.1dmp.io", [], 0.5)]
        if let entityElements = mapper[host] {
            return Entity(displayName: entityElements.0, domains: entityElements.1, prevalence: entityElements.2)
        } else {
            return nil
        }
    }
}

final class DaxDialog: XCTestCase {

    struct URLs {
        
        static let example = URL(string: "https://www.example.com")!
        static let ddg = URL(string: "https://duckduckgo.com?q=test")!
        static let facebook = URL(string: "https://www.facebook.com")!
        static let google = URL(string: "https://www.google.com")!
        static let ownedByFacebook = URL(string: "https://www.instagram.com")!
        static let amazon = URL(string: "https://www.amazon.com")!
        static let tracker = URL(string: "https://www.1dmp.io")!

    }

    let settings: InMemoryDaxDialogsSettings = InMemoryDaxDialogsSettings()
    lazy var mockVariantManager = MockVariantManager(isSupportedReturns: true)
    lazy var onboarding = DaxDialogs(settings: settings,
                                     entityProviding: MockEntityProvider(),
                                     variantManager: mockVariantManager)
    private var entityProvider: EntityProviding!

    override func setUp() {
        super.setUp()
        setupUserDefault(with: #file)
        entityProvider = MockEntityProvider()
    }
    
    func testWhenResumingRegularFlowThenNextHomeMessageIsBlankUntilBrowsingMessagesShown() {
        onboarding.enableAddFavoriteFlow()
        onboarding.resumeRegularFlow()
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.google)))
        XCTAssertEqual(onboarding.nextHomeScreenMessage(), .subsequent)
        XCTAssertEqual(settings.homeScreenMessagesSeen, 2)
    }

    func testWhenStartingAddFavoriteFlowThenNextMessageIsAddFavorite() {
        onboarding.enableAddFavoriteFlow()
        XCTAssertEqual(onboarding.nextHomeScreenMessage(), .addFavorite)
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
        XCTAssertTrue(onboarding.isAddFavoriteFlow)
    }

    func testWhenStartingNextMessageAndAddFavoriteFlowThenNextHomeScreenMessagesSeenDoesNotIncrement() {
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
        onboarding.enableAddFavoriteFlow()
        XCTAssertEqual(onboarding.nextHomeScreenMessage(), .addFavorite)
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
    }

    func testWhenEachVersionOfTrackersMessageIsShownThenFormattedCorrectlyAndNotShownAgain() {

        // swiftlint:disable line_length
        let testCases = [
            (urls: [ URLs.google ], expected: DaxDialogs.BrowsingSpec.withOneTracker.format(args: "Google"), line: #line),
            (urls: [ URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Google", "Amazon.com"), line: #line),
            (urls: [ URLs.amazon, URLs.ownedByFacebook ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Facebook", "Amazon.com"), line: #line),
            (urls: [ URLs.facebook, URLs.google ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 1, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon, URLs.tracker ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 2, "Google", "Facebook"), line: #line)
        ]
        // swiftlint:enable line_length

        testCases.forEach { testCase in
            
            let onboarding = DaxDialogs(settings: InMemoryDaxDialogsSettings(),
                                        entityProviding: MockEntityProvider(),
                                        variantManager: mockVariantManager)
            let privacyInfo = makePrivacyInfo(url: URLs.example)
            
            testCase.urls.forEach { url in
                let detectedTracker = detectedTrackerFrom(url, pageUrl: URLs.example.absoluteString)
                privacyInfo.trackerInfo.addDetectedTracker(detectedTracker, onPageWithURL: URLs.example)
            }
            
            XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
            
            // Assert the expected case
            XCTAssertEqual(testCase.expected, onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo), line: UInt(testCase.line))
            
            // Also assert the we don't see the message on subsequent calls
            XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
            XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo), line: UInt(testCase.line))
        }
        
    }

    func testWhenTrackersShownThenFireEducationShown() {
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        privacyInfo.trackerInfo.addDetectedTracker(detectedTrackerFrom(URLs.google, pageUrl: URLs.example.absoluteString),
                                                   onPageWithURL: URLs.example)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
    }

    func testWhenMajorTrackerShownThenFireEducationShown() {
        let privacyInfo = makePrivacyInfo(url: URLs.google)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
    }

    func testWhenSearchShownThenNoTrackersIsShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg)))
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
    }

    func testWhenMajorTrackerShownThenNoTrackersIsNotShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
    }

    func testWhenTrackersShownThenNoTrackersIsNotShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.amazon)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
    }
    
    func testWhenMajorTrackerShownThenOwnedByIsNotShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook)))
    }

    func testWhenSecondTimeOnSiteThatIsOwnedByFacebookThenShowNothingAfterFireEducation() {
        let privacyInfo = makePrivacyInfo(url: URLs.ownedByFacebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenFirstTimeOnSiteThatIsOwnedByFacebookThenShowOwnedByMajorTrackingMessage() {
        let privacyInfo = makePrivacyInfo(url: URLs.ownedByFacebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteOwnedByMajorTracker.format(args: "instagram.com", "Facebook", 39.0),
                       onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenSecondTimeOnSiteThatIsMajorTrackerThenShowNothingAfterFireEducation() {
        let privacyInfo = makePrivacyInfo(url: URLs.facebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenFirstTimeOnFacebookThenShowMajorTrackingMessage() {
        let privacyInfo = makePrivacyInfo(url: URLs.facebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: "Facebook", URLs.facebook.host ?? ""),
                       onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenFirstTimeOnGoogleThenShowMajorTrackingMessage() {
        let privacyInfo = makePrivacyInfo(url: URLs.google)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: "Google", URLs.google.host ?? ""),
                       onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenSecondTimeOnPageWithNoTrackersThenTrackersThenShowFireEducation() {
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenFirstTimeOnPageWithNoTrackersThenTrackersThenShowNoTrackersMessage() {
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.withoutTrackers, onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }
    
    func testWhenSecondTimeOnSearchPageThenShowNothing() {
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg)))
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg)))
    }
    
    func testWhenFirstTimeOnSearchPageThenShowSearchPageMessage() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.afterSearch, onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg)))
    }
    
    func testWhenOnSamePageAndPresenceOfTrackersChangesThenShowOnlyOneMessage() {
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.withoutTrackers, onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
        
        let privacyInfoWithTrackers = makePrivacyInfo(url: URLs.google)
        privacyInfo.trackerInfo = privacyInfoWithTrackers.trackerInfo
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: privacyInfo))
    }

    func testWhenDimissedThenShowNothing() {
        onboarding.dismiss()
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 0)
        XCTAssertNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
    }
    
    func testWhenThirdTimeOnHomeScreenAndFireEducationSeenThenShowNothing() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 2)
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 2)
    }
    
    func testWhenSecondTimeOnHomeScreenAndFireEducationSeenThenShowSubsequentDialog() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
        XCTAssertNotNil(onboarding.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 2)
    }

    func testWhenSecondTimeOnHomeScreenAndNoOtherDialogsSeenThenShowNothing() {
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
    }

    func testWhenFirstTimeOnHomeScreenThenShowFirstDialog() {
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.initial, onboarding.nextHomeScreenMessage())
        XCTAssertEqual(settings.homeScreenMessagesSeen, 1)
    }
    
    func testWhenPrimingDaxDialogForUseThenDismissedIsFalse() {
        let settings = InMemoryDaxDialogsSettings()
        settings.isDismissed = true
        
        let onboarding = DaxDialogs(settings: settings, entityProviding: entityProvider)
        onboarding.primeForUse()
        XCTAssertFalse(settings.isDismissed)
    }
    
    func testDaxDialogsDismissedByDefault() {
        XCTAssertTrue(DefaultDaxDialogsSettings().isDismissed)
    }


    private func detectedTrackerFrom(_ url: URL, pageUrl: String) -> DetectedRequest {
        let entity = entityProvider.entity(forHost: url.host!)
        return DetectedRequest(url: url.absoluteString,
                               eTLDplus1: nil,
                               knownTracker: KnownTracker(domain: entity?.displayName,
                                                          defaultAction: .block,
                                                          owner: nil,
                                                          prevalence: nil,
                                                          subdomains: [],
                                                          categories: [],
                                                          rules: nil),
                               entity: entity,
                               state: .blocked,
                               pageUrl: pageUrl)
    }
    
    private func makePrivacyInfo(url: URL) -> PrivacyInfo {
        let protectionStatus = ProtectionStatus(unprotectedTemporary: false, enabledFeatures: [], allowlisted: false, denylisted: false)
        let privacyInfo = PrivacyInfo(url: url,
                                      parentEntity: entityProvider.entity(forHost: url.host!),
                                      protectionStatus: protectionStatus)
        return privacyInfo
    }
}
