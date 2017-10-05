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
    fileprivate var mockETagStorage: MockAPIRequestETagStorage!

    override func setUp() {
        mockETagStorage = MockAPIRequestETagStorage()
        testee = APIRequest(url: AppUrls().disconnectMeBlockList, etagStorage: mockETagStorage)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhen304AndMatchingEtagThenRequestCompletesWithNoDataAndNoError() {
        let etag = UUID().uuidString
        mockETagStorage.etagToReturn = etag
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 304, headers: [ "ETag": etag ])
        }

        let expect = expectation(description: "testWhen304AndMatchingEtagThenRequestCompletesWithNoDataAndNoError")
        testee.execute { (data, error) in
            XCTAssertNil(data)
            XCTAssertNil(error)
            expect.fulfill()
            return .errorHandled
        }
        waitForExpectations(timeout: 1.0, handler: nil)

    }

    func testWhen200AndMatchingEtagThenRequestCompletesWithNoDataOrError() {
        let etag = UUID().uuidString
        mockETagStorage.etagToReturn = etag
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ "ETag": etag ])
        }

        let expect = expectation(description: "testWhen200AndMatchingEtagThenRequestCompletesWithNoDataOrError")
        testee.execute { (data, error) in
            XCTAssertNil(data)
            XCTAssertNil(error)
            expect.fulfill()
            return .errorHandled
        }
        waitForExpectations(timeout: 1.0, handler: nil)

    }

    func testWhen200AndNotMatchingEtagThenRequestCompletesWithDataAndNoError() {
        let etag = UUID().uuidString
        mockETagStorage.etagToReturn = etag
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ "ETag": "not the etag" ])
        }

        let expect = expectation(description: "testWhen200AndNotMatchingEtagThenRequestCompletesWithDataAndNoError")
        testee.execute { (data, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            expect.fulfill()
            return .errorHandled
        }
        waitForExpectations(timeout: 1.0, handler: nil)

    }


    func testWhenStatus200AndNoEtagThenRequestCompletesWithData() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }

        let expect = expectation(description: "testWhenStatus200AndNoEtagThenRequestCompletesWithData")
        testee.execute { (data, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            expect.fulfill()
            return .errorHandled
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
            return .errorHandled
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
            return .errorHandled
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func validJson() -> String {
        return OHPathForFile("MockJson/disconnect.json", type(of: self))!
    }
    
}

fileprivate class MockAPIRequestETagStorage: APIRequestETagStorage {

    var etagToReturn: String?
    var lastEtagSet: String?

    func set(etag: String?, for url: URL) {
        lastEtagSet = etag
    }

    func etag(for url: URL) -> String? {
        return etagToReturn
    }

}

