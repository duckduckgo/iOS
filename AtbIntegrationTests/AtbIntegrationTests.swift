//
//  AtbIntegrationTests.swift
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
import Swifter

class AtbIntegrationTests: XCTestCase {

    struct Constants {
        static let initialAtb = "v100-1"
        static let searchRetentionAtb = "v102-7"
        static let appRetentionAtb = "v102-6"
        static let devmode = "test"
        static let atbParam = "atb"
        static let setAtbParam = "set_atb"
        static let activityType = "at"
    }
    
    let app = XCUIApplication()
    let server = HttpServer()
    var searchRequests = [HttpRequest]()
    var extiRequests = [HttpRequest]()
    var installAtbRequests = [HttpRequest]()
    var appRetentionAtbRequests = [HttpRequest]()
    var searchRetentionAtbRequests = [HttpRequest]()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app.launchEnvironment = [
            "BASE_URL": "http://localhost:8080",
            "BASE_PIXEL_URL": "http://localhost:8080"
        ]
        
        addRequestHandlers()
        
        do {
            try server.start()
        } catch {
            fatalError("Could not start server")
        }
        
        Springboard.deleteMyApp()
        app.launch()
        skipOnboarding()
        dismissAddToDockDialog()
    }
    
    override func tearDown() {
        super.tearDown()
        server.stop()
        
        searchRequests.removeAll()
        extiRequests.removeAll()
        installAtbRequests.removeAll()
        searchRetentionAtbRequests.removeAll()
        appRetentionAtbRequests.removeAll()
    }
    
    func testWhenAppIsInstalledThenExitIsCalledAndInitialAtbIsRetrieved() throws {
        assertInstallAtbCalledOnce()
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest() throws {
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertSearchRetentionAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertInstallAtbCalledOnce()
        assertExtiCalledOnce()
    }

    func testWhenUserSearchesWithOldAtbThenAtbIsUpdated() {
        search(forText: "lemons")
        assertSearch(text: "lemons", atb: Constants.initialAtb, numberOfRequests: 1)
        assertSearchRetentionAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, numberOfRequests: 1)

        search(forText: "pears")
        assertSearch(text: "pears", atb: Constants.initialAtb, numberOfRequests: 2)
        assertSearchRetentionAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.searchRetentionAtb, numberOfRequests: 2)
        
        assertInstallAtbCalledOnce()
        assertExtiCalledOnce()
    }
    
    func testWhenUserEntersSearchDirectlyThenAtbIsAddedToRequest() {
        search(forText: "http://localhost:8080?q=beagles")
        assertSearch(text: "beagles", atb: Constants.initialAtb)
        assertSearchRetentionAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        assertInstallAtbCalledOnce()
        assertExtiCalledOnce()
    }
    
    func testWhenAppLaunchedAgainThenAppAtbIsUpdated() {
        assertAppRetentionAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, numberOfRequests: 1)
        app.launch()
        assertAppRetentionAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.appRetentionAtb, numberOfRequests: 2)
        assertInstallAtbCalledOnce()
        assertExtiCalledOnce()
    }
    
    func assertInstallAtbCalledOnce() {
        XCTAssertEqual(1, installAtbRequests.count)
        guard let request = installAtbRequests.last else { fatalError() }
        XCTAssertEqual(1, request.queryParams.count)
        XCTAssertEqual("1", request.queryParam(Constants.devmode))
    }
    
    func assertSearch(text: String, atb: String, numberOfRequests: Int = 1) {
        XCTAssertEqual(numberOfRequests, searchRequests.count)
        guard let request = searchRequests.last  else { fatalError() }
        XCTAssertEqual(text, request.queryParam("q"))
        XCTAssertTrue(request.queryParam(Constants.atbParam)?.hasPrefix(atb) ?? false)
    }
    
    func assertExtiCalledOnce() {
        XCTAssertEqual(1, extiRequests.count)
        let atbParam = extiRequests.first?.queryParam(Constants.atbParam)
        XCTAssertTrue(atbParam?.hasPrefix(Constants.initialAtb) ?? false)
    }
    
    func assertSearchRetentionAtb(expectedAtb: String, expectedSetAtb: String, numberOfRequests: Int = 1) {
        XCTAssertEqual(numberOfRequests, searchRetentionAtbRequests.count)
        guard let request = searchRetentionAtbRequests.last else { fatalError() }
        XCTAssertTrue(request.queryParam("atb")?.hasPrefix(expectedAtb) ?? false,
                      "first.atb does not start with \(expectedSetAtb)")
        XCTAssertEqual(expectedSetAtb, request.queryParam(Constants.setAtbParam))
        XCTAssertNil(request.queryParam(Constants.activityType))
        XCTAssertEqual("1", request.queryParam(Constants.devmode))
    }

    func assertAppRetentionAtb(expectedAtb: String, expectedSetAtb: String, numberOfRequests: Int = 1) {
        XCTAssertEqual(numberOfRequests, appRetentionAtbRequests.count)
        guard let request = appRetentionAtbRequests.last else { fatalError() }
        XCTAssertTrue(request.queryParam("atb")?.hasPrefix(expectedAtb) ?? false,
                      "first.atb does not start with \(expectedSetAtb)")
        XCTAssertEqual(expectedSetAtb, request.queryParam(Constants.setAtbParam))
        XCTAssertEqual("au", request.queryParam(Constants.activityType))
        XCTAssertEqual("1", request.queryParam(Constants.devmode))
    }
    
    private func dismissAddToDockDialog() {
        let noThanksButton = app.buttons["No Thanks"]
        guard noThanksButton.waitForExistence(timeout: 2) else {
            fatalError("No 'add to dock' view present")
        }
        noThanksButton.tap()
    }
    
    private func search(forText text: String) {
        let searchentrySearchField = app.searchFields["searchEntry"]
        
        if !searchentrySearchField.waitForExistence(timeout: 2) {
            // Centered home screen variant
            app.collectionViews.otherElements["activateSearch"].tap()
            
            if !searchentrySearchField.waitForExistence(timeout: 2) {
                fatalError("Search field could not be activated")
            }
        } else {
            searchentrySearchField.tap()
        }
        
        let keyboard = app.keyboards.element
        if keyboard.waitForExistence(timeout: 2) {
            searchentrySearchField.typeText("\(text)\r")
            Snapshot.waitForLoadingIndicatorToDisappear(within: 5.0)
        } else {
            XCTFail("No keyboard present after tapping search field")
        }
    }

    private func addRequestHandlers() {
        
        server["/"] = {
            self.searchRequests.append($0)
            return .accepted
        }
        
        server["/exti/"] = {
            self.extiRequests.append($0)
            return .accepted
        }
        
        server["/atb.js"] = {
            var atb = ""
            if $0.queryParam(Constants.activityType)  != nil {
                atb = Constants.appRetentionAtb
                self.appRetentionAtbRequests.append($0)
            } else if $0.queryParam(Constants.atbParam)  != nil {
                atb = Constants.searchRetentionAtb
                self.searchRetentionAtbRequests.append($0)
            } else {
                atb = Constants.initialAtb
                self.installAtbRequests.append($0)
            }
            return .ok(.json([
                "version": atb
                ] as AnyObject))
        }
    }
    
    private func skipOnboarding() {
        let continueButton = app.buttons["Continue"]
        guard continueButton.waitForExistence(timeout: 2) else {
            fatalError("Cound not skip onboarding")
        }
        
        continueButton.tap()
        continueButton.tap()
    }
    
}

fileprivate extension HttpRequest {
    
    func queryParam(_ named: String) -> String? {
        return queryParams.first(where: { $0.0 == named })?.1
    }
    
}

// from: https://stackoverflow.com/a/36168101/73479
class Springboard {
    
    static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    
    /**
     Terminate and delete the app via springboard
     */
    class func deleteMyApp() {
        XCUIApplication().terminate()
        
        // Resolve the query for the springboard rather than launching it
        springboard.activate()
        
        // Force delete the app from the springboard
        let icon = springboard.icons["DuckDuckGo"]
        if icon.exists {
            let iconFrame = icon.frame
            let springboardFrame = springboard.frame
            icon.press(forDuration: 1.3)
            
            // Tap the little "X" button at approximately where it is. The X is not exposed directly

            springboard.coordinate(withNormalizedOffset: CGVector(dx: (iconFrame.minX + 3) / springboardFrame.maxX,
                                                                  dy: (iconFrame.minY + 3) / springboardFrame.maxY)).tap()
            
            let deleteButton = springboard.alerts.buttons["Delete"]
            _ = deleteButton.waitForExistence(timeout: 5.0)
            deleteButton.tap()
        }
    }
}
