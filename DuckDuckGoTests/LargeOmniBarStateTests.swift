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
    var mockFeatureFlagger: MockFeatureFlagger!

    override func setUp() {
        super.setUp()
        mockFeatureFlagger = MockFeatureFlagger(enabledFeatureFlags: [.aiChatNewTabPage])
    }

    override func tearDown() {
        mockFeatureFlagger = nil
        super.tearDown()
    }

    func testWhenInHomeEmptyEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: disabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    
    func testWhenInHomeEmptyEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenEnteringHomeEmptyEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenClearingTextMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeEmptyEditingStateThenBrowsingStoppedMaintainsState() {
        let testee = LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: disabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenInHomeTextEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)

        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertFalse(testee.showMenu)
        XCTAssertTrue(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }
    func testWhenEnteringHomeTextEditingStateThenTextIsNotCleared() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInHomeTextEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenEnteringTextMaintainstState() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
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

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenInHomeNonEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: disabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
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

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertFalse(testee.showAccessoryButton)
    }

    func testWhenEnteringHomeNonEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInHomeNonEditingStateThenEditingStartedTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.HomeTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStartedTransitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInHomeNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowserEmptyEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: disabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showAccessoryButton)
    }

    func testWhenInBrowserEmptyEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showAccessoryButton)
    }
    func testWhenEnteringBrowserEmptyEditingStateThenTextIsCleared() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertTrue(testee.clearTextOnStart)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEditingStoppedTrainsitionsToBrowsingNonEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenClearingMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingEmptyEditingStateThenBrowsingStoppedTransitionsToHomeEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateWithVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertTrue(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showAccessoryButton)
    }

    func testWhenInBrowsingTextEditingStateWithoutVoiceSearchThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: disabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.showBackground)
        XCTAssertFalse(testee.showPrivacyIcon)
        XCTAssertTrue(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertTrue(testee.showSearchLoupe)
        XCTAssertFalse(testee.showVoiceSearch)
        XCTAssertFalse(testee.showAbort)
        XCTAssertFalse(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showAccessoryButton)
    }

    func testWhenEnteringBrowsingTextEditingStateThenTextIsMaintained() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenEditingStoppedTrainsitionsToNonEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenEnteringTextMaintainstState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStartedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingTextEditingStateThenBrowsingStoppedTransitionsToHomeTextEditingState() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenCorrectButtonsAreShown() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertTrue(testee.showBackground)
        XCTAssertTrue(testee.showPrivacyIcon)
        XCTAssertFalse(testee.showClear)
        XCTAssertTrue(testee.showMenu)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showCancel)
        XCTAssertFalse(testee.showSearchLoupe)
        XCTAssertFalse(testee.showAbort)
        XCTAssertTrue(testee.showRefresh)

        XCTAssertTrue(testee.hasLargeWidth)
        XCTAssertTrue(testee.showBackButton)
        XCTAssertTrue(testee.showForwardButton)
        XCTAssertTrue(testee.showBookmarksButton)
        XCTAssertTrue(testee.showAccessoryButton)
    }

    func testWhenEnteringBrowsingNonEditingStateThenTextIsMaintained() {
        let testee = LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertFalse(testee.clearTextOnStart)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStartedTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStartedState.name, LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenEditingStoppedMaintainsState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onEditingStoppedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenEnteringTextTransitionsToTextEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextEnteredState.name, LargeOmniBarState.BrowsingTextEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenClearingTextTransitionsToEmptyEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onTextClearedState.name, LargeOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStartedMaintainstState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStartedState.name, LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }

    func testWhenInBrowsingNonEditingStateThenBrowsingStoppedTransitionsToHomeNonEditingState() {
        let testee = LargeOmniBarState.BrowsingNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false)
        XCTAssertEqual(testee.onBrowsingStoppedState.name, LargeOmniBarState.HomeNonEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: enabledVoiceSearchHelper, featureFlagger: mockFeatureFlagger), isLoading: false).name)
    }
}
