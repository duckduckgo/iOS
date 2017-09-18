//
//  CohortRequestTests.swift
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

class CohortRequestTests: XCTestCase {
    
    let host = AppUrls().cohort.host!
    var testee = CohortRequest()
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testWhenStatus200AndValidJsonThenRequestCompletestWithCohortWithPlatformSuffix() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }
        
        let expectation = XCTestExpectation(description: "Valid json")
        testee.execute { (result, error) in
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.version, "v77-5mi")
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    
    func testWhenInvalidJsonThenRequestCompletestWithInvalidJsonError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.invalidJson(), status: 200, headers: nil)
        }
        
        let expectation = XCTestExpectation(description: "Invalid Json")
        testee.execute { (result, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.localizedDescription, JsonError.invalidJson.localizedDescription)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWhenUnexpectationedJsonThenRequestCompletestWithTypeMismatchError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.mismatchedJson(), status: 200, headers: nil)
        }
        
        let expectation = XCTestExpectation(description: "Type mismatch")
        testee.execute { (result, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.localizedDescription, JsonError.typeMismatch.localizedDescription)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWhenStatusIsLessThan200ThenRequestCompletesWithError() {

        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 199, headers: nil)
        }
        
        let expectation = XCTestExpectation(description: "Status code 199")
        testee.execute { (result, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWhenStatusCodeIs300ThenRequestCompletestWithError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 300, headers: nil)
        }
        
        let expectation = XCTestExpectation(description: "Status code 300")
        testee.execute { (result, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testWhenStatusCodeIsGreaterThan300ThenRequestCompletestWithError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 301, headers: nil)
        }
        
        let expectation = XCTestExpectation(description: "Status code 301")
        testee.execute { (result, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func validJson() -> String {
        return OHPathForFile("MockJson/cohort_atb.json", type(of: self))!
    }
    
    func mismatchedJson() -> String {
        return OHPathForFile("MockJson/unexpected.json", type(of: self))!
    }
    
    func invalidJson() -> String {
        return OHPathForFile("MockJson/invalid.json", type(of: self))!
    }
}
