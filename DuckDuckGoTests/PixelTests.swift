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

    func testWhenAppLaunchPixelIsFiredFromPhoneThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, deviceType: .phone)
                
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenAppLaunchPixelIsFiredFromTabletThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_tablet")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, deviceType: .pad)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenAppLaunchPixelIsFiredFromUnspecifiedThenCorrectURLRequestIsMadeAsPhone() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, deviceType: .unspecified)
        
        wait(for: [expectation], timeout: 1.0)
    }

}
