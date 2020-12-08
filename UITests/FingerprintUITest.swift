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
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let app = XCUIApplication()

        app.toolbars["Toolbar"]/*@START_MENU_TOKEN@*/.buttons["Fire"]/*[[".buttons[\"Close all tabs and clear data\"]",".buttons[\"Fire\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.sheets.scrollViews.otherElements.buttons["Close Tabs and Clear Data"].tap()
        
        app
            /*@START_MENU_TOKEN@*/.searchFields["searchEntry"]/*[[".searchFields[\"Search or enter address\"]",".searchFields[\"searchEntry\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            .tap()
        app
            .searchFields["searchEntry"]
            .typeText("https://privacy-test-pages.glitch.me/privacy-protections/fingerprinting/\n")
        let webview = app.webViews.firstMatch
        XCTAssertTrue(webview.staticTexts["⚠️ Please note that:"].firstMatch.waitForExistence(timeout: 25), "Page not loaded")
        
        webview
            /*@START_MENU_TOKEN@*/.buttons["Start the test"]/*[[".otherElements[\"Fingerprinting test page\"].buttons[\"Start the test\"]",".buttons[\"Start the test\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            .tap()
        XCTAssertTrue(webview.staticTexts["Click for details."].waitForExistence(timeout: 25), "Test not run")
    }

}
