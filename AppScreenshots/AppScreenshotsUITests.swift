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
import SimulatorStatusMagiciOS

class AppScreenshotsUITests: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()

        SDStatusBarManager.sharedInstance().enableOverrides()

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        skipOnboarding()
        clearTabsAndData()

        continueAfterFailure = false

    }

    override func tearDown() {
        super.tearDown()

        SDStatusBarManager.sharedInstance().disableOverrides()
    }

    func testTakeStartScreenShot() {
        waitForToastToDisappear()
        snapshot("Start Screen")
    }

    func testTakeTabSwitcherSearchResultsAndAutoCompleteScreenshots() {

        newTab()

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
        waitForLoadingIndicatorToDisappear()
        tapSiteRating()
        snapshot("Tracker Blocking")
    }

    // MARK: private

    private func skipOnboarding() {
        guard app.staticTexts["Search Anonymously"].exists else { return  }
        app.pageIndicators["page 1 of 2"].tap()
        app.buttons["Done"].tap()
    }

    private func tapSiteRating() {
        app.otherElements["siteRating"].tap()
    }

    private func showTabs() {
        app.toolbars.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .button).element(boundBy: 3).tap()
    }
    
    private func addTab() {
        app.toolbars.buttons["Add"].tap()
    }

    private func newTab() {
        showTabs()
        addTab()
    }

    private func enterSearch(_ text: String, submit: Bool = true) {
        print("enterSearch text:", text, "submit:", submit)

        let searchOrTypeUrlTextField = app.textFields["Search or type URL"]
        searchOrTypeUrlTextField.typeText(text)

        if submit {
            searchOrTypeUrlTextField.typeText("\n")
        }
    }

    private func saveBookmark() {
        let app = XCUIApplication()
        app.buttons["Menu"].tap()
        app.sheets.buttons["Add to Bookmarks"].tap()
        app.alerts["Save Bookmark"].buttons["Save"].tap()
    }
    
    private func clearTabsAndData() {
        app.toolbars.buttons["Fire"].tap()
        app.sheets.buttons["Clear Tabs and Data"].tap()
    }

    private func screenshotTabSwitcher() {
        enterSearch("https://twitter.com/duckduckgo")
        waitForLoadingIndicatorToDisappear()
        waitForPageTitle()
        newTab()
        enterSearch("https://dribbble.com/duckduckgo")
        waitForLoadingIndicatorToDisappear()
        waitForPageTitle()
        showTabs()
        snapshot("Tab Switcher")
    }

    private func screenshotSearchResults() {
        enterSearch("https://duckduckgo.com?q=bars%20in%20portland&kl=us-en&k1=-1")
        waitForLoadingIndicatorToDisappear()
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

    private func waitForLoadingIndicatorToDisappear() {
        sleep(5)
    }

}
