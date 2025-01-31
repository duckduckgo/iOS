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

    override func setUp() {
        super.setUp()
        toolbarHandler = ToolbarHandler()
        mockToolbar = UIToolbar()
        mockNavigatable = MockNavigatable(canGoBack: true, canGoForward: false)
    }

    override func tearDown() {
        toolbarHandler = nil
        mockToolbar = nil
        mockNavigatable = nil
        super.tearDown()
    }

    func testUpdateTabbarWithStateNewTab() {
        toolbarHandler.updateTabbarWithState(toolBar: mockToolbar, state: .newTab)

        XCTAssertEqual(mockToolbar.items?.count, 9)
        XCTAssertEqual(mockToolbar.items?[0].title, UserText.actionOpenBookmarks)
        XCTAssertEqual(mockToolbar.items?[2].title, UserText.actionOpenPasswords)
        XCTAssertEqual(mockToolbar.items?[4].title, UserText.actionForgetAll)
        XCTAssertEqual(mockToolbar.items?[6].title, UserText.tabSwitcherAccessibilityLabel)
        XCTAssertEqual(mockToolbar.items?[8].title, UserText.menuButtonHint)
    }

    func testUpdateTabbarWithStatePageLoaded() {
        toolbarHandler.updateTabbarWithState(toolBar: mockToolbar, state: .pageLoaded(currentTab: mockNavigatable))

        XCTAssertEqual(mockToolbar.items?.count, 9)
        XCTAssertEqual(mockToolbar.items?[0].title, UserText.keyCommandBrowserBack)
        XCTAssertEqual(mockToolbar.items?[2].title, UserText.keyCommandBrowserForward)
        XCTAssertEqual(mockToolbar.items?[4].title, UserText.actionForgetAll)
        XCTAssertEqual(mockToolbar.items?[6].title, UserText.tabSwitcherAccessibilityLabel)
        XCTAssertEqual(mockToolbar.items?[8].title, UserText.menuButtonHint)

        XCTAssertTrue(toolbarHandler.backButton.isEnabled)
        XCTAssertFalse(toolbarHandler.forwardButton.isEnabled)
    }

    func testUpdateTabbarWithStateNoChange() {
        toolbarHandler.updateTabbarWithState(toolBar: mockToolbar, state: .newTab)
        let initialItems = mockToolbar.items

        toolbarHandler.updateTabbarWithState(toolBar: mockToolbar, state: .newTab)

        XCTAssertEqual(mockToolbar.items, initialItems)
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
