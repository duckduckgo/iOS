//
//  LargeOmniBarStateTests.swift
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
class LargeOmniBarStateTests: XCTestCase {

    func testWhenInHomeEmptyEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeEmptyEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeTextEditingStateThenTextIsNotCleared() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenEnteringTextMaintainstState() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeNonEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeNonEditingState().name)
    }

    func testWhenInBrowserEmptyEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
    }

    func testWhenEnteringBrowserEmptyEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
}

    func testWhenEnteringBrowsingTextEditingStateThenTextIsMaintained() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertTrue(testee.showBackground)
        XCTAssertTrue(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
    }

    func testWhenEnteringBrowsingNonEditingStateThenTextIsMaintained() {
        let testee = LargeOmniBarState.BrowsingTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStartedTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeNonEditingState().name)
    }
}
// swiftlint:enable type_body_length
