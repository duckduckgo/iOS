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

import BrowserServicesKit
import ContentBlocking
import PrivacyDashboard
import TrackerRadarKit
import XCTest

@testable import Core
@testable import DuckDuckGo

struct MockEntityProvider: EntityProviding {
    
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
        static let ddg2 = URL(string: "https://duckduckgo.com?q=testSomethingElse")!
        static let facebook = URL(string: "https://www.facebook.com")!
        static let google = URL(string: "https://www.google.com")!
        static let ownedByFacebook = URL(string: "https://www.instagram.com")!
        static let ownedByFacebook2 = URL(string: "https://www.whatsapp.com")!
        static let amazon = URL(string: "https://www.amazon.com")!
        static let tracker = URL(string: "https://www.1dmp.io")!

    }

    let settings: MockDaxDialogsSettings = MockDaxDialogsSettings()
    lazy var mockVariantManager = MockVariantManager(isSupportedReturns: false)
    lazy var onboarding = DaxDialogs(settings: settings,
                                     entityProviding: MockEntityProvider(),
                                     variantManager: mockVariantManager)
    private var entityProvider: EntityProviding!

    override func setUp() {
        super.setUp()
        setupUserDefault(with: #file)
        entityProvider = MockEntityProvider()
    }

    func testWhenStartingAddFavoriteFlowThenNextMessageIsAddFavorite() {
        // WHEN
        onboarding.enableAddFavoriteFlow()

        // THEN
        XCTAssertEqual(onboarding.nextHomeScreenMessageNew(), .addFavorite)
        XCTAssertTrue(onboarding.isAddFavoriteFlow)
    }

    func testWhenEachVersionOfTrackersMessageIsShownThenFormattedCorrectly() {
        let testCases = [
            (urls: [ URLs.google ], expected: DaxDialogs.BrowsingSpec.withOneTracker.format(args: "Google"), line: #line),
            (urls: [ URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Google", "Amazon.com"), line: #line),
            (urls: [ URLs.amazon, URLs.ownedByFacebook ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Facebook", "Amazon.com"), line: #line),
            (urls: [ URLs.facebook, URLs.google ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 0, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 1, "Google", "Facebook"), line: #line),
            (urls: [ URLs.facebook, URLs.google, URLs.amazon, URLs.tracker ], expected: DaxDialogs.BrowsingSpec.withMultipleTrackers.format(args: 2, "Google", "Facebook"), line: #line)
        ]

        testCases.forEach { testCase in
            
            let onboarding = DaxDialogs(settings: MockDaxDialogsSettings(),
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
        }
        
    }
    
    func testWhenPrimingDaxDialogForUseThenDismissedIsFalse() {
        let settings = MockDaxDialogsSettings()
        settings.isDismissed = true
        
        let onboarding = DaxDialogs(settings: settings, entityProviding: entityProvider)
        onboarding.primeForUse()
        XCTAssertFalse(settings.isDismissed)
    }
    
    func testDaxDialogsDismissedByDefault() {
        XCTAssertTrue(DefaultDaxDialogsSettings().isDismissed)
    }

    func testWhenBrowsingSpecIsWithOneTrackerThenHighlightAddressBarIsFalse() throws {
        // GIVEN
        let sut = makeSUT(settings: MockDaxDialogsSettings())
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        let detectedTracker = detectedTrackerFrom(URLs.google, pageUrl: URLs.example.absoluteString)
        privacyInfo.trackerInfo.addDetectedTracker(detectedTracker, onPageWithURL: URLs.example)

        // WHEN
        let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: privacyInfo))

        // THEN
        XCTAssertEqual(result.type, .withOneTracker)
        XCTAssertFalse(result.highlightAddressBar)
    }

    func testWhenBrowsingSpecIsWithMultipleTrackerThenHighlightAddressBarIsFalse() throws {
        // GIVEN
        let sut = makeSUT(settings: MockDaxDialogsSettings())
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        [URLs.google, URLs.amazon].forEach { tracker in
            let detectedTracker = detectedTrackerFrom(tracker, pageUrl: URLs.example.absoluteString)
            privacyInfo.trackerInfo.addDetectedTracker(detectedTracker, onPageWithURL: URLs.example)
        }

        // WHEN
        let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: privacyInfo))

        // THEN
        XCTAssertEqual(result.type, .withMultipleTrackers)
        XCTAssertFalse(result.highlightAddressBar)
    }

    func testWhenURLIsDuckDuckGoSearchAndSearchDialogHasNotBeenSeenThenReturnSpecTypeAfterSearch() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingAfterSearchShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))

        // THEN
        XCTAssertEqual(result?.type, .afterSearch)
    }

    func testWhenURLIsMajorTrackerWebsiteAndMajorTrackerDialogHasNotBeenSeenThenReturnSpecTypeSiteIsMajorTracker() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingMajorTrackingSiteShown = false
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.facebook)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: privacyInfo)

        // THEN
        XCTAssertEqual(result?.type, .siteIsMajorTracker)
    }

    func testWhenURLIsOwnedByMajorTrackerAndMajorTrackerDialogHasNotBeenSeenThenReturnSpecTypeSiteOwnedByMajorTracker() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingMajorTrackingSiteShown = false
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.ownedByFacebook)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: privacyInfo)

        // THEN
        XCTAssertEqual(result?.type, .siteOwnedByMajorTracker)
    }

    func testWhenURLHasTrackersAndMultipleTrackersDialogHasNotBeenSeenThenReturnSpecTypeWithMultipleTrackers() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = false
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        [URLs.google, URLs.amazon].forEach { url in
            let detectedTracker = detectedTrackerFrom(url, pageUrl: URLs.example.absoluteString)
            privacyInfo.trackerInfo.addDetectedTracker(detectedTracker, onPageWithURL: URLs.example)
        }

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: privacyInfo)

        // THEN
        XCTAssertEqual(result?.type, .withMultipleTrackers)
    }

    func testWhenURLHasNoTrackersAndIsNotSERPAndNoTrakcersDialogHasNotBeenSeenThenReturnSpecTypeWithoutTrackers() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithoutTrackersShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example))

        // THEN
        XCTAssertEqual(result?.type, .withoutTrackers)
    }

    func testWhenURLIsDuckDuckGoSearchAndHasVisitedWebsiteThenSpecTypeSearchIsReturned() throws {
        try [DaxDialogs.BrowsingSpec.withoutTrackers, .siteIsMajorTracker, .siteOwnedByMajorTracker, .withOneTracker, .withMultipleTrackers].forEach { spec in
            // GIVEN
            let settings = MockDaxDialogsSettings()
            let sut = DaxDialogs(settings: settings, entityProviding: entityProvider)
            sut.overrideShownFlagFor(spec, flag: true)

            // WHEN
            let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg)))

            // THEN
            XCTAssertEqual(result.type, .afterSearch)
        }
    }

    func testWhenFireButtonSeen_AndFinalDialogNotSeen_AndSearchDone_ThenFinalBrowsingSpecIsReturned() throws {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingAfterSearchShown = true
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg)))

        // THEN
        XCTAssertEqual(result, .final)
    }

    func testWhenFireButtonSeen_AndFinalDialogNotSeen_AndWebsiteWithoutTracker_ThenFinalBrowsingSpecIsReturned() throws {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithoutTrackersShown = true
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example)))

        // THEN
        XCTAssertEqual(result, .final)
    }

    func testWhenFireButtonSeen_AndFinalDialogNotSeen_AndWebsiteWithTracker_ThenFinalBrowsingSpecIsReturned() throws {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        let detectedTracker = detectedTrackerFrom(URLs.google, pageUrl: URLs.example.absoluteString)
        privacyInfo.trackerInfo.addDetectedTracker(detectedTracker, onPageWithURL: URLs.example)

        // WHEN
        let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: privacyInfo))

        // THEN
        XCTAssertEqual(result, .final)
    }

    func testWhenFireButtonSeen_AndFinalDialogNotSeen_AndWebsiteMajorTracker_ThenFinalBrowsingSpecIsReturned() throws {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingMajorTrackingSiteShown = true
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.ownedByFacebook)

        // WHEN
        let result = try XCTUnwrap(sut.nextBrowsingMessageIfShouldShow(for: privacyInfo))

        // THEN
        XCTAssertEqual(result, .final)
    }

    func testWhenFireButtonSeen_AndFinalDialogSeen_AndSearchDone_ThenBrowsingSpecIsNil() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingAfterSearchShown = true
        settings.fireMessageExperimentShown = true
        settings.browsingFinalDialogShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))

        // THEN
        XCTAssertNil(result)
    }

    func testWhenFireButtonSeen_AndFinalDialogSeen_AndWebsiteWithoutTracker_ThenBrowsingSpecIsNotFinal() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithoutTrackersShown = true
        settings.fireMessageExperimentShown = true
        settings.browsingFinalDialogShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example))

        // THEN
        XCTAssertNil(result)
    }

    func testWhenFireButtonSeen_AndFinalDialogSeen_AndWebsiteWithTracker_ThenBrowsingSpecIsNil() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.fireMessageExperimentShown = true
        settings.browsingFinalDialogShown = true
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.example)
        let detectedTracker = detectedTrackerFrom(URLs.google, pageUrl: URLs.example.absoluteString)
        privacyInfo.trackerInfo.addDetectedTracker(detectedTracker, onPageWithURL: URLs.example)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: privacyInfo)

        // THEN
        XCTAssertNil(result)
    }

    func testWhenFireButtonSeen_AndFinalDialogSeen_AndWebsiteMajorTracker_ThenFinalBrowsingSpecIsReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingMajorTrackingSiteShown = true
        settings.fireMessageExperimentShown = true
        settings.browsingFinalDialogShown = true
        let sut = makeSUT(settings: settings)
        let privacyInfo = makePrivacyInfo(url: URLs.ownedByFacebook)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: privacyInfo)

        // THEN
        XCTAssertNil(result)
    }

    func testWhenFireButtonSeen_AndFinalDialogSeen_AndSearchNotSeen_ThenAfterSearchSpecIsReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithoutTrackersShown = true
        settings.browsingWithTrackersShown = true
        settings.browsingMajorTrackingSiteShown = true
        settings.fireMessageExperimentShown = true
        settings.browsingFinalDialogShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))

        // THEN
        XCTAssertEqual(result, .afterSearch)
    }

    func testWhenSearchDialogSeen_OnReload_SearchDialogReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))

        // THEN
        XCTAssertEqual(result1, .afterSearch)
        XCTAssertEqual(result1, result2)
    }

    func testWhenSearchDialogSeen_OnLoadingAnotherSearch_NilReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg2))

        // THEN
        XCTAssertEqual(result1, .afterSearch)
        XCTAssertNil(result2)
    }

    func testWhenMajorTrackerDialogSeen_OnReload_MajorTrackerDialogReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))

        // THEN
        XCTAssertEqual(result1?.type, .siteIsMajorTracker)
        XCTAssertEqual(result1, result2)
    }

    func testWhenMajorTrackerDialogSeen_OnLoadingAnotherSearch_NilReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.google))

        // THEN
        XCTAssertEqual(result1?.type, .siteIsMajorTracker)
        XCTAssertNil(result2)
    }

    func testWhenMajorTrackerOwnerMessageSeen_OnReload_MajorTrackerOwnerDialogReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook))

        // THEN
        XCTAssertEqual(result1?.type, .siteOwnedByMajorTracker)
        XCTAssertEqual(result1, result2)
    }

    func testWhenMajorTrackerOwnerMessageSeen_OnLoadingAnotherSearch_NilReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook2))

        // THEN
        XCTAssertEqual(result1?.type, .siteOwnedByMajorTracker)
        XCTAssertNil(result2)
    }

    func testWhenWithoutTrackersMessageSeen_OnReload_WithoutTrackersDialogReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.tracker))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.tracker))

        // THEN
        XCTAssertEqual(result1?.type, .withoutTrackers)
        XCTAssertEqual(result1, result2)
    }

    func testWhenWithoutTrackersMessageSeen_OnLoadingAnotherSearch_NilReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.tracker))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example))

        // THEN
        XCTAssertEqual(result1?.type, .withoutTrackers)
        XCTAssertNil(result2)
    }

    func testWhenFinalMessageSeen_OnReload_NilReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithoutTrackersShown = true
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example))
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.example))

        // THEN
        XCTAssertEqual(result1?.type, .final)
        XCTAssertNil(result2)
    }

    func testWhenVisitWebsiteSeen_OnReload_VisitWebsiteReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        sut.setSearchMessageSeen()

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        sut.setSearchMessageSeen()
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        let result3 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))

        // THEN
        XCTAssertEqual(result1?.type, .afterSearch)
        XCTAssertEqual(result2?.type, .visitWebsite)
        XCTAssertEqual(result2, result3)
    }

    func testWhenVisitWebsiteSeen_OnLoadingAnotherSearch_NilIseturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        sut.setSearchMessageSeen()

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        sut.setSearchMessageSeen()
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        let result3 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg2))

        // THEN
        XCTAssertEqual(result1?.type, .afterSearch)
        XCTAssertEqual(result2?.type, .visitWebsite)
        XCTAssertNil(result3)
    }

    func testWhenFireMessageSeen_OnReload_FireMessageReturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        sut.setSearchMessageSeen()

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        sut.setFireEducationMessageSeen()
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        let result3 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))

        // THEN
        XCTAssertEqual(result1?.type, .siteIsMajorTracker)
        XCTAssertEqual(result2?.type, .fire)
        XCTAssertEqual(result2, result3)
    }

    func testWhenSearchNotSeen_AndFireMessageSeen_OnLoadingAnotherSearch_ExpectedDialogIseturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        sut.setSearchMessageSeen()

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        sut.setFireEducationMessageSeen()
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        let result3 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))

        // THEN
        XCTAssertEqual(result1?.type, .siteIsMajorTracker)
        XCTAssertEqual(result2?.type, .fire)
        XCTAssertEqual(result3?.type, .afterSearch)
    }

    func testWhenSearchSeen_AndFireMessageSeen_OnLoadingAnotherSearch_ExpectedDialogIseturned() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        sut.setSearchMessageSeen()

        // WHEN
        let result1 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        sut.setFireEducationMessageSeen()
        let result2 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))
        let result3 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg))
        settings.browsingAfterSearchShown = true
        let result4 = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ddg2))

        // THEN
        XCTAssertEqual(result1?.type, .siteIsMajorTracker)
        XCTAssertEqual(result2?.type, .fire)
        XCTAssertEqual(result3?.type, .afterSearch)
        XCTAssertEqual(result4?.type, .final)
    }

    func testWhenBrowserWithTrackersShown_AndPrivacyAnimationNotShown_ThenShowPrivacyAnimationPulse() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.privacyButtonPulseShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.shouldShowPrivacyButtonPulse

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenBrowserWithTrackersShown_AndPrivacyAnimationShown_ThenDoNotShowPrivacyAnimationPulse() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.privacyButtonPulseShown = true
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.shouldShowPrivacyButtonPulse

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenBrowserWithTrackersShown_AndFireButtonPulseActive_ThenDoNotShowPrivacyAnimationPulse() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.privacyButtonPulseShown = false
        let sut = makeSUT(settings: settings)
        sut.fireButtonPulseStarted()

        // WHEN
        let result = sut.shouldShowPrivacyButtonPulse

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenCallSetPrivacyButtonPulseSeen_ThenSetPrivacyButtonPulseShownFlagToTrue() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        XCTAssertFalse(settings.privacyButtonPulseShown)

        // WHEN
        sut.setPrivacyButtonPulseSeen()

        // THEN
        XCTAssertTrue(settings.privacyButtonPulseShown)
    }

    func testWhenSetFireEducationMessageSeenIsCalled_ThenSetPrivacyButtonPulseShownToTrue() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        let sut = makeSUT(settings: settings)
        XCTAssertFalse(settings.privacyButtonPulseShown)

        // WHEN
        sut.setFireEducationMessageSeen()

        // THEN
        XCTAssertTrue(settings.privacyButtonPulseShown)
    }

    func testWhenFireButtonAnimationPulseNotShown__AndShouldShowFireButtonPulseIsCalled_ThenReturnTrue() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.privacyButtonPulseShown = true
        settings.browsingWithTrackersShown = true
        settings.fireButtonPulseDateShown = nil
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.shouldShowFireButtonPulse

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenFireButtonAnimationPulseShown_AndShouldShowFireButtonPulseIsCalled_ThenReturnFalse() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.privacyButtonPulseShown = true
        settings.browsingWithTrackersShown = true
        settings.fireButtonPulseDateShown = Date()
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.shouldShowFireButtonPulse

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenFireEducationMessageSeen_AndFinalMessageNotSeen_ThenShowFinalMessage() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.fireMessageExperimentShown = true
        settings.browsingFinalDialogShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(result, .final)
    }

    func testWhenNextHomeScreenMessageNewIsCalled_ThenLastVisitedOnboardingWebsiteAndLastShownDaxDialogAreSetToNil() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.lastShownContextualOnboardingDialogType = DaxDialogs.BrowsingSpec.fire.type.rawValue
        settings.lastVisitedOnboardingWebsiteURLPath = "https://www.example.com"
        let sut = makeSUT(settings: settings)
        XCTAssertNotNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNotNil(settings.lastVisitedOnboardingWebsiteURLPath)

        // WHEN
        _ = sut.nextHomeScreenMessageNew()

        // THEN
        XCTAssertNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNil(settings.lastVisitedOnboardingWebsiteURLPath)
    }

    func testWhenEnableAddFavoritesFlowIsCalled_ThenIsAddFavoriteFlowIsTrue() {
        // GIVEN
        let sut = makeSUT(settings: MockDaxDialogsSettings())
        XCTAssertFalse(sut.isAddFavoriteFlow)

        // WHEN
        sut.enableAddFavoriteFlow()

        // THEN
        XCTAssertTrue(sut.isAddFavoriteFlow)
    }

    func testWhenBlockedTrackersDialogSeen_AndMajorTrackerNotSeen_ThenReturnNilSpec() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.browsingMajorTrackingSiteShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))

        // THEN
        XCTAssertNil(result)
    }

    func testWhenBlockedTrackersDialogNotSeen_AndMajorTrackerNotSeen_ThenReturnMajorNetworkSpec() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = false
        settings.browsingMajorTrackingSiteShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.facebook))

        // THEN
        XCTAssertEqual(result?.type, .siteIsMajorTracker)
    }

    func testWhenBlockedTrackersDialogSeen_AndOwnedByMajorTrackerNotSeen_ThenReturnNilSpec() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = true
        settings.browsingMajorTrackingSiteShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook))

        // THEN
        XCTAssertNil(result)
    }

    func testWhenBlockedTrackersDialogNotSeen_AndOwnedByMajorTrackerNotSeen_ThenReturnOwnedByMajorNetworkSpec() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.browsingWithTrackersShown = false
        settings.browsingMajorTrackingSiteShown = false
        let sut = makeSUT(settings: settings)

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: URLs.ownedByFacebook))

        // THEN
        XCTAssertEqual(result?.type, .siteOwnedByMajorTracker)
    }

    func testWhenDismissIsCalled_ThenLastVisitedOnboardingWebsiteAndLastShownDaxDialogAreSetToNil() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.lastShownContextualOnboardingDialogType = DaxDialogs.BrowsingSpec.fire.type.rawValue
        settings.lastVisitedOnboardingWebsiteURLPath = "https://www.example.com"
        let sut = makeSUT(settings: settings)
        XCTAssertNotNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNotNil(settings.lastVisitedOnboardingWebsiteURLPath)

        // WHEN
        sut.dismiss()

        // THEN
        XCTAssertNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNil(settings.lastVisitedOnboardingWebsiteURLPath)
    }

    func testWhenSetDaxDialogDismiss_ThenLastVisitedOnboardingWebsiteAndLastShownDaxDialogAreSetToNil() {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.lastShownContextualOnboardingDialogType = DaxDialogs.BrowsingSpec.fire.type.rawValue
        settings.lastVisitedOnboardingWebsiteURLPath = "https://www.example.com"
        let sut = makeSUT(settings: settings)
        XCTAssertNotNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNotNil(settings.lastVisitedOnboardingWebsiteURLPath)

        // WHEN
        sut.setDaxDialogDismiss()

        // THEN
        XCTAssertNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNil(settings.lastVisitedOnboardingWebsiteURLPath)
    }

    func testWhenClearedBrowserDataIsCalled_ThenLastVisitedOnboardingWebsiteAndLastShownDaxDialogAreSetToNil() throws {
        // GIVEN
        let settings = MockDaxDialogsSettings()
        settings.lastShownContextualOnboardingDialogType = DaxDialogs.BrowsingSpec.fire.type.rawValue
        settings.lastVisitedOnboardingWebsiteURLPath = "https://www.example.com"
        let sut = makeSUT(settings: settings)
        XCTAssertNotNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNotNil(settings.lastVisitedOnboardingWebsiteURLPath)

        // WHEN
        sut.clearedBrowserData()

        // THEN
        XCTAssertNil(settings.lastShownContextualOnboardingDialogType)
        XCTAssertNil(settings.lastVisitedOnboardingWebsiteURLPath)
    }

    func testWhenIsEnabledIsFalse_AndReloadWebsite_ThenReturnNilBrowsingSpec() throws {
        // GIVEN
        let lastVisitedWebsitePath = "https://www.example.com"
        let lastVisitedWebsiteURL = try XCTUnwrap(URL(string: lastVisitedWebsitePath))
        let settings = MockDaxDialogsSettings()
        settings.lastShownContextualOnboardingDialogType = DaxDialogs.BrowsingSpec.fire.type.rawValue
        settings.lastVisitedOnboardingWebsiteURLPath = lastVisitedWebsitePath
        let sut = makeSUT(settings: settings)
        sut.dismiss()

        // WHEN
        let result = sut.nextBrowsingMessageIfShouldShow(for: makePrivacyInfo(url: lastVisitedWebsiteURL))

        // THEN
        XCTAssertNil(result)
    }

    func testWhenIsEnabledIsCalled_AndShouldShowDaxDialogsIsTrue_ThenReturnTrue() {
        // GIVEN
        let sut = DaxDialogs(settings: settings, entityProviding: entityProvider)

        // WHEN
        let result = sut.isEnabled

        // THEN
        XCTAssertTrue(result)
    }

    // MARK: - States

    func testWhenIsShowingAddToDockDialogCalledAndHomeSpecIsFinalAndAddToDockIsEnabledThenReturnTrue() {
        // GIVEN
        let onboardingManagerMock = OnboardingManagerMock()
        onboardingManagerMock.addToDockEnabledState = .contextual
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings, onboardingManager: onboardingManagerMock)
        _ = sut.nextHomeScreenMessageNew()

        // WHEN
        let result = sut.isShowingAddToDockDialog

        // THEN
        XCTAssertTrue(result)
    }

    func testWhenIsShowingAddToDockDialogCalledAndHomeSpecIsNotFinalThenReturnFalse() {
        // GIVEN
        let onboardingManagerMock = OnboardingManagerMock()
        onboardingManagerMock.addToDockEnabledState = .contextual
        let sut = makeSUT(settings: settings, onboardingManager: onboardingManagerMock)
        _ = sut.nextHomeScreenMessageNew()

        // WHEN
        let result = sut.isShowingAddToDockDialog

        // THEN
        XCTAssertFalse(result)
    }

    func testWhenIsShowingAddToDockDialogCalledAndHomeSpeciIsFinalAndAddToDockIsNotEnabledReturnFalse() {
        // GIVEN
        let onboardingManagerMock = OnboardingManagerMock()
        onboardingManagerMock.addToDockEnabledState = .disabled
        settings.fireMessageExperimentShown = true
        let sut = makeSUT(settings: settings, onboardingManager: onboardingManagerMock)
        _ = sut.nextHomeScreenMessageNew()

        // WHEN
        let result = sut.isShowingAddToDockDialog

        // THEN
        XCTAssertFalse(result)
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
        return PrivacyInfo(url: url,
                           parentEntity: entityProvider.entity(forHost: url.host!),
                           protectionStatus: protectionStatus)
    }

    private func makeSUT(settings: DaxDialogsSettings, onboardingManager: OnboardingAddToDockManaging = OnboardingManagerMock()) -> DaxDialogs {
        DaxDialogs(settings: settings, entityProviding: entityProvider, variantManager: MockVariantManager(), onboardingManager: onboardingManager)
    }
}
