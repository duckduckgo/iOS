//
//  DisconnectMeRequestTests.swift
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

class DisconnectMeRequestTests: XCTestCase {
    
    let host = AppUrls().contentBlocking.host!
    var testee: DisconnectMeRequest = DisconnectMeRequest()
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testWhenStatus200AndValidJsonThenRequestCompletestWithTrackersInSupportedCategories() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }
        
        let expect = expectation(description: "Valid json")
        testee.execute { (trackers, error) in
            XCTAssertNotNil(trackers)
            XCTAssertEqual(trackers?.count, 6)
            XCTAssertNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    
    func testWhenInvalidJsonThenRequestCompletestWithInvalidJsonError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.invalidJson(), status: 200, headers: nil)
        }
        
        let expect = expectation(description: "Invalid Json")
        testee.execute { (trackers, error) in
            XCTAssertNil(trackers)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.localizedDescription, JsonError.invalidJson.localizedDescription)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenUnexpectedJsonThenRequestCompletestWithTypeMismatchError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.mismatchedJson(), status: 200, headers: nil)
        }
        
        let expect = expectation(description: "Type mismatch")
        testee.execute { (trackers, error) in
            XCTAssertNil(trackers)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.localizedDescription, JsonError.typeMismatch.localizedDescription)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenStatusIsLessThan200ThenRequestCompletesWithError() {

        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 199, headers: nil)
        }
        
        let expect = expectation(description: "Status code 199")
        testee.execute { (trackers, error) in
            XCTAssertNil(trackers)
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenStatusCodeIs300ThenRequestCompletestWithError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 300, headers: nil)
        }
        
        let expect = expectation(description: "Status code 300")
        testee.execute { (trackers, error) in
            XCTAssertNil(trackers)
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenStatusCodeIsGreaterThan300ThenRequestCompletestWithError() {
        
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 301, headers: nil)
        }
        
        let expect = expectation(description: "Status code 301")
        testee.execute { (trackers, error) in
            XCTAssertNil(trackers)
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func validJson() -> String {
        return OHPathForFile("MockResponse/disconnect.json", type(of: self))!
    }
    
    func mismatchedJson() -> String {
        return OHPathForFile("MockResponse/disconnect_mismatched.json", type(of: self))!
    }
    
    func invalidJson() -> String {
        return OHPathForFile("MockResponse/invalid.json", type(of: self))!
    }
}
