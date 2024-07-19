//
//  DaxDialogsNewTabTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit
@testable import DuckDuckGo

final class DaxDialogsNewTabTests: XCTestCase {

    var daxDialogs: DaxDialogs!
    var settings: DaxDialogsSettings!

    override func setUp() {
        settings = MockDaxDialogsSettings()
        daxDialogs = DaxDialogs(settings: settings, entityProviding: MockEntityProvider())
    }

    override func tearDown() {
        settings = nil
        daxDialogs = nil
    }

    func testIfIsAddFavoriteFlow_OnNextHomeScreenMessageNew_ReturnsAddFavorite() {
        // GIVEN
        daxDialogs.enableAddFavoriteFlow()

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(homeScreenMessage, .addFavorite)
    }

    func testIfBrowsingAfterSearchNotShown_OnNextHomeScreenMessageNew_ReturnsInitial() {
        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(homeScreenMessage, .initial)
    }

    func testIfBrowsingAfterSearchShown_OnNextHomeScreenMessageNew_ReturnsSubsequent() {
        // GIVEN
        settings.browsingAfterSearchShown = true

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(homeScreenMessage, .subsequent)
    }

    func testIfBrowsingAfterSearchShown_andBrowsingMajorTrackingSiteShown_OnNextHomeScreenMessageNew_ReturnsFinal() {
        // GIVEN
        settings.browsingAfterSearchShown = true
        settings.browsingMajorTrackingSiteShown = true
        XCTAssertFalse(settings.browsingFinalDialogShown)

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(homeScreenMessage, .final)
        XCTAssertTrue(settings.browsingFinalDialogShown)
    }

    func testIfBrowsingAfterSearchShown_andBrowsingWithTrackersShown_OnNextHomeScreenMessageNew_ReturnsFinal() {
        // GIVEN
        settings.browsingAfterSearchShown = true
        settings.browsingWithTrackersShown = true
        XCTAssertFalse(settings.browsingFinalDialogShown)

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(homeScreenMessage, .final)
        XCTAssertTrue(settings.browsingFinalDialogShown)
    }

    func testIfBrowsingAfterSearchShown_andBrowsingWithoutTrackersShown_OnNextHomeScreenMessageNew_ReturnsFinal() {
        // GIVEN
        settings.browsingAfterSearchShown = true
        settings.browsingWithoutTrackersShown = true
        XCTAssertFalse(settings.browsingFinalDialogShown)

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertEqual(homeScreenMessage, .final)
        XCTAssertTrue(settings.browsingFinalDialogShown)
    }

    func testIfBrowsingAfterSearchShown_andBrowsingMajorTrackingSiteShown_andFinalDialogAlreadyShown_OnNextHomeScreenMessageNew_ReturnsNil() {
        // GIVEN
        settings.browsingAfterSearchShown = true
        settings.browsingMajorTrackingSiteShown = true
        settings.browsingFinalDialogShown = true

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertNil(homeScreenMessage)
    }

    func testIfBrowsingAfterSearchShown_andBrowsingWithTrackersShown_andFinalDialogAlreadyShown_OnNextHomeScreenMessageNew_ReturnsNil() {
        // GIVEN
        settings.browsingAfterSearchShown = true
        settings.browsingWithTrackersShown = true
        settings.browsingFinalDialogShown = true

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertNil(homeScreenMessage)
    }

    func testIfBrowsingAfterSearchShown_andBrowsingWithoutTrackersShown_andFinalDialogAlreadyShown_OnNextHomeScreenMessageNew_ReturnsNil() {
        // GIVEN
        settings.browsingAfterSearchShown = true
        settings.browsingWithoutTrackersShown = true
        settings.browsingFinalDialogShown = true

        // WHEN
        let homeScreenMessage = daxDialogs.nextHomeScreenMessageNew()

        // THEN
        XCTAssertNil(homeScreenMessage)
    }

}

class MockDaxDialogsSettings: DaxDialogsSettings {
    var isDismissed: Bool = false

    var homeScreenMessagesSeen: Int = 0

    var browsingAfterSearchShown: Bool = false

    var browsingWithTrackersShown: Bool = false

    var browsingWithoutTrackersShown: Bool = false

    var browsingMajorTrackingSiteShown: Bool = false

    var fireButtonEducationShownOrExpired: Bool = false

    var fireButtonPulseDateShown: Date?

    var browsingFinalDialogShown: Bool = false
}
