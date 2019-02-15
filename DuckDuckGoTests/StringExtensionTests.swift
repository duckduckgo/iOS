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

    func testWhenPunycodeUrlIsCalledOnQueryThenUrlIsNotReturned() {
        XCTAssertNil(" ".punycodedUrl?.absoluteString)
    }

    func testWhenPunycodeUrlIsCalledOnLocalHostnameThenUrlIsNotReturned() {
        XCTAssertNil("💩".punycodedUrl?.absoluteString)
    }
    
    func testWhenPunycodeUrlIsCalledWithValidUrlsThenUrlIsReturned() {
        XCTAssertEqual("xn--ls8h.la", "💩.la".punycodedUrl?.absoluteString)
        XCTAssertEqual("xn--ls8h.la/", "💩.la/".punycodedUrl?.absoluteString)
        XCTAssertEqual("82.xn--b1aew.xn--p1ai", "82.мвд.рф".punycodedUrl?.absoluteString)
        XCTAssertEqual("http://xn--ls8h.la:8080", "http://💩.la:8080".punycodedUrl?.absoluteString)
        XCTAssertEqual("http://xn--ls8h.la", "http://💩.la".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la", "https://💩.la".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/", "https://💩.la/".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/path/to/resource", "https://💩.la/path/to/resource".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/path/to/resource?query=true", "https://💩.la/path/to/resource?query=true".punycodedUrl?.absoluteString)
        XCTAssertEqual("https://xn--ls8h.la/%F0%9F%92%A9", "https://💩.la/💩".punycodedUrl?.absoluteString)
    }
    
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
