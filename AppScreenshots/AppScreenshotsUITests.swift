//
//  AppScreenshotsUITests.swift
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

class AppScreenshotsUITests: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        skipOnboarding()
        clearTabsAndData()

        continueAfterFailure = false

    }

    func testTakeStartScreenShot() {
        waitForToastToDisappear()
        snapshot("Start Screen")
    }

    func testTakeTabSwitcherSearchResultsAndAutoCompleteScreenshots() {

        screenshotTabSwitcher()

        addTab()

        screenshotSearchResults()

        newTab()

        screenshotAutoComplete()
    }

    func testScreenshotSiteRating() {
        newTab()
        enterSearch("https://nytimes.com/2017/08/24/books/review/10-new-books-we-recommend-this-week.html")
        sleep(5)
        Snapshot.waitForLoadingIndicatorToDisappear()
        tapSiteRating()
        snapshot("Tracker Blocking")
    }

    // MARK: private

    private func skipOnboarding() {
        guard app.staticTexts["Real Privacy"].exists else { return  }

        XCUIApplication().children(matching: .window)
            .element(boundBy: 0).children(matching: .other)
            .element.children(matching: .other)
            .element.children(matching: .other)
            .element(boundBy: 1).children(matching: .button)
            .element.tap()

    }

    private func tapSiteRating() {
        let bar = app.navigationBars["DuckDuckGo.MainView"]
        if bar.staticTexts["A"].exists {
            bar.staticTexts["A"].tap()
        } else if bar.staticTexts["B"].exists {
            bar.staticTexts["B"].tap()
        } else if bar.staticTexts["C"].exists {
            bar.staticTexts["C"].tap()
        }
    }

    private func showTabs() {
        app.toolbars.buttons["Tabs"].tap()
    }

    private func addTab() {
        app.toolbars.containing(.button, identifier:"Add").buttons["Add"].tap()
    }

    private func newTab() {
        showTabs()
        addTab()
    }

    private func enterSearch(_ text: String, submit: Bool = true) {
        print("enterSearch text:", text, "submit:", submit)

        let searchOrTypeUrlTextField = app.navigationBars["DuckDuckGo.MainView"].textFields["Search or type URL"]
        searchOrTypeUrlTextField.typeText(text)

        if submit {
            app.typeText("\n")
        }
    }

    private func saveBookmark() {
        let app = XCUIApplication()
        app.navigationBars["DuckDuckGo.MainView"].buttons["Menu"].tap()
        app.sheets.buttons["Add to Bookmarks"].tap()
        app.alerts["Save Bookmark"].buttons["Save"].tap()
    }

    private func clearTabsAndData() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.children(matching: .button).element(boundBy: 2).tap()
        app.sheets.buttons["Clear Tabs and Data"].tap()
    }

    private func screenshotTabSwitcher() {
        app.staticTexts["Search or type URL"].tap()
        enterSearch("https://twitter.com/duckduckgo")
        Snapshot.waitForLoadingIndicatorToDisappear()
        waitForPageTitle()
        newTab()
        enterSearch("https://dribbble.com/duckduckgo")
        Snapshot.waitForLoadingIndicatorToDisappear()
        waitForPageTitle()
        showTabs()
        snapshot("Tab Switcher")
    }

    private func screenshotSearchResults() {
        enterSearch("https://duckduckgo.com?q=bars%20in%20portland&kl=us-en&k1=-1")
        Snapshot.waitForLoadingIndicatorToDisappear()
        waitForPageTitle()
        snapshot("Search Results")
    }

    private func screenshotAutoComplete() {
        enterSearch("tycho", submit: false)
        snapshot("Autocomplete")
    }

    private func waitForPageTitle() {
        sleep(2)
    }

    private func waitForToastToDisappear() {
        sleep(6)
    }

}
