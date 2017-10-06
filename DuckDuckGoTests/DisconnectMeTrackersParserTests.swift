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
        XCTAssertThrowsError(try testee.convert(fromJsonData: data.empty(), categoryFilter: nil), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }
    
    func testWhenJsonInvalidThenInvalidJsonErrorThrown() {
        XCTAssertThrowsError(try testee.convert(fromJsonData: data.invalid(), categoryFilter: nil), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }
    
    func testWhenJsonIncorrectForTypeThenTypeMismatchErrorThrown() {
        let mismatchedJson = data.fromJsonFile("MockJson/disconnect_mismatched.json")
        XCTAssertThrowsError(try testee.convert(fromJsonData: mismatchedJson, categoryFilter: nil), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }
    
    func testWhenJsonValidThenNoErrorThrown() {
        let validJson = data.fromJsonFile("MockJson/disconnect.json")
        XCTAssertNoThrow(try! testee.convert(fromJsonData: validJson, categoryFilter: nil))
    }
    
    func testWhenJsonValidAndCategoryUnfilteredThenResultContainsAllTrackers() {
        let validJson = data.fromJsonFile("MockJson/disconnect.json")
        let result = try! testee.convert(fromJsonData: validJson, categoryFilter: nil)
        XCTAssertEqual(result.count, 9)
        XCTAssertEqual(result["99anadurl.com"], "anadurl.com")
        XCTAssertEqual(result["analyticsurl.com"], "analyticsurl.com")
        XCTAssertEqual(result["99asocialurl.com"], "asocialurl.com")
        XCTAssertEqual(result["acontenturl.com"], "acontenturl.com")
        XCTAssertEqual(result["adisconnecturl.com"], "adisconnecturl.com")
        XCTAssertEqual(result["anothersocialurl.com"], "anothersocialurl.com")
        XCTAssertEqual(result["55anothersocialurl.com"], "anothersocialurl.com")
        XCTAssertEqual(result["99anothersocialurl.com"], "anothersocialurl.com")
        XCTAssertEqual(result["anunknowncategory.com"], "unknowncategoryurl.com")
    }
    
    func testWhenJsonValidAndCategoryFilteredThenResultContainsOnlyFilteredTrackers() {
        let validJson = data.fromJsonFile("MockJson/disconnect.json")
        let result = try! testee.convert(fromJsonData: validJson, categoryFilter: [.analytics, .advertising, .social])
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result["99anadurl.com"], "anadurl.com")
        XCTAssertEqual(result["analyticsurl.com"], "analyticsurl.com")
        XCTAssertEqual(result["99asocialurl.com"], "asocialurl.com")
        XCTAssertEqual(result["anothersocialurl.com"], "anothersocialurl.com")
        XCTAssertEqual(result["55anothersocialurl.com"], "anothersocialurl.com")
        XCTAssertEqual(result["99anothersocialurl.com"], "anothersocialurl.com")
    }
}
