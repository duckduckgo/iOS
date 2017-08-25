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
@testable import Core

class UITests: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        clearTabsAndData()

        continueAfterFailure = false

    }

    func testStartScreen() {
        sleep(6) // wait for toast to go away
        snapshot("Start Screen")
    }

    func testTakeReleaseScreenshots() {

        screenshotTabSwitcher()

        addTab()

        screenshotSearchResults()

        newTab()

        screenshotAutoComplete()
    }

    func testScreenshotSiteRating() {
        newTab()
        enterSearch("https://nytimes.com/2017/08/24/books/review/10-new-books-we-recommend-this-week.html")
        Snapshot.waitForLoadingIndicatorToDisappear()
        tapSiteRating()
        snapshot("Tracker Blocking")
    }

    func tapSiteRating() {
        let bar = XCUIApplication().navigationBars["DuckDuckGo.MainView"]
        if bar.staticTexts["A"].exists {
            bar.staticTexts["A"].tap()
        } else if bar.staticTexts["B"].exists {
            bar.staticTexts["B"].tap()
        } else if bar.staticTexts["C"].exists {
            bar.staticTexts["C"].tap()
        }
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

    func enterSearch(_ text: String, submit: Bool = true) {
        print("enterSearch text:", text, "submit:", submit)

        let searchOrTypeUrlTextField = app.navigationBars["DuckDuckGo.MainView"].textFields["Search or type URL"]
        searchOrTypeUrlTextField.typeText(text)

        if submit {
            app.typeText("\n")
        }
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

    func screenshotTabSwitcher() {
        app.staticTexts["Search or type URL"].tap()
        enterSearch("https://twitter.com/duckduckgo")
        Snapshot.waitForLoadingIndicatorToDisappear()
        sleep(2)
        newTab()
        enterSearch("https://dribbble.com/duckduckgo")
        Snapshot.waitForLoadingIndicatorToDisappear()
        sleep(2)
        showTabs()
        snapshot("Tab Switcher")
    }

    func screenshotSearchResults() {
        enterSearch("https://duckduckgo.com?q=bars%20in%20portland&kl=us-en&k1=-1")
        Snapshot.waitForLoadingIndicatorToDisappear()
        sleep(3)
        snapshot("Search Results")
    }

    func screenshotAutoComplete() {
        enterSearch("tycho", submit: false)
        snapshot("Autocomplete")
    }

}
