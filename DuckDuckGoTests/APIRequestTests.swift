//
//  APIRequestTests.swift
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
import OHHTTPStubs
@testable import Core

class APIRequestTests: XCTestCase {
    
    let host = AppUrls().disconnectMeBlockList.host!
    var testee: APIRequest!

    override func setUp() {
        testee = APIRequest(url: AppUrls().disconnectMeBlockList)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenStatus200ThenRequestCompletesWithData() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }

        let expect = expectation(description: "testWhenStatus200ThenRequestCompletesWithData")
        testee.execute { (data, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)

    }

    func testWhenStatusCodeIs300ThenRequestCompletestWithError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 300, headers: nil)
        }
        
        let expect = expectation(description: "testWhenStatusCodeIs300ThenRequestCompletestWithError")
        testee.execute { (data, error) in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenStatusCodeIsGreaterThan300ThenRequestCompletestWithError() {

        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 301, headers: nil)
        }

        let expect = expectation(description: "testWhenStatusCodeIsGreaterThan300ThenRequestCompletestWithError")
        testee.execute { (data, error) in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func validJson() -> String {
        return OHPathForFile("MockResponse/disconnect.json", type(of: self))!
    }
    
}
