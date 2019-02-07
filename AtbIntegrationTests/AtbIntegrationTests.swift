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
        static let retentionAtb = "v102-7"
        static let devmode = "test"
        static let atbParam = "atb"
        static let setAtbParam = "set_atb"
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
        
        atbToSet = Constants.initialAtb
        
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

    }
    
    override func tearDown() {
        super.tearDown()
        server.stop()
        
        searchRequests.removeAll()
        extiRequests.removeAll()
        atbRequests.removeAll()

    }
    
    func testWhenAppIsInstalledThenInitialAtbIsRetrieved() throws {

        assertGetAtbCalled()
        assertExtiCalledOnce()

    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest1() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest2() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest3() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest4() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest5() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest6() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest7() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest8() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest9() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenSearchPerformedThenAtbIsAddedToRequest10() throws {
        
        search(forText: "oranges")
        assertSearch(text: "oranges", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        
        assertExtiCalledOnce()
    }
    
    func testWhenUserSearchesWithOldAtbThenAtbIsUpdated() {
        atbToSet = Constants.retentionAtb

        search(forText: "lemons")
        assertSearch(text: "lemons", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)
        searchRequests.removeAll()
        atbRequests.removeAll()

        search(forText: "pears")
        assertSearch(text: "pears", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.retentionAtb, expectedRequestCount: 1)
        
        assertExtiCalledOnce()
    }
    
    func testWhenUserEntersSearchDirectlyThenAtbIsAddedToRequest() {
        
        search(forText: "http://localhost:8080?q=beagles")
        assertSearch(text: "beagles", atb: Constants.initialAtb)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb)

        assertExtiCalledOnce()
    }
    
    func assertGetAtbCalled() {
        XCTAssertEqual(1, atbRequests.count)
        guard let request = atbRequests.first else { fatalError() }
        
        XCTAssertEqual(1, request.queryParams.count)
        XCTAssertEqual("1", request.queryParam(Constants.devmode))
    }
    
    func assertSearch(text: String, atb: String) {
        XCTAssertEqual(1, searchRequests.count)

        guard let request = searchRequests.last else {
            XCTFail("No search request")
            return
        }
        XCTAssertEqual(text, request.queryParam("q"))
        XCTAssertTrue(request.queryParam(Constants.atbParam)?.hasPrefix(atb) ?? false)
    }
    
    func assertExtiCalledOnce() {
        XCTAssertEqual(1, extiRequests.count)
        let atbParam = extiRequests.first?.queryParam(Constants.atbParam)
        XCTAssertTrue(atbParam?.hasPrefix(Constants.initialAtb) ?? false)
    }
    
    // by default expects 2 atb requests, the initial get atb and the one being asserted
    func assertAtb(expectedAtb: String, expectedSetAtb: String, expectedRequestCount: Int = 2) {
        XCTAssertEqual(expectedRequestCount, atbRequests.count)
        guard let request = atbRequests.last else {
            XCTFail("No atb request")
            return
        }
        
        XCTAssertEqual(3, request.queryParams.count)
        XCTAssertTrue(request.queryParam("atb")?.hasPrefix(expectedAtb) ?? false,
                      "first.atb does not start with \(expectedSetAtb)")
        XCTAssertEqual(expectedSetAtb, request.queryParam(Constants.setAtbParam))
        XCTAssertEqual("1", request.queryParam(Constants.devmode))

    }
    
    private func search(forText text: String) {
        if !app.searchFields["searchEntry"].exists {
            let noThanksButton = app.buttons["No Thanks"]
            _ = noThanksButton.waitForExistence(timeout: 2)
            noThanksButton.tap()
            app.collectionViews.otherElements["activateSearch"].tap()
        }
        
        let searchentrySearchField = app.searchFields["searchEntry"]
        searchentrySearchField.tap()
        searchentrySearchField.typeText("\(text)\r")
        Snapshot.waitForLoadingIndicatorToDisappear(within: 5.0)
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
