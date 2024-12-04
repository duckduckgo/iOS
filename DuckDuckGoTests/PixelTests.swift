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

    override func setUpWithError() throws {
        try super.setUpWithError()

        Pixel.isDryRun = false
    }

    override func tearDown() {
        Pixel.isDryRun = true
        
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenTimedPixelFiredThenCorrectDurationIsSet() {
        let expectation = XCTestExpectation()
        
        let date = Date(timeIntervalSince1970: 0)
        let now = Date(timeIntervalSince1970: 1)

        stub(condition: isHost(host) && isPath("/t/ml_ios_phone")) { request -> HTTPStubsResponse in
            XCTAssertEqual("1.0", request.url?.getParameter(named: "dur"))

            expectation.fulfill()
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
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
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testPixelDebouncePreventsFiringWithinInterval() throws {
        throw XCTSkip("Flaky")
        let firstFireExpectation = XCTestExpectation(description: "First pixel fire should succeed")
        let thirdFireExpectation = XCTestExpectation(description: "Third pixel fire should succeed after debounce interval")

        stub(condition: isHost(self.host)) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let pixel = Pixel.Event.appLaunch
        let debounceInterval = 1 // Debounce interval of 5 seconds

        // Should be OK
        Pixel.fire(pixel: pixel, forDeviceType: .phone, onComplete: { error in
            XCTAssertNil(error)
            firstFireExpectation.fulfill()
        }, debounce: debounceInterval)

        // Should be debounced
        Pixel.fire(pixel: pixel, forDeviceType: .phone, onComplete: { _ in
        }, debounce: debounceInterval)

        // Should be OK
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(debounceInterval + 1)) {
            Pixel.fire(pixel: pixel, forDeviceType: .phone, onComplete: { error in
                XCTAssertNil(error)
                thirdFireExpectation.fulfill()
            }, debounce: debounceInterval)
        }

        wait(for: [firstFireExpectation, thirdFireExpectation], timeout: Double(debounceInterval + 4))
    }

    func testWhenDefiningUnderlyingErrorParametersThenNestedErrorsAreIncluded() {
        let underlyingError4 = NSError(domain: "underlyingError4", code: 5, userInfo: [:])
        let underlyingError3 = NSError(domain: "underlyingError3", code: 4, userInfo: [NSUnderlyingErrorKey: underlyingError4])
        let underlyingError2 = NSError(domain: "underlyingError2", code: 3, userInfo: [NSUnderlyingErrorKey: underlyingError3])
        let underlyingError1 = NSError(domain: "underlyingError1", code: 2, userInfo: [NSUnderlyingErrorKey: underlyingError2])
        let error = NSError(domain: "error", code: 1, userInfo: [NSUnderlyingErrorKey: underlyingError1])

        var parameters: [String: String] = [:]
        parameters.appendErrorPixelParams(error: error)

        XCTAssertEqual(parameters.count, 10)
        XCTAssertEqual(parameters["d"], error.domain)
        XCTAssertEqual(parameters["e"], String(error.code))
        XCTAssertEqual(parameters["ud"], underlyingError1.domain)
        XCTAssertEqual(parameters["ue"], String(underlyingError1.code))
        XCTAssertEqual(parameters["ud2"], underlyingError2.domain)
        XCTAssertEqual(parameters["ue2"], String(underlyingError2.code))
        XCTAssertEqual(parameters["ud3"], underlyingError3.domain)
        XCTAssertEqual(parameters["ue3"], String(underlyingError3.code))
        XCTAssertEqual(parameters["ud4"], underlyingError4.domain)
        XCTAssertEqual(parameters["ue4"], String(underlyingError4.code))
    }

    func testWhenDefiningUnderlyingErrorParametersAndThereIsNoUnderlyingErrorThenOnlyTopLevelParametersAreIncluded() {
        let error = NSError(domain: "error", code: 1, userInfo: [:])

        var parameters: [String: String] = [:]
        parameters.appendErrorPixelParams(error: error)

        XCTAssertEqual(parameters.count, 2)
        XCTAssertEqual(parameters["d"], error.domain)
        XCTAssertEqual(parameters["e"], String(error.code))
    }

}
