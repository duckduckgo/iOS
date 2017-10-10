//
//  ContentBlockerTests.swift
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

class ContentBlockerTests: XCTestCase {
    
    struct TrackerPageUrl {
        static let noTrackers = "http://localhost:8000/notrackers.html"
        static let iFrames = "http://localhost:8000/iframetrackers.html"
        static let resources = "http://localhost:8000/resourcetrackers.html"
        static let requests = "http://localhost:8000/requesttrackers.html"
    }
    
    struct PageElementIndex {
        static let uniqueTrackerCount: UInt = 2
    }
    
    struct Timeout {
        static let postFirstLaunch: UInt32 = 10
        static let pageLoad = 20
        static let postPageLoad: UInt32 = 1
    }
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        skipOnboarding()
        clearTabsAndData()
        continueAfterFailure = true
    }
    
    func testThatNothingIsBlockedOnCleanPage() {
        checkContentBlocking(onTestPage: TrackerPageUrl.noTrackers)
    }

    func testThatIFramesAreBlocked() {
        checkContentBlocking(onTestPage: TrackerPageUrl.iFrames)
    }
    
    func testThatResourcesAreBlocked() {
        checkContentBlocking(onTestPage: TrackerPageUrl.resources)
    }
    
    func testThatRequestsAreBlocked() {
        checkContentBlocking(onTestPage: TrackerPageUrl.requests)
    }
    
    func checkContentBlocking(onTestPage url: String) {
        
        newTab()
        
        enterSearch(url)
        
        waitForPageLoad()
        
        openContentBlocker()
        
        let popoverTrackerCount = app.tables.staticTexts["trackerCount"]
        let webTrackerCount = app.webViews.staticTexts.element(boundBy: PageElementIndex.uniqueTrackerCount)
        
        XCTAssertTrue(popoverTrackerCount.exists)
        XCTAssertTrue(webTrackerCount.exists)
        XCTAssertEqual(popoverTrackerCount.label, webTrackerCount.label)
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
    
    private func skipOnboarding() {
        guard app.staticTexts["Search Anonymously"].exists else { return }
        app.pageIndicators["page 1 of 2"].tap()
        app.buttons["Done"].tap()
        sleep(Timeout.postFirstLaunch)
    }
    
    private func clearTabsAndData() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.children(matching: .button).element(boundBy: 2).tap()
        app.sheets.buttons["Clear Tabs and Data"].tap()
    }
    
    private func enterSearch(_ text: String, submit: Bool = true) {
        print("enterSearch text:", text, "submit:", submit)
        
        let searchOrTypeUrlTextField = app.navigationBars["DuckDuckGo.MainView"].textFields["Search or type URL"]
        searchOrTypeUrlTextField.typeText(text)
        
        if submit {
            app.typeText("\n")
        }
    }
    
    private func waitForPageLoad() {
        SnapShotHelperExcerpt.waitForLoadingIndicators(timeout: Timeout.pageLoad)
        sleep(Timeout.postPageLoad)
    }
    
    private func openContentBlocker() {
        let navBar = app.navigationBars["DuckDuckGo.MainView"]
        navBar.otherElements["siteRating"].tap()
    }
}

