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
        static let defaultTimeout: Double = 30

        static let devmode = "test"
        static let atbParam = "atb"
        static let setAtbParam = "set_atb"
        static let activityType = "at"
    }

    let app = XCUIApplication()
    let server = HttpServer()
    var requests = 0

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app.launchEnvironment = [
            "BASE_URL": "http://localhost:8080",
            "BASE_PIXEL_URL": "http://localhost:8080",
            "ONBOARDING": "false",
            // usually just has to match an existing variant to prevent one being allocated
            "VARIANT": "sc"
        ]
        
        addRequestHandlers()
        
        do {
            try server.start()
        } catch {
            fatalError("Could not start server")
        }

        requests = 0
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        server.stop()
    }

    func testAppUsageCausesAtbRequests() {
        waitForRequests()
    }

    func testSearchCausesAtbRequests() {
        requests = 0 // Reset to ensure test launch of the app doesn't register as a false positive
        search(forText: "lemons")
        waitForRequests()
    }

    func testRelaunchCausesAtbRequests() {
        requests = 0 // Reset to ensure test launch of the app doesn't register as a false positive
        backgroundRelaunch()
        waitForRequests()
    }

    func backgroundRelaunch() {
        XCUIDevice.shared.press(.home)
        app.activate()
        if !app.searchFields["searchEntry"].waitForExistence(timeout: Constants.defaultTimeout) {
            fatalError("Can not find search field. Has the app launched?")
        }
    }

    private func search(forText text: String) {

        let searchentrySearchField = app.searchFields.element
        XCTAssertTrue(searchentrySearchField.waitForExistence(timeout: Constants.defaultTimeout))
        searchentrySearchField.tap()
        searchentrySearchField.typeText("\(text)\r")
        Snapshot.waitForLoadingIndicatorToDisappear(within: Constants.defaultTimeout)

    }

    /// We don't care which requests, as long as it's one of the expected endpoints.  The actual logic is tested in
    ///  the StatisticsLoader tests
    private func waitForRequests(timeout: TimeInterval = Constants.defaultTimeout) {
        let start = Date()
        while (start.timeIntervalSinceNow * -1) < timeout {
            _ = app.buttons["_wait_"].waitForExistence(timeout: 1)
            if requests > 0 {
                return
            }
        }

        XCTFail("No requests detected")
    }

    private func addRequestHandlers() {

        server["/exti/"] = { _ in
            self.requests += 1
            return .accepted
        }
        
        server["/atb.js"] = { _ in
            self.requests += 1
            return .accepted
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

private extension HttpRequest {

    func queryParam(_ named: String) -> String? {
        return queryParams.first(where: { $0.0 == named })?.1
    }

}
