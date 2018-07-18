//
//  PixelTests.swift
//  UnitTests
//
//  Created by Chris Brind on 11/07/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Core

class PixelTests: XCTestCase {
    
    let host = "improving.duckduckgo.com"
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenAppLaunchPixelIsFiredThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch)
                
        wait(for: [expectation], timeout: 1.0)
    }
    
}
