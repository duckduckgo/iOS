//
//  PhoneOmniBarStateTests.swift
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

class PhoneOmniBarStateTests: XCTestCase {

    func testWhenInHomeEmptyEditingStateThenCorrectButtonsAreShow() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
    }

    func testWhenEnteringHomeEmptyEditingStateThenTextIsCleared() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, PhoneOmniBar.HomeNonEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, PhoneOmniBar.HomeTextEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = PhoneOmniBar.HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenCorrectButtonsAreShow() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
    }

    func testWhenEnteringHomeTextEditingStateThenTextIsNotCleared() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, PhoneOmniBar.HomeTextEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, PhoneOmniBar.HomeNonEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenEnteringTextMaintainstState() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, PhoneOmniBar.HomeTextEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = PhoneOmniBar.HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenCorrectButtonsAreShow() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
    }

    func testWhenEnteringHomeNonEditingStateThenTextIsCleared() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, PhoneOmniBar.HomeNonEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, PhoneOmniBar.HomeTextEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = PhoneOmniBar.HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, PhoneOmniBar.HomeNonEditingState().name)
    }

    func testWhenInBrowserEmptyEditingStateThenCorrectButtonsAreShow() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
    }

    func testWhenEnteringBrowserEmptyEditingStateThenTextIsCleared() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, PhoneOmniBar.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, PhoneOmniBar.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, PhoneOmniBar.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, PhoneOmniBar.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = PhoneOmniBar.BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenCorrectButtonsAreShow() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
    }

    func testWhenEnteringBrowsingTextEditingStateThenTextIsMaintained() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, PhoneOmniBar.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, PhoneOmniBar.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, PhoneOmniBar.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, PhoneOmniBar.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, PhoneOmniBar.HomeEmptyEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShow() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertTrue(testee.showBackground)
        XCTAssertTrue(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
    }

    func testWhenEnteringBrowsingNonEditingStateThenTextIsMaintained() {
        let testee = PhoneOmniBar.BrowsingTextEditingState()
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStartedTransitionsToTextEditingState() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, PhoneOmniBar.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, PhoneOmniBar.BrowsingTextEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, PhoneOmniBar.BrowsingEmptyEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, PhoneOmniBar.BrowsingNonEditingState().name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = PhoneOmniBar.BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, PhoneOmniBar.HomeNonEditingState().name)
    }
}
