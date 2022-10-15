//
//  TermsOfServiceListParserTests.swift
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
@testable import Core
@testable import BrowserServicesKit
import Common

class TermsOfServiceListParserTests: XCTestCase {

    private var data = JsonTestDataLoader()
    private var testee = TermsOfServiceListParser()

    func testWhenDataEmptyThenInvalidJsonErrorThrown() {
        XCTAssertThrowsError(try testee.convert(fromJsonData: data.empty()), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }

    func testWhenJsonInvalidThenInvalidJsonErrorThrown() {
        XCTAssertThrowsError(try testee.convert(fromJsonData: data.invalid()), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }

    func testWhenJsonIncorrectForTypeThenTypeMismatchErrorThrown() {
        let mismatchedJson = data.fromJsonFile("MockFiles/tosdr_mismatched.json")
        XCTAssertThrowsError(try testee.convert(fromJsonData: mismatchedJson), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }

    func testWhenJsonValidThenNoErrorThrown() {
        XCTAssertNoThrow(try testee.convert(fromJsonData: data.fromJsonFile("MockFiles/tosdr.json")))
    }

    func testWhenJsonValidThenResultContainsTerms() {
        guard let result = try? testee.convert(fromJsonData: data.fromJsonFile("MockFiles/tosdr.json")) else {
            XCTFail("Failed to convert from json data")
            return
        }
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["example.com"]?.derivedScore, 5)
        XCTAssertEqual(result["anotherexample.com"]?.derivedScore, 1)
        XCTAssertEqual(result["example.com"]?.goodReasons.count, 1)
        XCTAssertEqual(result["example.com"]?.goodReasons[0], "you can request access and deletion of personal data")
        XCTAssertEqual(result["example.com"]?.badReasons.count, 3)
        XCTAssertEqual(result["example.com"]?.badReasons[0], "targeted third-party advertising")
    }

}
