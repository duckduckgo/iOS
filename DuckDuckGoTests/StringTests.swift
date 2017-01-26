//
//  StringTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 26/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest


class StringTests: XCTestCase {
    
    func testTrimWhitespaceRemovesLeadingSpaces() {
        let input = "  abcd"
        XCTAssertEqual("abcd", input.trimWhitespace())
    }
    
    func testTrimWhitespaceRemovesTrailingSpaces() {
        let input = "abcd  "
        XCTAssertEqual("abcd", input.trimWhitespace())
    }
    
    func testTrimWhitespaceDoesNotRemovesInnerSpaces() {
        let input = "ab  cd"
        XCTAssertEqual(input, input.trimWhitespace())
    }

    func testTrimWhitespaceRemovesLeadingWhitespaceCharacters() {
        let input = "\t\nabcd"
        XCTAssertEqual("abcd", input.trimWhitespace())
    }

    func testTrimWhitespaceRemovesTrailingWhitespaceCharacters() {
        let input = "abcd\t\n"
        XCTAssertEqual("abcd", input.trimWhitespace())
    }
    
    func testTrimWhitespaceDoesNotRemoveInnerWhitespaceCharacters() {
        let input = "ab\t\ncd"
        XCTAssertEqual(input, input.trimWhitespace())
    }
}
