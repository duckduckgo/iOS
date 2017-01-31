//
//  URLExtensionTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest

class URLExtensionTests: XCTestCase {
    
    func testIsWebUrlWithValidStringReturnsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "http://test.com"))
    }
    
    func testIsWebUrlWithValidStringAndParamsReturnsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "http://test.com?s=dafas&d=342"))
    }
    
    func testIsWebUrlWithValidStringAndInvalidParamsReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "http://test.com?s=!"))
    }
    
    func testIsWebUrlWithValidStringAndInvalidSchemeReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "asdas://test.com"))
    }
    
    func testIsWebUrlWithValidStringAndNoSchemeReturnsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "test.com"))
    }
    
    func testIsWebUrlWithStringContinaingSpaceReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "http://t est.com"))
    }
    
    func testIsWebUrlWithoutSchemeAndInvalidCharInHostReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "test!com.com"))
    }
    
    func testIsWebUrlWithSimpleStringReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "randomtext"))
    }
    
    func testWebUrlWithValidStringReturnsSameUrl() {
        let input = "http://test.com"
        let result = URL.webUrl(fromText: input)
        XCTAssertNotNil(result)
        XCTAssertEqual(input, result?.absoluteString)
    }
    
    func testWebUrlWithInvalidStringReturnsNil() {
        let result = URL.webUrl(fromText: "http://test .com")
        XCTAssertNil(result)
    }
    
    func testWebUrlWithValidStringAndNoSchemeReturnsUrlWithScheme() {
        let result = URL.webUrl(fromText: "test.com")
        XCTAssertNotNil(result)
        XCTAssertEqual("http://test.com", result?.absoluteString)
    }
    
    func testEncodeUrlEncodesText() {
        let input = "test \"%-.<>\\^_`{|~"
        let expected = "test%20%22%25-.%3C%3E%5C%5E_%60%7B%7C~"
        let actual = URL.encode(queryText: input)
        XCTAssertEqual(expected, actual)
    }
}
