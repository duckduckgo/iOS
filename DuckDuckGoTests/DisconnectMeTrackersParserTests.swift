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
        let mismatchedJson = data.fromJsonFile("MockResponse/disconnect_mismatched")
        XCTAssertThrowsError(try testee.convert(fromJsonData: mismatchedJson), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }
    
    func testWhenJsonValidThenNoErrorThrown() {
        let validJson = data.fromJsonFile("MockResponse/disconnect")
        XCTAssertNoThrow(try testee.convert(fromJsonData: validJson))
    }
    
    func testWhenJsonValidThenResultContainsTrackersFromSupportedCategories() {
        let validJson = data.fromJsonFile("MockResponse/disconnect")
        let result = try! testee.convert(fromJsonData: validJson)
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0], Tracker(url: "analyticsurl.com", parentDomain: "analyticsurl.com"))
        XCTAssertEqual(result[1], Tracker(url: "99anadurl.com", parentDomain: "anadurl.com"))
        XCTAssertEqual(result[2], Tracker(url: "99asocialurl.com", parentDomain: "asocialurl.com"))
        XCTAssertEqual(result[3], Tracker(url: "anothersocialurl.com", parentDomain: "anothersocialurl.com"))
        XCTAssertEqual(result[4], Tracker(url: "55anothersocialurl.com", parentDomain: "anothersocialurl.com"))
        XCTAssertEqual(result[5], Tracker(url: "99anothersocialurl.com", parentDomain: "anothersocialurl.com"))
    }
}
