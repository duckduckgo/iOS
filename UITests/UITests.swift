//
//  UITests.swift
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

import XCTest

class UITests: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        clearTabsAndData()

    }

    func testTakeReleaseScreenshots() {
        snapshot("Start Screen")

        app.staticTexts["Search or type URL"].tap()
        enterSearch("https://dribbble.com/duckduckgo")
        Snapshot.waitForLoadingIndicatorToDisappear()
        newTab()
        enterSearch("https://twitter.com/duckduckgo")
        Snapshot.waitForLoadingIndicatorToDisappear()
        showTabs()
        snapshot("Tab Switcher")

        addTab()
        enterSearch("bars in portland")
        snapshot("Search Results")

    }

    func showTabs() {
        app.toolbars.buttons["Tabs"].tap()
    }

    func addTab() {
        app.toolbars.containing(.button, identifier:"Add").buttons["Add"].tap()
    }

    func newTab() {
        showTabs()
        addTab()
    }

    func enterSearch(_ text: String) {

        let searchOrTypeUrlTextField = app.navigationBars["DuckDuckGo.MainView"].textFields["Search or type URL"]
        searchOrTypeUrlTextField.tap()

        searchOrTypeUrlTextField.typeText(text)
        app.typeText("\n")
    }

    func saveBookmark() {
        let app = XCUIApplication()
        app.navigationBars["DuckDuckGo.MainView"].buttons["Menu"].tap()
        app.sheets.buttons["Add to Bookmarks"].tap()
        app.alerts["Save Bookmark"].buttons["Save"].tap()
    }

    func clearTabsAndData() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.children(matching: .button).element(boundBy: 2).tap()
        app.sheets.buttons["Clear Tabs and Data"].tap()
    }

}
