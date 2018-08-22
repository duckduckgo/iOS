//
//  StringExtensionTests.swift
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

class StringExtensionTests: XCTestCase {

    func testWhenDropPrefixIsCalledWithoutMatchingPrefixThenStringIsUnchanged() {
        XCTAssertEqual("subdomain.example.com", "subdomain.example.com".dropPrefix(prefix: "www."))
    }

    func testWhenDropPrefixIsCalledWithMatchingPrefixThenItIsDropped() {
        XCTAssertEqual("example.com", "www.example.com".dropPrefix(prefix: "www."))
    }
    
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
