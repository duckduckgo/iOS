//
//  ToolbarHandlerTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

// MARK: - ToolbarHandlerTests

class ToolbarHandlerTests: XCTestCase {

    var toolbarHandler: ToolbarHandler!
    var mockToolbar: UIToolbar!
    var mockNavigatable: MockNavigatable!
    var mockFeatureFlagger: MockFeatureFlagger!

    override func setUp() {
        super.setUp()
        mockToolbar = UIToolbar()
        mockNavigatable = MockNavigatable(canGoBack: true, canGoForward: false)
        mockFeatureFlagger = MockFeatureFlagger()
        toolbarHandler = ToolbarHandler(toolbar: mockToolbar, featureFlagger: mockFeatureFlagger)
    }

    override func tearDown() {
        toolbarHandler = nil
        mockToolbar = nil
        mockNavigatable = nil
        mockFeatureFlagger = nil
        super.tearDown()
    }

    func testUpdateToolbarWithStateNewTabFeatureOff() {
        mockFeatureFlagger.enabledFeatureFlags = []
        toolbarHandler.updateToolbarWithState(.newTab)

        XCTAssertEqual(mockToolbar.items?.count, 9)
        XCTAssertEqual(mockToolbar.items?[0].title, UserText.keyCommandBrowserBack)
        XCTAssertEqual(mockToolbar.items?[2].title, UserText.keyCommandBrowserForward)
        XCTAssertEqual(mockToolbar.items?[4].title, UserText.actionForgetAll)
        XCTAssertEqual(mockToolbar.items?[6].title, UserText.tabSwitcherAccessibilityLabel)
        XCTAssertEqual(mockToolbar.items?[8].title, UserText.actionOpenBookmarks)
    }

    func testUpdateToolbarWithStateNewTabFeatureOn() {
        mockFeatureFlagger.enabledFeatureFlags = [.aiChatNewTabPage]
        toolbarHandler.updateToolbarWithState(.newTab)

        XCTAssertEqual(mockToolbar.items?.count, 9)
        XCTAssertEqual(mockToolbar.items?[0].title, UserText.actionOpenBookmarks)
        XCTAssertEqual(mockToolbar.items?[2].title, UserText.actionOpenPasswords)
        XCTAssertEqual(mockToolbar.items?[4].title, UserText.actionForgetAll)
        XCTAssertEqual(mockToolbar.items?[6].title, UserText.tabSwitcherAccessibilityLabel)
        XCTAssertEqual(mockToolbar.items?[8].title, UserText.menuButtonHint)
    }

    func testUpdateToolbarWithStatePageLoaded() {
        toolbarHandler.updateToolbarWithState(.pageLoaded(currentTab: mockNavigatable))

        XCTAssertEqual(mockToolbar.items?.count, 9)
        XCTAssertEqual(mockToolbar.items?[0].title, UserText.keyCommandBrowserBack)
        XCTAssertEqual(mockToolbar.items?[2].title, UserText.keyCommandBrowserForward)
        XCTAssertEqual(mockToolbar.items?[4].title, UserText.actionForgetAll)
        XCTAssertEqual(mockToolbar.items?[6].title, UserText.tabSwitcherAccessibilityLabel)
        XCTAssertEqual(mockToolbar.items?[8].title, UserText.menuButtonHint)

        XCTAssertTrue(toolbarHandler.backButton.isEnabled)
        XCTAssertFalse(toolbarHandler.forwardButton.isEnabled)
    }

    func testUpdateToolbarWithStateNoChange() {
        toolbarHandler.updateToolbarWithState(.newTab)
        let initialItems = mockToolbar.items

        toolbarHandler.updateToolbarWithState(.newTab)

        XCTAssertEqual(mockToolbar.items, initialItems)
    }

    func testBackButtonEnabledState() {
        mockNavigatable = MockNavigatable(canGoBack: true, canGoForward: false)
        toolbarHandler.updateToolbarWithState(.pageLoaded(currentTab: mockNavigatable))
        XCTAssertTrue(toolbarHandler.backButton.isEnabled)

        mockNavigatable = MockNavigatable(canGoBack: false, canGoForward: false)
        toolbarHandler.updateToolbarWithState(.pageLoaded(currentTab: mockNavigatable))
        XCTAssertFalse(toolbarHandler.backButton.isEnabled)
    }

    func testForwardButtonEnabledState() {
        mockNavigatable = MockNavigatable(canGoBack: false, canGoForward: true)
        toolbarHandler.updateToolbarWithState(.pageLoaded(currentTab: mockNavigatable))
        XCTAssertTrue(toolbarHandler.forwardButton.isEnabled)

        mockNavigatable = MockNavigatable(canGoBack: false, canGoForward: false)
        toolbarHandler.updateToolbarWithState(.pageLoaded(currentTab: mockNavigatable))
        XCTAssertFalse(toolbarHandler.forwardButton.isEnabled)
    }
}

// MARK: - MockNavigatable

final class MockNavigatable: Navigatable {
    var canGoBack: Bool
    var canGoForward: Bool

    init(canGoBack: Bool, canGoForward: Bool) {
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
    }
}
