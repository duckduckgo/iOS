//
//  AtbIntegrationTests.swift
//  AtbIntegrationTests
//
//  Created by Chris Brind on 30/07/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import XCTest

class AtbIntegrationTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        let port = 8080
        
        app = XCUIApplication()
        app.launchEnvironment = ["BASE_DOMAIN_AND_PORT": "http://localhost:\(port)"]
        app.launch()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test() {
        
        
        
        
    }
    
}
