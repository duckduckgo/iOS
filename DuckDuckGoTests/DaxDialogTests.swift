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
    
    lazy var mockVariantManager = MockVariantManager(isSupportedReturns: true)
    lazy var onboarding = DaxDialogs(settings: InMemoryDaxDialogsSettings(),
                                     contentBlockingRulesManager: Self.rulesManager!,
                                     variantManager: mockVariantManager)
    
    static var rulesManager: ContentBlockerRulesManager?

    override func setUp() {
        super.setUp()
        UserDefaults.app.removePersistentDomain(forName: #file)
        UserDefaults.app = UserDefaults(suiteName: #file)!

        
        guard Self.rulesManager == nil else { return }
        
        let contentBlockingUpdating = ContentBlockingUpdating()

        let trackerDataManager = TrackerDataManager(etag: nil,
                                                    data: nil,
                                                    embeddedDataProvider: AppTrackerDataSetProvider(),
                                                    errorReporting: nil)
        
        let privacyConfigurationManager
        = PrivacyConfigurationManager(fetchedETag: nil,
                                      fetchedData: nil,
                                      embeddedDataProvider: AppPrivacyConfigurationDataProvider(),
                                      localProtection: DomainsProtectionUserDefaultsStore(),
                                      errorReporting: nil)
        
        let contentBlockerRulesSource = DefaultContentBlockerRulesListsSource(trackerDataManger: trackerDataManager)
        let exceptionsSource = DefaultContentBlockerRulesExceptionsSource(privacyConfigManager: privacyConfigurationManager)

        let contentBlockingManager = ContentBlockerRulesManager(rulesSource: contentBlockerRulesSource,
                                                                       exceptionsSource: exceptionsSource,
                                                                       updateListener: contentBlockingUpdating,
                                                                       logger: contentBlockingLog)
        
        Self.rulesManager = contentBlockingManager
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: contentBlockingUpdating,
                              handler: nil)
        
        wait(for: [exp], timeout: 15.0)
    }
    
    func testWhenResumingRegularFlowThenNextHomeMessageIsBlankUntilBrowsingMessagesShown() {
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
            (urls: [ URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Google", "Amazon.com"), line: #line),
            (urls: [ URLs.amazon, URLs.ownedByFacebook ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Facebook", "Amazon.com"), line: #line),
            (urls: [ URLs.facebook, URLs.google ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 1, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon, URLs.tracker ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 2, "Google", "Facebook"), line: #line)
        ]
        // swiftlint:enable line_length

        testCases.forEach { testCase in
            
            let onboarding = DaxDialogs(settings: InMemoryDaxDialogsSettings(), variantManager: mockVariantManager)
            let siteRating = SiteRating(url: URLs.example)
            
            testCase.urls.forEach { url in
                let detectedTracker = detectedTrackerFrom(url, pageUrl: URLs.example.absoluteString)
                siteRating.trackerDetected(detectedTracker)
            }
            
            XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
            
            // Assert the expected case
            XCTAssertEqual(testCase.expected, onboarding.nextBrowsingMessage(siteRating: siteRating), line: UInt(testCase.line))
            
            // Also assert the we don't see the message on subsequent calls
            XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
            XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating), line: UInt(testCase.line))
        }
        
    }

    func testWhenTrackersShownThenFireEducationShown() {
        let siteRating = SiteRating(url: URLs.example)
        siteRating.trackerDetected(detectedTrackerFrom(URLs.google, pageUrl: URLs.example.absoluteString))
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenMajorTrackerShownThenFireEducationShown() {
        let siteRating = SiteRating(url: URLs.google)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenSearchShownThenNoTrackersIsShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenMajorTrackerShownThenNoTrackersIsNotShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.facebook)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }

    func testWhenTrackersShownThenNoTrackersIsNotShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.amazon)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
    }
    
    func testWhenMajorTrackerShownThenOwnedByIsNotShown() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.facebook)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ownedByFacebook)))
    }

    func testWhenSecondTimeOnSiteThatIsOwnedByFacebookThenShowNothingAfterFireEducation() {
        let siteRating = SiteRating(url: URLs.ownedByFacebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnSiteThatIsOwnedByFacebookThenShowOwnedByMajorTrackingMessage() {
        let siteRating = SiteRating(url: URLs.ownedByFacebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteOwnedByMajorTracker.format(args: "instagram.com", "Facebook", 39.0),
                       onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenSecondTimeOnSiteThatIsMajorTrackerThenShowNothingAfterFireEducation() {
        let siteRating = SiteRating(url: URLs.facebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnFacebookThenShowMajorTrackingMessage() {
        let siteRating = SiteRating(url: URLs.facebook)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: "Facebook", URLs.facebook.host ?? ""),
                       onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnGoogleThenShowMajorTrackingMessage() {
        let siteRating = SiteRating(url: URLs.google)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.siteIsMajorTracker.format(args: "Google", URLs.google.host ?? ""),
                       onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenSecondTimeOnPageWithNoTrackersThenTrackersThenShowFireEducation() {
        let siteRating = SiteRating(url: URLs.example)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: siteRating))
    }

    func testWhenFirstTimeOnPageWithNoTrackersThenTrackersThenShowNoTrackersMessage() {
        let siteRating = SiteRating(url: URLs.example)
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.withoutTrackers, onboarding.nextBrowsingMessage(siteRating: siteRating))
    }
    
    func testWhenSecondTimeOnSearchPageThenShowNothing() {
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
    }
    
    func testWhenFirstTimeOnSearchPageThenShowSearchPageMessage() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.BrowsingSpec.afterSearch, onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.ddg)))
    }

    func testWhenDimissedThenShowNothing() {
        onboarding.dismiss()
        XCTAssertNil(onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
    }
    
    func testWhenThirdTimeOnHomeScreenAndFireEducationSeenThenShowNothing() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
        XCTAssertEqual(DaxDialogs.HomeScreenSpec.subsequent, onboarding.nextHomeScreenMessage())
        XCTAssertNil(onboarding.nextHomeScreenMessage())
    }
    
    func testWhenSecondTimeOnHomeScreenAndFireEducationSeenThenShowSubsequentDialog() {
        XCTAssertFalse(onboarding.shouldShowFireButtonPulse)
        XCTAssertNotNil(onboarding.nextHomeScreenMessage())
        XCTAssertNotNil(onboarding.nextBrowsingMessage(siteRating: SiteRating(url: URLs.example)))
        XCTAssertTrue(onboarding.shouldShowFireButtonPulse)
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
        
    private func detectedTrackerFrom(_ url: URL, pageUrl: String) -> DetectedTracker {
        let tds = Self.rulesManager?.currentTDSRules?.trackerData
        let entity = tds?.findEntity(forHost: url.host!)
        let knownTracker = tds?.findTracker(forUrl: url.absoluteString)
        return DetectedTracker(url: url.absoluteString,
                                      knownTracker: knownTracker,
                                      entity: entity,
                                      blocked: true,
                                      pageUrl: pageUrl)
    }
}
