//
//  AppleContentBlockerParserTests.swift
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
