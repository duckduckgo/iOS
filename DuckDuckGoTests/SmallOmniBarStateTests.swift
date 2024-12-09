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

class SmallOmniBarStateTests: XCTestCase {

    let enabledVoiceSearchHelper = MockVoiceSearchHelper(isSpeechRecognizerAvailable: true)
    let disabledVoiceSearchHelper = MockVoiceSearchHelper(isSpeechRecognizerAvailable: false)
    
    func testWhenInHomeEmptyEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: disabledVoiceSearchHelper, isLoading: false)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    
    func testWhenInHomeEmptyEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenEnteringHomeEmptyEditingStateThenTextIsCleared() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: disabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenInHomeTextEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    
    func testWhenEnteringHomeTextEditingStateThenTextIsNotCleared() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenEnteringTextMaintainsState() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: disabledVoiceSearchHelper, isLoading: false)
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    
    func testWhenInHomeNonEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertTrue(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenEnteringHomeNonEditingStateThenTextIsCleared() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.HomeTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowserEmptyEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: disabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenInBrowserEmptyEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    
    func testWhenEnteringBrowserEmptyEditingStateThenTextIsCleared() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: disabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenInBrowsingTextEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertTrue(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    
    func testWhenEnteringBrowsingTextEditingStateThenTextIsMaintained() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShown() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertTrue(testee.showBackground)
        XCTAssertTrue(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertFalse(testee.showAbort)
        XCTAssertTrue(testee.showRefresh)

        XCTAssertFalse(testee.hasLargeWidth)
        XCTAssertFalse(testee.showBackButton)
        XCTAssertFalse(testee.showForwardButton)
        XCTAssertFalse(testee.showBookmarksButton)
        XCTAssertTrue(testee.showAccessoryButton)
    }

    func testWhenEnteringBrowsingNonEditingStateThenTextIsMaintained() {
        let testee = SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingNonEditingStateThenToBrowsingTextEditingStartedState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, SmallOmniBarState.BrowsingTextEditingStartedState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }
    
    func testWhenInBrowsingEditingStartedStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.BrowsingTextEditingStartedState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, SmallOmniBarState.BrowsingTextEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, SmallOmniBarState.BrowsingEmptyEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = SmallOmniBarState.BrowsingNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, SmallOmniBarState.HomeNonEditingState(voiceSearchHelper: enabledVoiceSearchHelper, isLoading: false).name)
    }
}
