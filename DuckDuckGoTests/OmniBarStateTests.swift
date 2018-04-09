//
//  OmniBarStateTests.swift
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
@testable import DuckDuckGo

class OmniBarStateTests: XCTestCase {
    
    func testWhenInHomeEmptyEditingStateThenCorrectButtonsAreShow() {
        let testee = HomeEmptyEditingState()
        XCTAssertTrue(testee.showEditingBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showBookmarks)
    }
    
    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = HomeEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, HomeNonEditingState().name)
    }
    
    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, HomeTextEditingState().name)
    }
    
    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = HomeEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = HomeEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeTextEditingStateThenCorrectButtonsAreShow() {
        let testee = HomeTextEditingState()
        XCTAssertTrue(testee.showEditingBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showBookmarks)
    }
    
    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, HomeTextEditingState().name)
    }
    
    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = HomeTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, HomeNonEditingState().name)
    }
    
    func testWhenInHomeTextEditingStateThenEnteringTextMaintainstState() {
        let testee = HomeTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, HomeTextEditingState().name)
    }
    
    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = HomeTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = HomeTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeNonEditingStateThenCorrectButtonsAreShow() {
        let testee = HomeNonEditingState()
        XCTAssertFalse(testee.showEditingBackground)
        XCTAssertFalse(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showBookmarks)
    }
    
    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = HomeNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, HomeNonEditingState().name)
    }
    
    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = HomeNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, HomeTextEditingState().name)
    }
    
    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = HomeNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = HomeNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInBrowserEmptyEditingStateThenCorrectButtonsAreShow() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertTrue(testee.showEditingBackground)
        XCTAssertTrue(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showBookmarks)
    }
    
    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, BrowsingEmptyEditingState().name)
    }
    
    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, BrowsingTextEditingState().name)
    }
    
    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, BrowsingEmptyEditingState().name)
    }
    
    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, BrowsingEmptyEditingState().name)
    }
    
    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = BrowsingEmptyEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInBrowsingTextEditingStateThenCorrectButtonsAreShow() {
        let testee = BrowsingTextEditingState()
        XCTAssertTrue(testee.showEditingBackground)
        XCTAssertTrue(testee.showSiteRating)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showBookmarks)
    }
    
    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, BrowsingTextEditingState().name)
    }
    
    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = BrowsingTextEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, BrowsingTextEditingState().name)
    }
    
    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = BrowsingTextEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, BrowsingEmptyEditingState().name)
    }
    
    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, BrowsingTextEditingState().name)
    }
    
    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = BrowsingTextEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, HomeEmptyEditingState().name)
    }
    
    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShow() {
        let testee = BrowsingNonEditingState()
        XCTAssertFalse(testee.showEditingBackground)
        XCTAssertTrue(testee.showSiteRating)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showBookmarks)
    }
    
    func testWhenInBrowsingNonEditingStateThenEditingStartedTransitionsToTextEditingState() {
        let testee = BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStartedState.name, BrowsingTextEditingState().name)
    }
    
    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = BrowsingNonEditingState()
        XCTAssertEqual(testee.onEditingStoppedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextEnteredState.name, BrowsingTextEditingState().name)
    }
    
    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = BrowsingNonEditingState()
        XCTAssertEqual(testee.onTextClearedState.name, BrowsingEmptyEditingState().name)
    }
    
    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStartedState.name, BrowsingNonEditingState().name)
    }
    
    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = BrowsingNonEditingState()
        XCTAssertEqual(testee.onBrowsingStoppedState.name, HomeEmptyEditingState().name)
    }
}
