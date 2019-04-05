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
import Core
import Alamofire

class PixelTests: XCTestCase {
    
    let host = "improving.duckduckgo.com"
    let testAgent = "Test Agent"
    let userAgentName = "User-Agent"
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenPixelFiredThenAPIHeadersAreAdded() {
        let expectation = XCTestExpectation()
        
        stub(condition: hasHeaderNamed(userAgentName, value: testAgent)) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers[userAgentName] = testAgent
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone, withHeaders: headers)
        
        wait(for: [expectation], timeout: 1.0)

    }
    
    func testWhenPixelIsFiredWithAdditionalParametersThenParametersAdded() {
        let expectation = XCTestExpectation()
        let params = ["param1": "value1", "param2": "value2"]
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { request -> OHHTTPStubsResponse in
            XCTAssertEqual("value1", request.url?.getParam(name: "param1"))
            XCTAssertEqual("value2", request.url?.getParam(name: "param2"))
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone, withAdditionalParameters: params)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWhenAppLaunchPixelIsFiredFromPhoneThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone)
                
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenAppLaunchPixelIsFiredFromTabletThenCorrectURLRequestIsMade() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_tablet")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .pad)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenAppLaunchPixelIsFiredFromUnspecifiedThenCorrectURLRequestIsMadeAsPhone() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { _ -> OHHTTPStubsResponse in
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .unspecified)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenPixelFiresSuccessfullyThenCompletesWithNoError() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host)) { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWhenPixelFiresUnsuccessfullyThenCompletesWithError() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host)) { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }
        
        Pixel.fire(pixel: .appLaunch, forDeviceType: .phone) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

}
