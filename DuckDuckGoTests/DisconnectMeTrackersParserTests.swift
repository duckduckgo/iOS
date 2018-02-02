//
//  DisconnectMeTrackersParserTests.swift
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

class DisconnectMeTrackersParserTests: XCTestCase {
    
    private var data = JsonTestDataLoader()
    private var testee = DisconnectMeTrackersParser()
    
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
        let mismatchedJson = data.fromJsonFile("MockFiles/disconnect_mismatched.json")
        XCTAssertThrowsError(try testee.convert(fromJsonData: mismatchedJson), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }
    
    func testWhenJsonValidThenNoErrorThrown() {
        let validJson = data.fromJsonFile("MockFiles/disconnect.json")
        XCTAssertNoThrow(try! testee.convert(fromJsonData: validJson))
    }
    
    func testWhenJsonValidThenResultContainsAllTrackers() {
        let validJson = data.fromJsonFile("MockFiles/disconnect.json")
        let result = try! testee.convert(fromJsonData: validJson)
        XCTAssertEqual(result.count, 12)
        XCTAssertEqual(result["99anadurl.com"]?.networkName, "anadurl.com")
        XCTAssertEqual(result["analyticsurl.com"]?.networkName, "analytics.com")
        XCTAssertEqual(result["99asocialurl.com"]?.networkName, "asocialurl.com")
        XCTAssertEqual(result["acontenturl.com"]?.networkName, "content.com")
        XCTAssertEqual(result["adisconnecturl.com"]?.networkName, "disconnect.com")
        XCTAssertEqual(result["anothersocialurl.com"]?.networkName, "anothersocialurl.com")
        XCTAssertEqual(result["55anothersocialurl.com"]?.networkName, "anothersocialurl.com")
        XCTAssertEqual(result["99anothersocialurl.com"]?.networkName, "anothersocialurl.com")
        XCTAssertEqual(result["anunknowncategory.com"]?.networkName, "unknowncategory.com")
        XCTAssertEqual(result["adisconnecturl.com"]?.networkName, "disconnect.com")
    }

    func testWhenJsonValidButContainsDntEffElementInFirstPositionThenNoErrorThrown() {
        let validJson = data.fromJsonFile("MockFiles/disconnect_dnt.json")
        XCTAssertNoThrow(try! testee.convert(fromJsonData: validJson))
    }

}
