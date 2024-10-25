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
@testable import Core
@testable import DuckDuckGo

class LargeOmniBarStateTests: XCTestCase {

    let enabledVoiceSearchHelper = MockVoiceSearchHelper(isSpeechRecognizerAvailable: true)
    let disabledVoiceSearchHelper = MockVoiceSearchHelper(isSpeechRecognizerAvailable: false)

    func testWhenInHomeEmptyEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: disabledVoiceSearchHelper)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }
    
    func testWhenInHomeEmptyEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeEmptyEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeTextEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: disabledVoiceSearchHelper)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenInHomeTextEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        
        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }
    func testWhenEnteringHomeTextEditingStateThenTextIsNotCleared() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeTextEditingStateThenEnteringTextMaintainstState() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeNonEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }
    
    func testWhenInHomeNonEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: disabledVoiceSearchHelper)
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showShareButton)
    }

    func testWhenEnteringHomeNonEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowserEmptyEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: disabledVoiceSearchHelper)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
    }

    func testWhenInBrowserEmptyEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
    }
    
    func testWhenEnteringBrowserEmptyEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingTextEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
}
    
    func testWhenInBrowsingTextEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: disabledVoiceSearchHelper)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showShareButton)
}

    func testWhenEnteringBrowsingTextEditingStateThenTextIsMaintained() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertTrue(testee.showBackground)
        XCTAssertTrue(testee.showPrivacyIcon)
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
        let testee = LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStartedTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper).name)
    }
}
