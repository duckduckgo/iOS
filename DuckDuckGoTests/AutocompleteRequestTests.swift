//
//  AutocompleteRequestTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation

import XCTest
@testable import DuckDuckGo
@testable import Core
import OHHTTPStubs
import OHHTTPStubsSwift

class AutocompleteRequestTests: XCTestCase {

    let request = (try? AutocompleteRequest(query: "test"))!

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenRequestIsMadeThenHasNavParameter() throws {
        stub(condition: {
            return ($0.url?.getParameter(named: "nav") == "1"
        }, response: { _ in
            return HTTPStubsResponse(data: """
                []
                """.data(using: .utf8)!, statusCode: 200, headers: nil)
        })

        let expect = expectation(description: "test")
        request.execute { _, _ in
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenModernResponseThenURLsAreNotNilForPhrasesWithNav() throws {
        stub(condition: {
            return $0.url?.path == "/ac"
        }, response: { _ in
            return HTTPStubsResponse(data: """
                [ { "phrase": "healthcare.gov", "isNav": true }, {  "phrase": "healthcare.gov", "isNav": false } ]
                """.data(using: .utf8)!, statusCode: 200, headers: nil)
        })

        let expect = expectation(description: "test")
        request.execute { suggestions, _ in
            XCTAssertNotNil(suggestions?[0].url)
            XCTAssertNil(suggestions?[1].url)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenResponseContainsLegacyResultsThenURLsAreNotNilForWebLikeSuggestions() throws {
        stub(condition: {
            return $0.url?.path == "/ac"
        }, response: { _ in
            return HTTPStubsResponse(data: """
                [ { "phrase": "healthcare.gov" }, { "phrase": "test" } ]
                """.data(using: .utf8)!, statusCode: 200, headers: nil)
        })

        let expect = expectation(description: "test")
        request.execute { suggestions, _ in
            XCTAssertNotNil(suggestions?[0].url)
            XCTAssertNil(suggestions?[1].url)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenResponseContainsUnexpectedPropertiesThenCanParseResponse() throws {
        stub(condition: {
            return $0.url?.path == "/ac"
        }, response: { _ in
            return HTTPStubsResponse(data: """
                [ { "phrase": "test", "isNav": false }, { "phrase": "test", "random": 22 } ]
                """.data(using: .utf8)!, statusCode: 200, headers: nil)
        })

        let expect = expectation(description: "test")
        request.execute { suggestions, _ in
            XCTAssertEqual(2, suggestions?.count)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
