//
//  AtbIntegrationTests.swift
//  AtbIntegrationTests
//
//  Created by Chris Brind on 30/07/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import XCTest
import Swifter

class AtbIntegrationTests: XCTestCase {

    struct Constants {
        static let initialAtb = "v100-1"
        static let retentionAtb = "v102-7"
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
        
        Springboard.deleteMyApp()
        
        app.launchEnvironment = [
            "BASE_URL": "http://localhost:8080",
            "BASE_PIXEL_URL": "http://localhost:8080"
        ]
        
        addRequestHandlers()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    fileprivate func skipOnboarding() {
        let continueButton = app.buttons["Continue"]
        continueButton.tap()
        continueButton.tap()
    }
    
    /**
 
     /exti/?atb=v001-1sd
     /atb.js
     /atb.js?atb=v001-1sd&set_atb=v001-1
     /atb.js?atb=v001-1sd&set_atb=v001-1
     /atb.js?atb=v001-1sd&set_atb=v001-1
     /atb.js?atb=v001-1sd&set_atb=v002-7
     /?q=oranges&t=ddg_ios&atb=v001-1sd
     /?q=lemons&t=ddg_ios&atb=v001-1sd
     /?q=pears&t=ddg_ios&atb=v001-1sd
     
    */
    func test() throws {
        try server.start()
        
        app.launch()
        
        skipOnboarding()
        
        search(forText: "oranges")
        
        updateATBForRetention()
        
        search(forText: "lemons")
        
        search(forText: "pears")

        // for debug purposes
        for request in extiRequests + atbRequests + searchRequests {
            print(request.path)
        }
        
        assertExti(requests: extiRequests)
        assertAtb(requests: atbRequests)
        assertSearch(requests: searchRequests)
    }
    
    func assertExti(requests: [HttpRequest], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(1, requests.count, file: file, line: line)
        
        let atbParam = requests.first?.queryParams[0].1
        XCTAssertTrue(atbParam?.hasPrefix(Constants.initialAtb) ?? false, file: file, line: line)
    }
    
    func assertAtb(request: HttpRequest, expectedAtb: String, expectedSetAtb: String, file: StaticString = #file, line: UInt = #line) {
        
        XCTAssertEqual(2, request.queryParams.count, file: file, line: line)
        XCTAssertTrue(request.queryParam("atb")?.hasPrefix(expectedAtb) ?? false,
                      "first.atb does not start with \(expectedSetAtb)", file: file, line: line)
        XCTAssertEqual(expectedSetAtb, request.queryParam("set_atb"), file: file, line: line)
        
    }
    
    func assertAtb(requests: [HttpRequest], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(5, requests.count, file: file, line: line)
        XCTAssertEqual(0, requests.first?.queryParams.count, file: file, line: line)
        assertAtb(request: requests[1], expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.initialAtb, file: file, line: line)
        assertAtb(request: requests.last!, expectedAtb: Constants.initialAtb, expectedSetAtb: Constants.retentionAtb, file: file, line: line)
    }
    
    func assertSearch(requests: [HttpRequest], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(3, requests.count, file: file, line: line)
        
        var index = 0
        for request in requests {
            XCTAssertTrue(request.queryParam("atb")?.hasPrefix(Constants.initialAtb) ?? false,
                          "request[\(index)].atb does not start with \(Constants.initialAtb)", file: file, line: line)
            index += 1
        }
        
    }
    
    private func updateATBForRetention() {
        atbToSet = Constants.retentionAtb
    }
    
    private func search(forText text: String) {
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
    
}

fileprivate extension HttpRequest {
    
    func queryParam(_ named: String) -> String? {
        return queryParams.first(where: { $0.0 == named })?.1
    }
    
}

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

