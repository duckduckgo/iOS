//
//  URLExtensionTests.swift
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

class URLExtensionTests: XCTestCase {

    func testWhenUserIsPresentThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "http://example.com@sample.com"))
    }

    func testWhenGivenLongWellFormedUrlThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl(text: "http://www.veganchic.com/products/Camo-High-Top-Sneaker-by-The-Critical-Slide-Societ+80758-0180.html"))
    }

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
        XCTAssertTrue(URL.isWebUrl(text: "https://m.facebook.com/?refsrc=https%3A%2F%2Fwww.facebook.com%2F&_rdr"))
    }
    
    func testWhenGivenSimpleStringThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: "randomtext"))
    }
    
    func testWhenGivenStringWithDotPrefixThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(text: ".randomtext"))
    }
    
    func testWhenGivenStringWithDotSuffixThenIsWebUrlIsFalse() {
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
    
    func testWhenParamDoesNotExistThenGetParamIsNil() {
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
    
    func testWhenUrlProtocolIsHttpThenIsHttpsIsFalse() {
        let url = URL(string: "http://test.com")!
        XCTAssertFalse(url.isHttps())
    }
    
    func testWhenUrlProtocolIsHttpsThenIsHttpsIsTrue() {
        let url = URL(string: "https://test.com")!
        XCTAssertTrue(url.isHttps())
    }

    func testWhenUrlProtocolIsNonHttpThenIsHttpsIsFalse() {
        let url = URL(string: "mailto://test.com")!
        XCTAssertFalse(url.isHttps())
    }
}
