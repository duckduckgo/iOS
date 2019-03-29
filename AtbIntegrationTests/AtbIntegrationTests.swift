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
    
    enum RequestType {
        case atb
        case exti
        case search
    }
    
    struct Request {
        let type: RequestType
        let httpRequest: HttpRequest
    }
    
    let app = XCUIApplication()
    let server = HttpServer()
    var requests = [Request]()
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
        requests.removeAll()
    }
    
    func testWhenAppIsInstalledThenExitIsCalledAndInitialAtbIsRetrieved() throws {
        assertRequestCount(count: 3)
        assertAtb(expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertExti()
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest() throws {
        search(forText: "oranges")

        assertRequestCount(count: 5)
        assertAtb(expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertExti()
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
        assertSearch(text: "oranges", atb: Constants.initialAtb)
    }

    func testWhenUserSearchesWithOldAtbThenAtbIsUpdated() {
        atbToSet = Constants.searchRetentionAtb
        search(forText: "lemons")
        search(forText: "pears")

        assertRequestCount(count: 7)
        assertAtb(expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertExti()
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
        assertSearch(text: "lemons", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.searchRetentionAtb, expectedType: nil)
        assertSearch(text: "pears", atb: Constants.initialAtb)
    }
    
    func testWhenUserEntersSearchDirectlyThenAtbIsAddedToRequest() {
        search(forText: "http://localhost:8080?q=beagles")
    
        assertRequestCount(count: 5)
        assertAtb(expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertExti()
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
        assertSearch(text: "beagles", atb: Constants.initialAtb)
    }
    
    func testWhenAppLaunchedAgainThenAppAtbIsUpdated() {
        atbToSet = Constants.appRetentionAtb
        app.launch() // this launch gets new atb
        app.launch() // this launch sends it

        assertRequestCount(count: 5)
        assertAtb(expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertExti()
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.appRetentionAtb, expectedType: "app_use")
    }
    
    func assertRequestCount(count: Int) {
        XCTAssertEqual(count, requests.count)
    }
    
    func assertExti() {
        let request = requests.removeFirst()
        XCTAssertEqual(RequestType.exti, request.type)
        XCTAssertEqual(Constants.initialAtb, request.httpRequest.queryParam(Constants.atbParam))
    }
    
    func assertAtb(expectedAtb: String? = nil, expectedSetAtb: String? = nil, expectedType: String? = nil) {
        let request = requests.removeFirst()
        XCTAssertEqual(RequestType.atb, request.type)
        
        let httpRequest = request.httpRequest
        XCTAssertEqual(expectedAtb, httpRequest.queryParam(Constants.atbParam))
        XCTAssertEqual(expectedSetAtb, httpRequest.queryParam(Constants.setAtbParam))
        XCTAssertEqual(expectedType, httpRequest.queryParam(Constants.activityType))
        XCTAssertEqual("1", httpRequest.queryParam(Constants.devmode))
    }
    
    func assertSearch(text: String, atb: String) {
        let request = requests.removeFirst()
        XCTAssertEqual(RequestType.search, request.type)

        let httpRequest = request.httpRequest
        XCTAssertEqual(text, httpRequest.queryParam("q"))
        XCTAssertEqual(atb, httpRequest.queryParam(Constants.atbParam))
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
            self.requests.append(Request(type: RequestType.search, httpRequest: $0))
            return .accepted
        }
        
        server["/exti/"] = {
            self.requests.append(Request(type: RequestType.exti, httpRequest: $0))
            return .accepted
        }
        
        server["/atb.js"] = {
            self.requests.append(Request(type: RequestType.atb, httpRequest: $0))
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
