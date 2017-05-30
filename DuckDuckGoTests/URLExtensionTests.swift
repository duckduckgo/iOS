//
//  URLExtensionTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest

class URLExtensionTests: XCTestCase {
    
    func testWhenHostIsValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "test.com"))
        XCTAssertTrue(URL.isWebUrl(text: "121.33.2.11"))
    }
    
    func testWhenHostIsInvalidThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "t est.com"))
        XCTAssertFalse(URL.isWebUrl(text: "test!com.com"))
        XCTAssertFalse(URL.isWebUrl(text: "121.33.33."))
    }
    
    func testWhenSchemeIsValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "http://test.com"))
        XCTAssertTrue(URL.isWebUrl(text: "http://121.33.2.11"))
    }
    
    func testWhenSchemeIsInvalidThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "asdas://test.com"))
        XCTAssertFalse(URL.isWebUrl(text: "asdas://121.33.2.11"))
    }
    
    func testWhenPathIsValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "http://test.com/path"))
        XCTAssertTrue(URL.isWebUrl(text: "http://121.33.2.11/path"))
        XCTAssertTrue(URL.isWebUrl(text: "test.com/path"))
        XCTAssertTrue(URL.isWebUrl(text: "121.33.2.11/path"))
    }
    
    func testWhenPathIsInvalidThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "http://test.com/pa th"))
        XCTAssertFalse(URL.isWebUrl(text: "http://121.33.2.11/pa th"))
        XCTAssertFalse(URL.isWebUrl(text: "test.com/pa th"))
        XCTAssertFalse(URL.isWebUrl(text: "121.33.2.11/pa th"))
    }
    
    func testWhenParamsAreValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "http://test.com?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl(text: "http://121.33.2.11?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl(text: "test.com?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl(text: "121.33.2.11?s=dafas&d=342"))
    }
    
    func testWhenParamsAreInvalidThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "http://test.com?s=!"))
        XCTAssertFalse(URL.isWebUrl(text: "http://121.33.2.11?s=!"))
        XCTAssertFalse(URL.isWebUrl(text: "test.com?s=!"))
        XCTAssertFalse(URL.isWebUrl(text: "121.33.2.11?s=!"))
    }
    
    func testWhenGivenSimpleStringThenIsWebUrlReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "randomtext"))
    }
    
    func testWhenGivenStringWithDotPrefixThenIsWebUrlReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: ".randomtext"))
    }
    
    func testWhenGivenStringWithDotSuffixThenIsWebUrlReturnsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "randomtext."))
    }
    
    func testWhenGivenNumberThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "33"))
    }

    func testWhenWebUrlCalledWithValidURLThenSameUrlIsReturned() {
        let input = "http://test.com"
        let result = URL.webUrl(fromText: input)
        XCTAssertNotNil(result)
        XCTAssertEqual(input, result?.absoluteString)
    }

    func testWhenWebUrlCalledWithInvalidURLThenNilIsReturned() {
        let result = URL.webUrl(fromText: "http://test .com")
        XCTAssertNil(result)
    }
    
    func testWhenWebUrlCalledWithoutSchemeThenSchemeIsAdded() {
        let result = URL.webUrl(fromText: "test.com")
        XCTAssertNotNil(result)
        XCTAssertEqual("http://test.com", result?.absoluteString)
    }
    
    func testWhenDecodingThenPercentageEncodedTextIsReversed() {
        let input = "test%20%22%25-.%3C%3E%5C%5E_%60%7B%7C~"
        let expected = "test \"%-.<>\\^_`{|~"
        let actual = URL.decode(query: input)
        XCTAssertEqual(expected, actual)
    }
    
    func testWhenParamExistsThenGetParamReturnsCorrectValue() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let expected = "secondValue"
        let actual = url?.getParam(name: "secondParam")
        XCTAssertEqual(actual, expected)
    }
    
    func testWhenParamDoesNotExistThenGetParamReturnsNil() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let result = url?.getParam(name: "someOtherParam")
        XCTAssertNil(result)
    }
    
    func testWhenParamExistsThenRemovingReturnUrlWithoutParam() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let expected = URL(string: "http://test.com?secondParam=secondValue")
        let actual = url?.removeParam(name: "firstParam")
        XCTAssertEqual(actual, expected)
    }
    
    func testWhenParamDoesNotExistThenRemovingReturnsSameUrl() {
        let url = URL(string: "http://test.com?firstParam=firstValue&secondParam=secondValue")
        let actual = url?.removeParam(name: "someOtherParam")
        XCTAssertEqual(actual, url)
    }
    
    func testWhenNoParamsThenAddingAppendsQuery() {
        let url = URL(string: "http://test.com")
        let expected = URL(string: "http://test.com?aParam=aValue")
        let actual = url?.addParam(name: "aParam", value: "aValue")
        XCTAssertEqual(actual, expected)
    }
    
    func testWhenParamDoesNotExistThenAddingParamAppendsItToExistingQuery() {
        let url = URL(string: "http://test.com?firstParam=firstValue")
        let expected = URL(string: "http://test.com?firstParam=firstValue&anotherParam=anotherValue")
        let actual = url?.addParam(name: "anotherParam", value: "anotherValue")
        XCTAssertEqual(actual, expected)
    }
    
    func testWhenParamHasInvalidCharactersThenAddingParamAppendsEncodedVersion() {
        let url = URL(string: "http://test.com")
        let expected = URL(string: "http://test.com?aParam=43%20%2B%205")
        let actual = url?.addParam(name: "aParam", value: "43 + 5")
        XCTAssertEqual(actual, expected)
    }
    
    func testWhenParamExistsThenAddingNewValueUpdatesParam() {
        let url = URL(string: "http://test.com?firstParam=firstValue")
        let expected = URL(string: "http://test.com?firstParam=newValue")
        let actual = url?.addParam(name: "firstParam", value: "newValue")
        XCTAssertEqual(actual, expected)
    }
}
