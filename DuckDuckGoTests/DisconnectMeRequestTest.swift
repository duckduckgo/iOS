//
//  DisconnectMeRequestTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 05/08/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//


import XCTest
import OHHTTPStubs
@testable import Core

class DisconnectMeRequestTests: XCTestCase {
    
    var testee: DisconnectMeRequest!
    
    override func setUp() {
        testee = DisconnectMeRequest()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testWhenStatus200AndValidJsonThenRequestCompletestWithTrackersInSupportedCategories() {
        
        stub(condition: isHost(AppUrls.contentBlocking.host!)) { _ in
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
        
        stub(condition: isHost(AppUrls.contentBlocking.host!)) { _ in
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
        
        stub(condition: isHost(AppUrls.contentBlocking.host!)) { _ in
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

        stub(condition: isHost(AppUrls.contentBlocking.host!)) { _ in
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
        
        stub(condition: isHost(AppUrls.contentBlocking.host!)) { _ in
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
        
        stub(condition: isHost(AppUrls.contentBlocking.host!)) { _ in
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
        return OHPathForFile("MockResponse/disconnect_valid.json", type(of: self))!
    }
    
    func mismatchedJson() -> String {
        return OHPathForFile("MockResponse/disconnect_mismatched.json", type(of: self))!
    }
    
    func invalidJson() -> String {
        return OHPathForFile("MockResponse/invalid.json", type(of: self))!
    }
}
