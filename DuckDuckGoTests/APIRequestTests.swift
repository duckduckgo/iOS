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
import OHHTTPStubsSwift
@testable import Core

class APIRequestTests: XCTestCase {

    let host = AppUrls().surrogates.host!
    let url = AppUrls().surrogates
    
    override func setUp() {
        swizzlePreferredLanguagesMethod()
    }

    override func tearDown() {
        swizzlePreferredLanguagesMethod()
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenRequestMadeThenCorrectHeadersAreAdded() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }

        let expect = expectation(description: "testWhenRequestMadeThenCorrectHeadersAreAdded")
        let dataTask = APIRequest.request(url: url) { (_, _) in
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
        
        let headerFields = dataTask.currentRequest!.allHTTPHeaderFields!
        let userAgent = headerFields[APIHeaders.Name.userAgent]!
        XCTAssertTrue(userAgent.hasPrefix("ddg_ios"))

        let acceptEncoding = headerFields[APIHeaders.Name.acceptEncoding]!
        XCTAssertEqual(acceptEncoding, "gzip;q=1.0, compress;q=0.5")

        let acceptLanguage = headerFields[APIHeaders.Name.acceptLanguage]!
        XCTAssertEqual(acceptLanguage, "en-GB;q=1.0, fr-FR;q=0.9, fr-CA;q=0.8, en-US;q=0.7, de-AT;q=0.6, de-CH;q=0.5")
    }

    func testWhenRequestWithUserAgentMadeThenUserAgentIsUpdated() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ APIHeaders.Name.userAgent: "old ua"])
        }

        let expect = expectation(description: "testWhenRequestWithUserAgentMadeThenUserAgentIsUpdated")
        let dataTask = APIRequest.request(url: url) { (_, _) in
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
        let userAgent = dataTask.currentRequest!.allHTTPHeaderFields![APIHeaders.Name.userAgent]!
        XCTAssertTrue(userAgent.hasPrefix("ddg_ios"))
    }

    func testWhenStatus200WithEtagThenRequestCompletesWithEtag() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ "ETag": "an etag"] )
        }

        let expect = expectation(description: "testWhenStatus200WithEtagThenRequestCompletesWithEtag")
        APIRequest.request(url: url) { (data, error) in
            XCTAssertNotNil(data?.etag)
            XCTAssertNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenStatus200ThenRequestCompletesWithData() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }

        let expect = expectation(description: "testWhenStatus200ThenRequestCompletesWithData")
        APIRequest.request(url: url) { (data, error) in
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
        APIRequest.request(url: url) { (_, error) in
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
        APIRequest.request(url: url) { (_, error) in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenMultipleRequestsAreFiredThenCallbacksAreProcessedOnSerialQueue() {

        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil)
        }

        let expectFirst = expectation(description: "first request has been processed")
        let expectLast = expectation(description: "second request has been processed")

        APIRequest.request(url: url) { (_, error) in
            // Give second request a chance to execute the callback
            Thread.sleep(forTimeInterval: 0.4)
            XCTAssertNil(error)
            expectFirst.fulfill()
        }

        Thread.sleep(forTimeInterval: 0.1)

        APIRequest.request(url: url) { (_, error) in
            XCTAssertNil(error)
            expectLast.fulfill()
        }

        wait(for: [expectFirst, expectLast], timeout: 1.0, enforceOrder: true)
    }

    func validJson() -> String {
        return OHPathForFile("MockFiles/disconnect.json", type(of: self))!
    }
    
    static func mockedPreferredLangauges() -> [String] {
        return ["en-GB", "fr-FR", "fr-CA", "en-US", "de-AT", "de-CH", "zh_HK"]
    }

    func swizzlePreferredLanguagesMethod() {
        let original = class_getClassMethod(NSLocale.classForCoder(), #selector(getter: NSLocale.preferredLanguages))
        let mocked = class_getClassMethod(APIRequestTests.classForCoder(), #selector(APIRequestTests.mockedPreferredLangauges))
        method_exchangeImplementations(original!, mocked!)
    }
}
