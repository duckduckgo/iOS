//
//  DisconnectMeContentBlockerParserTests.swift
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

class DisconnectMeContentBlockerParserTests: XCTestCase {
    
    private var testee = DisconnectMeContentBlockerParser()
    
    func testWhenDataEmptyThenInvalidJsonErrorThrown() {
        XCTAssertThrowsError(try testee.convert(fromJsonData: emptyData()), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }
    
    func testWhenJsonInvalidThenInvalidJsonErrorThrown() {
        XCTAssertThrowsError(try testee.convert(fromJsonData: invalidJson()), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }
    
    func testWhenJsonIncorrectForTypeThenTypeMismatchErrorThrown() {
        XCTAssertThrowsError(try testee.convert(fromJsonData: incorrectForTypeJson()), "") { (error) in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }
    
    func testWhenJsonValidThenNoErrorThrown() {
        XCTAssertNoThrow(try testee.convert(fromJsonData: validJson()))
    }
    
    func testWhenJsonValidThenResultParsedCorrectly() {
        let result = try! testee.convert(fromJsonData: validJson())
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["Advertising"]!.count, 1)
        XCTAssertEqual(result["Social"]!.count, 4)
        XCTAssertEqual(result["Advertising"]![0], ContentBlockerEntry(category: .advertising, domain: "anadurl.com", url: "99anadurl.com"))
        XCTAssertEqual(result["Social"]![0], ContentBlockerEntry(category: .social, domain: "asocialurl.com", url: "99asocialurl.com"))
        XCTAssertEqual(result["Social"]![1], ContentBlockerEntry(category: .social, domain: "anothersocialurl.com", url: "anothersocialurl.com"))
        XCTAssertEqual(result["Social"]![2], ContentBlockerEntry(category: .social, domain: "anothersocialurl.com", url: "55anothersocialurl.com"))
        XCTAssertEqual(result["Social"]![3], ContentBlockerEntry(category: .social, domain: "anothersocialurl.com", url: "99anothersocialurl.com"))
    }
    
    private func emptyData() -> Data {
        return "".data(using: .utf16)!
    }
    
    private func invalidJson() -> Data {
        return "{[}".data(using: .utf16)!
    }
    
    private func incorrectForTypeJson() -> Data {
        return try! FileLoader().load(bundle: bundle(), name: "disconnect_incorrect", ext: "json")
    }
    
    private func validJson() -> Data {
        return try! FileLoader().load(bundle: bundle(), name: "disconnect_valid", ext: "json")
    }
    
    private func bundle() ->Bundle {
        return Bundle(for: type(of: self))
    }
}
