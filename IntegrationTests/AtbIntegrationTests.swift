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
@testable import Core

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
    
    enum StatisticsRequestType {
        case atb
        case exti
    }
    
    struct StatisticsRequest {
        let type: StatisticsRequestType
        let httpRequest: HttpRequest
    }
    
    let app = XCUIApplication()
    let server = HttpServer()
    var statisticsRequests = [StatisticsRequest]()
    var searchRequests = [HttpRequest]()
    var atbToSet = Constants.initialAtb
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app.launchEnvironment = [
            "BASE_URL": "http://localhost:8080",
            "BASE_PIXEL_URL": "http://localhost:8080",
            "DAXDIALOGS": "false",
            "ONBOARDING": "false",
            // usually just has to match an existing variant to prevent one being allocated
            "VARIANT": "sa"
        ]
        
        addRequestHandlers()
        
        do {
            try server.start()
        } catch {
            fatalError("Could not start server")
        }
        
        Springboard.deleteMyApp()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        server.stop()
        statisticsRequests.removeAll()
        searchRequests.removeAll()
    }
    
    func test() throws {
        try assertWhenAppIsInstalledAndLaunchedThenExtiIsCalledAndInitialAtbIsRetrieved()
        clearRequests()
        
        assertWhenAppLaunchedAgainThenAppAtbIsUpdated()
        clearRequests()
        
        assertWhenUserSearchesWithOldAtbThenAtbIsUpdated()
        clearRequests()
        
        try assertWhenSearchPerformedThenAtbIsAddedToRequest()
        clearRequests()

        assertWhenUserEntersSearchDirectlyThenAtbIsAddedToRequest()
        clearRequests()
    }
    
    func assertWhenAppIsInstalledAndLaunchedThenExtiIsCalledAndInitialAtbIsRetrieved() throws {
        
        waitFor(searchRequestsCount: 0, statisticRequestsCount: 3, timeout: 30)
        
        assertSearchRequestCount(count: 0)
        assertStatisticsRequestCount(count: 3)
        assertAtb(expectedAtb: nil, expectedSetAtb: nil, expectedType: nil)
        assertExti()
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
    }
    
    func assertWhenSearchPerformedThenAtbIsAddedToRequest() throws {
        search(forText: "oranges")

        assertSearchRequestCount(count: 1)
        assertSearch(text: "oranges", atb: Constants.initialAtb)
    }

    func assertWhenUserSearchesWithOldAtbThenAtbIsUpdated() {
        atbToSet = Constants.searchRetentionAtb

        search(forText: "lemons")
        search(forText: "pears")

        waitFor(searchRequestsCount: 2, statisticRequestsCount: 0, timeout: 30)
        assertSearchRequestCount(count: 2)
        assertSearch(text: "lemons", atb: Constants.initialAtb)
        assertSearch(text: "pears", atb: Constants.initialAtb)
        
        waitFor(searchRequestsCount: 0, statisticRequestsCount: 2, timeout: 30)
        assertStatisticsRequestCount(count: 2)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: nil)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.searchRetentionAtb, expectedType: nil)
    }
    
    func assertWhenUserEntersSearchDirectlyThenAtbIsAddedToRequest() {
        search(forText: "http://localhost:8080?q=beagles")
        
        assertSearchRequestCount(count: 1)
        assertSearch(text: "beagles", atb: Constants.initialAtb)
    }
    
    func assertWhenAppLaunchedAgainThenAppAtbIsUpdated() {
        atbToSet = Constants.appRetentionAtb
        
        backgroundRelaunch() // this launch gets new atb
        backgroundRelaunch() // this launch sends it

        waitFor(searchRequestsCount: 0, statisticRequestsCount: 2, timeout: 30)
        assertSearchRequestCount(count: 0)
        assertStatisticsRequestCount(count: 2)
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, expectedType: "app_use")
        assertAtb(expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.appRetentionAtb, expectedType: "app_use")
    }
    
    func clearRequests() {
        statisticsRequests.removeAll()
        searchRequests.removeAll()
    }
    
    func backgroundRelaunch() {
        XCUIDevice.shared.press(.home)
        app.activate()
        if !app.searchFields["searchEntry"].waitForExistence(timeout: Constants.defaultTimeout) {
            fatalError("Can not find search field. Has the app launched?")
        }
    }
    
    func assertStatisticsRequestCount(count: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(count, statisticsRequests.count, file: file, line: line)
    }
    
    func assertExti(file: StaticString = #file, line: UInt = #line) {
        let request = statisticsRequests.removeFirst()
        XCTAssertEqual(StatisticsRequestType.exti, request.type, file: file, line: line)
        XCTAssertEqual(Constants.initialAtb, request.httpRequest.queryParam(Constants.atbParam), file: file, line: line)
    }
    
    func assertAtb(expectedAtb: String? = nil, expectedSetAtb: String? = nil, expectedType: String? = nil,
                   file: StaticString = #file, line: UInt = #line) {
        let request = statisticsRequests.removeFirst()
        XCTAssertEqual(StatisticsRequestType.atb, request.type, file: file, line: line)
        
        let httpRequest = request.httpRequest
        XCTAssertEqual(expectedAtb, httpRequest.queryParam(Constants.atbParam), file: file, line: line)
        XCTAssertEqual(expectedSetAtb, httpRequest.queryParam(Constants.setAtbParam), file: file, line: line)
        XCTAssertEqual(expectedType, httpRequest.queryParam(Constants.activityType), file: file, line: line)
        XCTAssertEqual("1", httpRequest.queryParam(Constants.devmode), file: file, line: line)
    }
    
    func assertSearchRequestCount(count: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(count, searchRequests.count, file: file, line: line)
    }
    
    func assertSearch(text: String, atb: String, file: StaticString = #file, line: UInt = #line) {
        let request = searchRequests.removeFirst()

        XCTAssertEqual(text, request.queryParam("q"), file: file, line: line)
        XCTAssertEqual(atb, request.queryParam(Constants.atbParam), file: file, line: line)
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
            // Check software keyboard is enabled
            searchentrySearchField.typeText("\(text)\r")
            Snapshot.waitForLoadingIndicatorToDisappear(within: Constants.defaultTimeout)
        } else {
            XCTFail("No keyboard present after tapping search field")
        }
    }
    
    private func waitFor(searchRequestsCount: Int, statisticRequestsCount: Int, timeout: TimeInterval) {
        let start = Date()
        
        while (start.timeIntervalSinceNow * -1) < timeout {
            _ = app.buttons["_wait_"].waitForExistence(timeout: 1)
            if searchRequests.count >= searchRequestsCount && statisticsRequests.count >= statisticRequestsCount {
                return
            }
        }
        
        if searchRequests.count != searchRequests.count || statisticRequestsCount != statisticsRequests.count {
            XCTFail("\(searchRequests.count) vs \(searchRequestsCount), \(statisticRequestsCount) vs \(statisticsRequests.count)")
        }
    }

    private func addRequestHandlers() {
        
        server["/"] = {
            self.searchRequests.append($0)
            return .accepted
        }
        
        server["/exti/"] = {
            self.statisticsRequests.append(StatisticsRequest(type: StatisticsRequestType.exti, httpRequest: $0))
            return .accepted
        }
        
        server["/atb.js"] = {
            self.statisticsRequests.append(StatisticsRequest(type: StatisticsRequestType.atb, httpRequest: $0))
            return .ok(.json([
                "version": self.atbToSet
            ] as AnyObject))
        }
    }
    
    private func waitForButtonThenTap(_ named: String) {
        let button = app.buttons[named]
        guard button.waitForExistence(timeout: Constants.defaultTimeout) else {
            fatalError("Could not find button named \(named)")
        }
        button.tap()
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
            
            let rearrangeButton = springboard.buttons["Rearrange Apps"]
            if rearrangeButton.waitForExistence(timeout: 2) {
                rearrangeButton.tap()
                
                sleep(1)
                // Tap the little "X" button at approximately where it is. The X is not exposed directly

                springboard.coordinate(withNormalizedOffset: CGVector(dx: (iconFrame.minX + 3) / springboardFrame.maxX,
                                                                      dy: (iconFrame.minY + 3) / springboardFrame.maxY)).tap()
            } else {
                // Buttons have been rearranged for iOS 13.1+ version
                let deleteButton = springboard.buttons["Delete App"]
                deleteButton.tap()
            }
            
            let deleteButton = springboard.alerts.buttons["Delete"]
            _ = deleteButton.waitForExistence(timeout: AtbIntegrationTests.Constants.defaultTimeout)
            deleteButton.tap()
        }
    }
}
