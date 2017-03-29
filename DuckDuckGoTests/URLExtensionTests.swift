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
    
    func testIsWebUrlWithStringContainingSpaceReturnsFalse() {
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
    
    func testDecodeUrlDecodesPercentageEncodedText() {
        let input = "test%20%22%25-.%3C%3E%5C%5E_%60%7B%7C~"
        let expected = "test \"%-.<>\\^_`{|~"
        let actual = URL.decode(query: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testDecodeUrlDecodesSpaces() {
        let input = "test+space"
        let expected = "test space"
        let actual = URL.decode(query: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testGetParamReturnsCorrectValueIfParamExists() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let expected = "secondValue"
        let actual = url?.getParam(name: "secondParam")
        XCTAssertEqual(actual, expected)
    }
    
    func testGetParamReturnsNilIfParamDoesNotExist() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let result = url?.getParam(name: "someOtherParam")
        XCTAssertNil(result)
    }
    
    func testRemoveParamReturnUrlWithoutParam() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let expected = URL(string: "http://test.com?secondParam=secondValue")
        let actual = url?.removeParam(name: "firstParam")
        XCTAssertEqual(actual, expected)
    }
    
    func testRemoveParamReturnsSameUrlIfParamDoesNotExist() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let actual = url?.removeParam(name: "someOtherParam")
        XCTAssertEqual(actual, url)
    }
    
    func testAddParamToURlWithNoParamsReturnsUrlWithParam() {
        let url = URL(string: "http://test.com")
        let expected = URL(string: "http://test.com?aParam=aValue")
        let actual = url?.addParam(name: "aParam", value: "aValue")
        XCTAssertEqual(actual, expected)
    }
    
    func testAddParamToUrlWithParamsReturnsUrlWithAppendedParam() {
        let url = URL(string: "http://test.com?firstParam=firstValue")
        let expected = URL(string: "http://test.com?firstParam=firstValue&anotherParam=anotherValue")
        let actual = url?.addParam(name: "anotherParam", value: "anotherValue")
        XCTAssertEqual(actual, expected)
    }
    
    func testAddParamToUrlWithSameParamReturnsUrlWithUpdatedParam() {
        let url = URL(string: "http://test.com?firstParam=firstValue")
        let expected = URL(string: "http://test.com?firstParam=newValue")
        let actual = url?.addParam(name: "firstParam", value: "newValue")
        XCTAssertEqual(actual, expected)
    }
}
