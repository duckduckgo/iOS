//
//  AtbParserTests.swift
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

class AtbParserTests: XCTestCase {

    private var testee = AtbParser()
    private var data = JsonTestDataLoader()

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
        XCTAssertThrowsError(try testee.convert(fromJsonData: data.unexpected()), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }

    func testWhenJsonValidThenNoErrorThrown() {
        let validJson = data.fromJsonFile("MockFiles/atb.json")
        XCTAssertNoThrow(try testee.convert(fromJsonData: validJson))
    }

    func testWhenJsonValidThenResultContainsAtb() {
        let validJson = data.fromJsonFile("MockFiles/atb.json")
        let result = try? testee.convert(fromJsonData: validJson)
        XCTAssertEqual(result?.version, "v77-5")
    }

    func testWhenJsonContainsUpdateVersionThenResultContainsUpdateVersion() {
        let validJson = data.fromJsonFile("MockFiles/atb-with-update.json")
        let result = try? testee.convert(fromJsonData: validJson)
        XCTAssertEqual(result?.updateVersion, "v20-1")
    }

}
