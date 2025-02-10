//
//  OmniBarEqualityCheckTests.swift
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
import BrowserServicesKit

final class OmniBarEqualityCheckTests: XCTestCase {
    func testRequiresUpdateChecksForIsLoading() {
        let loadingOmniBarState = DummyOmniBarState(isLoading: true)
        let notLoadingOmniBarState = DummyOmniBarState(isLoading: false)

        XCTAssertTrue(loadingOmniBarState.requiresUpdate(transitioningInto: notLoadingOmniBarState))
    }

    func testRequiresUpdateChecksForName() {
        let fooOmniBarState = DummyOmniBarState(name: "foo")
        let barOmniBarState = DummyOmniBarState(name: "bar")

        XCTAssertTrue(fooOmniBarState.requiresUpdate(transitioningInto: barOmniBarState))
    }

    func testIsDifferentStateChecksForName() {
        let fooOmniBarState = DummyOmniBarState(name: "foo")
        let barOmniBarState = DummyOmniBarState(name: "bar")

        XCTAssertTrue(fooOmniBarState.isDifferentState(than: barOmniBarState))
    }

    func testIsDifferentStateIgnoresOtherProperties() {
        let fooOmniBarState = DummyOmniBarState()
        var barOmniBarState = DummyOmniBarState()

        barOmniBarState.hasLargeWidth = !fooOmniBarState.hasLargeWidth
        barOmniBarState.showBackButton = !fooOmniBarState.showBackButton
        barOmniBarState.showForwardButton = !fooOmniBarState.showForwardButton
        barOmniBarState.showBookmarksButton = !fooOmniBarState.showBookmarksButton
        barOmniBarState.showAccessoryButton = !fooOmniBarState.showAccessoryButton
        barOmniBarState.clearTextOnStart = !fooOmniBarState.clearTextOnStart
        barOmniBarState.allowsTrackersAnimation = !fooOmniBarState.allowsTrackersAnimation
        barOmniBarState.showSearchLoupe = !fooOmniBarState.showSearchLoupe
        barOmniBarState.showCancel = !fooOmniBarState.showCancel
        barOmniBarState.showPrivacyIcon = !fooOmniBarState.showPrivacyIcon
        barOmniBarState.showBackground = !fooOmniBarState.showBackground
        barOmniBarState.showClear = !fooOmniBarState.showClear
        barOmniBarState.showRefresh = !fooOmniBarState.showRefresh
        barOmniBarState.showMenu = !fooOmniBarState.showMenu
        barOmniBarState.showSettings = !fooOmniBarState.showSettings
        barOmniBarState.showVoiceSearch = !fooOmniBarState.showVoiceSearch
        barOmniBarState.showAbort = !fooOmniBarState.showAbort

        XCTAssertFalse(fooOmniBarState.isDifferentState(than: barOmniBarState))
    }
}

private struct DummyOmniBarState: OmniBarState, OmniBarLoadingBearerStateCreating {
    var name: String
    var isLoading: Bool
    var dependencies: OmnibarDependencyProvider

    var hasLargeWidth = false
    var showBackButton = false
    var showForwardButton = false
    var showBookmarksButton = false
    var showAccessoryButton = false
    var clearTextOnStart = false
    var allowsTrackersAnimation = false
    var showSearchLoupe = false
    var showCancel = false
    var showPrivacyIcon = false
    var showBackground = false
    var showClear = false
    var showRefresh = false
    var showMenu = false
    var showSettings = false
    var showVoiceSearch = false
    var showAbort = false
    var showDismiss = false

    var onEditingStoppedState: OmniBarState { DummyOmniBarState() }
    var onEditingStartedState: OmniBarState { DummyOmniBarState() }
    var onTextClearedState: OmniBarState { DummyOmniBarState() }
    var onTextEnteredState: OmniBarState { DummyOmniBarState() }
    var onBrowsingStartedState: OmniBarState { DummyOmniBarState() }
    var onBrowsingStoppedState: OmniBarState { DummyOmniBarState() }
    var onEnterPhoneState: OmniBarState { DummyOmniBarState() }
    var onEnterPadState: OmniBarState { DummyOmniBarState() }
    var onReloadState: OmniBarState { DummyOmniBarState() }

    init(dependencies: OmnibarDependencyProvider, isLoading: Bool) {
        self.init(isLoading: isLoading, dependencies: dependencies)
    }

    init(name: String = "DummyOmniBarState", isLoading: Bool = false, dependencies: OmnibarDependencyProvider = MockOmnibarDependency()) {
        self.name = name
        self.isLoading = isLoading
        self.dependencies = dependencies
    }
}
