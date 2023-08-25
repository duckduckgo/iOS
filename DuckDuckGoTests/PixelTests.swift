//
//  PixelTests.swift
//  UnitTests
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import OHHTTPStubs
import OHHTTPStubsSwift
import Networking
@testable import Core

class PixelTests: XCTestCase {
    
    let host = "improving.duckduckgo.com"
    let testAgent = "Test Agent"
    let userAgentName = "User-Agent"
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenTimedPixelFiredThenCorrectDurationIsSet() {
        let expectation = XCTestExpectation()
        
        let date = Date(timeIntervalSince1970: 0)
        let now = Date(timeIntervalSince1970: 1)
        
        stub(condition: { request -> Bool in
            if let url = request.url {
                XCTAssertEqual("1.0", url.getParameter(named: "dur"))
                return true
            }
            
            XCTFail("Did not found param dur")
            return true
        }, response: { _ -> HTTPStubsResponse in
            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })
        
        let pixel = TimedPixel(.appLaunch, date: date)
        pixel.fire(now)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWhenPixelFiredThenAPIHeadersAreAdded() {
        let expectation = XCTestExpectation()
        
        stub(condition: hasHeaderNamed(userAgentName, value: testAgent)) { _ -> HTTPStubsResponse in
            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        let headers = APIRequest.Headers(userAgent: testAgent)
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone, withHeaders: headers)
        
        wait(for: [expectation], timeout: 1.0)

    }
    
    func testWhenPixelIsFiredWithAdditionalParametersThenParametersAdded() {
        let expectation = XCTestExpectation()
        let params = ["param1": "value1", "param2": "value2"]
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { request -> HTTPStubsResponse in
            XCTAssertEqual("value1", request.url?.getParameter(named: "param1"))
            XCTAssertEqual("value2", request.url?.getParameter(named: "param2"))
            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone, withAdditionalParameters: params)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWhenAppLaunchPixelIsFiredFromPhoneThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { _ -> HTTPStubsResponse in
            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone)
                
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenAppLaunchPixelIsFiredFromTabletThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_tablet")) { _ -> HTTPStubsResponse in
            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .pad)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenAppLaunchPixelIsFiredFromUnspecifiedThenCorrectURLRequestIsMadeAsPhone() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { _ -> HTTPStubsResponse in
            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .unspecified)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenPixelFiresSuccessfullyThenCompletesWithNoError() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host)) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWhenPixelFiresUnsuccessfullyThenCompletesWithError() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host)) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

}
