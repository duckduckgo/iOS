//
//  SmallOmniBarStateTests.swift
//  DuckDuckGo
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

import Foundation

import XCTest
@testable import DuckDuckGo

// swiftlint:disable type_body_length
class SmallOmniBarStateTests: XCTestCase {

    func testWhenInHomeEmptyEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeEmptyEditingStateThenTextIsCleared() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeTextEditingStateThenTextIsNotCleared() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenEnteringTextMaintainstState() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeNonEditingStateThenTextIsCleared() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInBrowserEmptyEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringBrowserEmptyEditingStateThenTextIsCleared() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringBrowsingTextEditingStateThenTextIsMaintained() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertTrue(testee.showBackground)
        XCTAssertTrue(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringBrowsingNonEditingStateThenTextIsMaintained() {
        let testee = SmallOmniBarState.BrowsingTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStartedTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeNonEditingState().name)
    }
}
// swiftlint:enable type_body_length
