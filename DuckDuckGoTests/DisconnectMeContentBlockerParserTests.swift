//
//  DisconnectMeContentBlockerParserTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 22/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
        XCTAssertEqual(result["Advertising"]![0], ContentBlockerEntry(domain: "anadurl.com", url: "99anadurl.com"))
        XCTAssertEqual(result["Social"]![0], ContentBlockerEntry(domain: "asocialurl.com", url: "99asocialurl.com"))
        XCTAssertEqual(result["Social"]![1], ContentBlockerEntry(domain: "anothersocialurl.com", url: "anothersocialurl.com"))
        XCTAssertEqual(result["Social"]![2], ContentBlockerEntry(domain: "anothersocialurl.com", url: "55anothersocialurl.com"))
        XCTAssertEqual(result["Social"]![3], ContentBlockerEntry(domain: "anothersocialurl.com", url: "99anothersocialurl.com"))
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
