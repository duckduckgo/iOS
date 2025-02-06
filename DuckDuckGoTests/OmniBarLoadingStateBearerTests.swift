//
//  OmniBarLoadingStateBearerTests.swift
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
@testable import DuckDuckGo

final class OmniBarLoadingStateBearerTests: XCTestCase {

    static let unaffectedByLoadingStates: [(OmniBarState & OmniBarLoadingBearerStateCreating).Type] = [
        SmallOmniBarState.BrowsingEmptyEditingState.self,
        SmallOmniBarState.BrowsingTextEditingStartedState.self,
        SmallOmniBarState.BrowsingTextEditingState.self,
        SmallOmniBarState.HomeEmptyEditingState.self,
        SmallOmniBarState.HomeNonEditingState.self,
        SmallOmniBarState.HomeTextEditingState.self,
        LargeOmniBarState.BrowsingEmptyEditingState.self,
        LargeOmniBarState.BrowsingTextEditingState.self,
        LargeOmniBarState.HomeEmptyEditingState.self,
        LargeOmniBarState.HomeNonEditingState.self,
        LargeOmniBarState.HomeTextEditingState.self
    ]

    static let affectedByLoadingStates: [(OmniBarState & OmniBarLoadingBearerStateCreating).Type] = [
        SmallOmniBarState.BrowsingNonEditingState.self,
        LargeOmniBarState.BrowsingNonEditingState.self
    ]

    func testUnaffectedByLoadingStatesDoNotShowAbortButtonWhenLoading() {
        for state in Self.unaffectedByLoadingStates {
            let state = state.init(dependencies: MockOmnibarDependency(voiceSearchHelper: MockVoiceSearchHelper(isSpeechRecognizerAvailable: false)), isLoading: true)
            XCTAssertFalse(state.showAbort)
        }
    }

    func testAffectedByLoadingStatesShowAbortInPlaceOfRefreshButtonWhenLoading() {
        for state in Self.affectedByLoadingStates {
            let state = state.init(dependencies: MockOmnibarDependency(voiceSearchHelper: MockVoiceSearchHelper(isSpeechRecognizerAvailable: false)), isLoading: true)
            XCTAssertTrue(state.showAbort)
            XCTAssertFalse(state.showRefresh)
        }
    }

    func testLoadingStateIsPreservedAcrossStates() {
        let initialState = SmallOmniBarState.BrowsingEmptyEditingState(dependencies: MockOmnibarDependency(voiceSearchHelper: MockVoiceSearchHelper(isSpeechRecognizerAvailable: false)), isLoading: true)

        let lastState = initialState
            .withLoading()
            .onBrowsingStartedState
            .onBrowsingStoppedState
            .onEditingSuspendedState
            .onEnterPadState
            .onBrowsingStartedState
            .onEditingStoppedState
            .onTextClearedState
            .onTextEnteredState
            .onEnterPhoneState
            .onTextClearedState
            .onTextEnteredState

        XCTAssertTrue(lastState.isLoading)
        XCTAssertFalse(lastState.withoutLoading().isLoading)
    }
}
