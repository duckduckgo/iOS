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
    
    func testThatParserCreatesCorrectJsonData() {
        let entries = [
            ContentBlockerEntry(domain: "facebook.com", url: "facebook.gb"),
            ContentBlockerEntry(domain: "reddit.com", url: "reddit.co.uk"),
        ]
        let testee = AppleContentBlockerParser()
        let result = testee.toJsonData(forEntries: entries)!
        let resultString = String(data: result, encoding: .utf8)!
        let expectedString = "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"unless-domain\":[\"*facebook.com\"],\"load-type\":[\"third-party\"],\"url-filter\":\"facebook.gb\"}},{\"action\":{\"type\":\"block\"},\"trigger\":{\"unless-domain\":[\"*reddit.com\"],\"load-type\":[\"third-party\"],\"url-filter\":\"reddit.co.uk\"}}]"
        XCTAssertEqual(resultString, expectedString)
    }
    
    func testThatParserCreatesJsonArrayWithCorrectSize() {
        let entries = [
            ContentBlockerEntry(domain: "facebook.com", url: "facebook.gb"),
            ContentBlockerEntry(domain: "reddit.com", url: "reddit.co.uk"),
        ]
        let testee = AppleContentBlockerParser()
        let result = testee.toJsonArray(forEntries: entries)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 2)
    }
}
