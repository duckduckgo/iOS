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
        // 5 should be good enough. 10 for some padding
        static let defaultTimeout: Double = 10

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
    var atbRequests = [HttpRequest]()
    var atbToSet = Constants.initialAtb
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app.launchEnvironment = [
            "BASE_URL": "http://localhost:8080",
            "BASE_PIXEL_URL": "http://localhost:8080",
            "VARIANT": "sc"
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
        atbRequests.removeAll()
    }
    
    func testWhenAppIsInstalledThenExitIsCalledAndInitialAtbIsRetrieved() throws {
        assertAtbCount(requests: 2)
        assertAtb(requestIndex: 0, expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertAtb(requestIndex: 1, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)

        assertExtiCalledOnce()
        assertAtbCount(requests: 3)
        assertAtb(requestIndex: 0, expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertAtb(requestIndex: 1, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(requestIndex: 2, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
    }

    func testWhenUserSearchesWithOldAtbThenAtbIsUpdated() {
        atbToSet = Constants.searchRetentionAtb
        
        search(forText: "lemons")
        assertSearch(text: "lemons", atb: Constants.initialAtb, numberOfRequests: 1)

        search(forText: "pears")
        assertSearch(text: "pears", atb: Constants.initialAtb, numberOfRequests: 2)

        assertExtiCalledOnce()
        assertAtbCount(requests: 4)
        assertAtb(requestIndex: 0, expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertAtb(requestIndex: 1, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(requestIndex: 2, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
        assertAtb(requestIndex: 3, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.searchRetentionAtb, expectedType: nil)
    }
    
    func testWhenUserEntersSearchDirectlyThenAtbIsAddedToRequest() {
        search(forText: "http://localhost:8080?q=beagles")
        assertSearch(text: "beagles", atb: Constants.initialAtb)
    
        assertExtiCalledOnce()
        assertAtbCount(requests: 3)
        assertAtb(requestIndex: 0, expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertAtb(requestIndex: 1, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(requestIndex: 2, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
    }
    
    func testWhenAppLaunchedAgainThenAppAtbIsUpdated() {
        atbToSet = Constants.appRetentionAtb
        app.launch() // this launch gets new atb
        app.launch() // this launch sends it

        assertExtiCalledOnce()
        assertAtbCount(requests: 4)
        assertAtb(requestIndex: 0, expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertAtb(requestIndex: 1, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(requestIndex: 2, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(requestIndex: 3, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.appRetentionAtb, expectedType: "app_use")
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
    
    func assertAtbCount(requests: Int) {
        XCTAssertEqual(requests, atbRequests.count)
    }
    
    func assertAtb(requestIndex: Int = 0, expectedAtb: String? = nil, expectedSetAtb: String? = nil, expectedType: String? = nil) {
        let request = atbRequests[requestIndex]
        XCTAssertEqual(expectedAtb, request.queryParam(Constants.atbParam))
        XCTAssertEqual(expectedSetAtb, request.queryParam(Constants.setAtbParam))
        XCTAssertEqual(expectedType, request.queryParam(Constants.activityType))
        XCTAssertEqual("1", request.queryParam(Constants.devmode))
    }
    
    private func dismissAddToDockDialog() {
        let noThanksButton = app.buttons["No Thanks"]
        guard noThanksButton.waitForExistence(timeout: Constants.defaultTimeout) else {
            fatalError("No 'add to dock' view present")
        }
        noThanksButton.tap()
    }
    
    private func search(forText text: String) {
        let searchentrySearchField = app.searchFields["searchEntry"]
        
        if !searchentrySearchField.waitForExistence(timeout: Constants.defaultTimeout) {
            // Centered home screen variant
            app.collectionViews.otherElements["activateSearch"].tap()
            
            if !searchentrySearchField.waitForExistence(timeout: Constants.defaultTimeout) {
                fatalError("Search field could not be activated")
            }
        } else {
            searchentrySearchField.tap()
        }
        
        let keyboard = app.keyboards.element
        if keyboard.waitForExistence(timeout: Constants.defaultTimeout) {
            searchentrySearchField.typeText("\(text)\r")
            Snapshot.waitForLoadingIndicatorToDisappear(within: Constants.defaultTimeout)
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
            self.atbRequests.append($0)
            return .ok(.json([
                "version": self.atbToSet
            ] as AnyObject))
        }
    }
    
    private func skipOnboarding() {
        let continueButton = app.buttons["Continue"]
        guard continueButton.waitForExistence(timeout: Constants.defaultTimeout) else {
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
            _ = deleteButton.waitForExistence(timeout: AtbIntegrationTests.Constants.defaultTimeout)
            deleteButton.tap()
        }
    }
}
