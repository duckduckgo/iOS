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

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run.
        // The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {

        let app = XCUIApplication()
        Snapshot.setupSnapshot(app)

        app.completeOnboarding("01_")
        app.showAbout("02_")

        app.searchFor("cnn")
        app.examinePrivacyDashboard("04_")

        app.searchFor("cnn.com")
        app.examinePrivacyDashboard("06_")

        app.searchFor("evanscycles.com")
        app.examinePrivacyDashboard("07_")

        app.searchFor("thehill.com")
        app.examinePrivacyDashboard("08_")

        app.toggleProtection("09_")
        app.examinePrivacyDashboard("10_")

        app.examineNetworkOffenders("11_")

    }

}

fileprivate extension XCUIApplication {

    func completeOnboarding(_ snapshotPrefix: String) {

        let continueButton = buttons["Continue"]
        Snapshot.snapshot("\(snapshotPrefix)OnboardingPage1")
        continueButton.tap()
        Snapshot.snapshot("\(snapshotPrefix)OnboardingPage1")
        continueButton.tap()
    }

    func showAbout(_ snapshotPrefix: String) {
        buttons["Settings"].tap()
        tables.cells["about"].tap()
        Snapshot.snapshot("\(snapshotPrefix)About")

        scrollViews.otherElements.buttons["aboutPage"].tap()
    }

    func searchFor(_ term: String) {
        let searchEntry = searchFields["searchEntry"]
        searchEntry.tap()
        searchEntry.typeText(term)
        keyboards.buttons["Go"].tap()
    }

    func examinePrivacyDashboard(_ snapshotPrefix: String) {

        otherElements["siteRating"].tap()
        Snapshot.snapshot("\(snapshotPrefix)01SiteRating")

        tables.otherElements["header"].tap()
        Snapshot.snapshot("\(snapshotPrefix)02ScoreCard")

        tables.buttons["backButton"].tap()
        tables.cells["encryption"].tap()
        Snapshot.snapshot("\(snapshotPrefix)03Encryption")

        tables.buttons["backButton"].tap()
        tables.cells["trackerCount"].tap()
        Snapshot.snapshot("\(snapshotPrefix)04Trackers")

        tables.buttons["backButton"].tap()
        tables.cells["privacyPractices"].tap()
        Snapshot.snapshot("\(snapshotPrefix)05PrivacyPractices")

        otherElements["siteRating"].tap()
    }

    func toggleProtection(_ snapshotPrefix: String) {
        otherElements["siteRating"].tap()

        tables.switches["privacyProtectionToggle"].tap()
        Snapshot.snapshot("\(snapshotPrefix)PrivacyToggled")

        otherElements["siteRating"].tap()
    }

    func examineNetworkOffenders(_ snapshotPrefix: String) {
        otherElements["siteRating"].tap()
        tables.otherElements["networkOffenders"].tap()
        Snapshot.snapshot("\(snapshotPrefix)NetworkOffenders")
        otherElements["siteRating"].tap()
    }

}
