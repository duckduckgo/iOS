//
//  FingerprintUITest.swift
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

// swiftlint:disable line_length

import XCTest

class FingerprintUITest: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        
        app.launchEnvironment = [
            "DAXDIALOGS": "false",
            "ONBOARDING": "false",
            "VARIANT": "sc",
            "UITESTING": "true"
        ]
        
        app.launch()

        // Add a bookmark to edit to a bookmarklet later
        app.searchFields["searchEntry"].tap()
        
        sleep(1)
        
        app
            .searchFields["searchEntry"]
            .typeText("https://duckduckgo.com\n")
        
        sleep(5) // let site load

        _ = app.buttons["Browsing Menu"].waitForExistence(timeout: 25)
        app.buttons["Browsing Menu"].tap()

        if app.tables.staticTexts["Add Bookmark"].waitForExistence(timeout: 2) {
            app.tables.staticTexts["Add Bookmark"].tap()
        } else if app.tables.staticTexts["Bookmarks"].waitForExistence(timeout: 2) {
            dismissMenu()
            removeTheBookmark()
            
            app.buttons["Browsing Menu"].tap()
            if app.tables.staticTexts["Add Bookmark"].waitForExistence(timeout: 2) {
                app.tables.staticTexts["Add Bookmark"].tap()
            } else {
                XCTFail("Could not ensure one bookmark is present")
            }
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        removeTheBookmark()
    }
    
    func dismissMenu() {
        let app = XCUIApplication()
        app.otherElements["Browsing Menu Background"].tap()
    }
    
    func removeTheBookmark() {
        // Remove the bookmark we added
        let app = XCUIApplication()

        _ = app.buttons["Browsing Menu"].waitForExistence(timeout: 25)
        app.buttons["Browsing Menu"].tap()
        
        if app.tables.staticTexts["Bookmarks"].waitForExistence(timeout: 25) {
            app.tables.staticTexts["Bookmarks"].tap()
        }
        
        let tablesQuery = app.tables
        _ = tablesQuery.staticTexts["DuckDuckGo — Privacy, simplified."].waitForExistence(timeout: 25)
        tablesQuery.staticTexts["DuckDuckGo — Privacy, simplified."].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        app.navigationBars["Bookmarks"].buttons["Done"].tap()
    }

    func test() throws {
        let app = XCUIApplication()

        _ = app.buttons["Browsing Menu"].waitForExistence(timeout: 25)
        app.buttons["Browsing Menu"].tap()

        if app.tables.staticTexts["Bookmarks"].waitForExistence(timeout: 2) {
            app.tables.staticTexts["Bookmarks"].tap()
        } else {
            XCTFail("Bookmarks button missing")
        }
        
        // Edit bookmark into bookmarklet to verify fingerprinting test
        let bookmarksToolbarButtons = app.toolbars.buttons
        _ = bookmarksToolbarButtons["Edit"].waitForExistence(timeout: 25)
        bookmarksToolbarButtons["Edit"].tap()
        if app.tables.staticTexts["DuckDuckGo — Privacy, simplified."].waitForExistence(timeout: 25) {
            app.staticTexts["DuckDuckGo — Privacy, simplified."].tap()
        } else {
            XCTFail("Could not find bookmark")
        }
        
        app.textFields.matching(identifier: "URL").firstMatch.clear()
        app.textFields.matching(identifier: "URL").firstMatch
            .typeText("javascript:(function(){const values = {'screen.availTop': 0,'screen.availLeft': 0,'screen.availWidth': screen.width,'screen.availHeight': screen.height,'screen.colorDepth': 24,'screen.pixelDepth': 24,'window.screenY': 0,'window.screenLeft': 0,'navigator.doNotTrack': undefined};var passed = true;var reason = null;for (const test of results.results) {if (values[test.id] !== undefined) {if (values[test.id] !== test.value) {console.log(test.id, values[test.id]);reason = test.id;passed = false;break;}}}var elem = document.createElement('p');elem.innerHTML = (passed) ? 'TEST PASSED' : 'TEST FAILED: ' + reason;document.body.insertBefore(elem, document.body.childNodes[0]);}());")
        app.navigationBars.buttons["Save"].tap()
        app.toolbars.buttons["Done"].tap()
        app.navigationBars.buttons["Done"].tap()
        
        // Clear all tabs and data
        app.toolbars["Toolbar"].buttons["Fire"].tap()
        app.buttons["Close Tabs and Clear Data"].tap()
        
        sleep(2)
        
        // Go to fingerprinting test page
        app
            .searchFields["searchEntry"]
            .tap()
        app
            .searchFields["searchEntry"]
            .typeText("https://privacy-test-pages.site/privacy-protections/fingerprinting/?run\n")
        let webview = app.webViews.firstMatch
        XCTAssertTrue(webview.staticTexts["⚠️ Please note that:"].firstMatch.waitForExistence(timeout: 25), "Page not loaded")
        
        // Run the new bookmarklet
        app.buttons["Browsing Menu"].tap()
        if app.tables.staticTexts["Bookmarks"].waitForExistence(timeout: 2) {
            app.tables.staticTexts["Bookmarks"].tap()
        } else {
            XCTFail("Bookmarks button missing")
        }
        app.tables.staticTexts["DuckDuckGo — Privacy, simplified."].tap()
        
        // Verify the test passed
        XCTAssertTrue(webview.staticTexts["TEST PASSED"].waitForExistence(timeout: 25), "Test not run")
    }

}

extension XCUIElement {
    
    // https://stackoverflow.com/a/38523252
    public func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        let lowerRightCorner = self.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
        lowerRightCorner.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }

}

// swiftlint:enable line_length
