//
//  AppleContentBlockerParserTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 20/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class AppleContentBlockerParserTests: XCTestCase {
    
    private var testee = AppleContentBlockerParser()

    func testWhenNoEntriesThenParserCreatesEmptyArray() {
        let result = testee.toJsonArray(entries: noEntries())
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 0)
    }
    
    func testWhenEntriesValidThenParserCreatesJsonArrayOfCorrectSize() {
        let result = testee.toJsonArray(entries: validEntries())
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 2)
    }
    
    func testWhenEntriesValidThenParserCreatesCorrectJsonData() {
        let result = try! testee.toJsonData(entries: validEntries())
        let resultString = String(data: result, encoding: .utf8)!
        let expectedString = "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"load-type\":[\"third-party\"],\"url-filter\":\"facebook.gb\"}},{\"action\":{\"type\":\"block\"},\"trigger\":{\"load-type\":[\"third-party\"],\"url-filter\":\"reddit.co.uk\"}}]"
        XCTAssertEqual(resultString, expectedString)
    }
    
    private func noEntries() -> [ContentBlockerEntry] {
        return [ContentBlockerEntry]()
    }

    private func validEntries() -> [ContentBlockerEntry] {
        return [
            ContentBlockerEntry(category: .social, domain: "facebook.com", url: "facebook.gb"),
            ContentBlockerEntry(category: .social, domain: "reddit.com", url: "reddit.co.uk"),
        ]
    }
}
