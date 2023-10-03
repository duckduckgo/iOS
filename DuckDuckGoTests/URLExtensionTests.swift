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
    
    func testWhenHostnameHasMultiplePunycodedPartsThenItIsConsideredValid() {
        XCTAssertTrue("82.xn--b1aew.xn--p1ai".isValidHostname)
    }

    func testWhenUrlHasHttpSchemeThenToHttpsUpdatesItToHttps() {
        XCTAssertEqual(URL(string: "https://example.com"), URL(string: "http://example.com")?.toHttps())
    }
    
    func testWhenUrlHasHttpsSchemeThenToHttpsDoesNothing() {
        XCTAssertEqual(URL(string: "https://example.com"), URL(string: "https://example.com")?.toHttps())
    }

    func testWhenUrlHasOtherSchemeThenToHttpsDoesNothing() {
        XCTAssertEqual(URL(string: "other://example.com"), URL(string: "other://example.com")?.toHttps())
    }
    
    func testWhenUrlHasNoSchemeThenToHttpsDoesNothing() {
        XCTAssertEqual(URL(string: "example.com"), URL(string: "example.com")?.toHttps())
    }
    
    func testWhenMobileUrlAndToDesktopUrlIsCalledThenDesktopUrlIsReturned() {
        XCTAssertEqual("https://example.com", URL(string: "https://m.example.com")?.toDesktopUrl().absoluteString)
        XCTAssertEqual("https://example.com", URL(string: "https://mobile.example.com")?.toDesktopUrl().absoluteString)
        XCTAssertEqual("http://example.com/path/to/something?x=1",
                       URL(string: "http://m.example.com/path/to/something?x=1")?.toDesktopUrl().absoluteString)
    }

    func testWhenDesktopUrlAndToDesktopUrlIsCalledThenDesktopUrlIsSame() {
        XCTAssertEqual("https://example.com", URL(string: "https://example.com")?.toDesktopUrl().absoluteString)
        XCTAssertEqual("https://www.example.com", URL(string: "https://www.example.com")?.toDesktopUrl().absoluteString)
    }

    func testWhenURLHasLongTLDItStillIsConsideredValid() {
        XCTAssertTrue(URL.isWebUrl("https://blah.accountants"))
    }

    func testWhenGivenLongWellFormedUrlThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl("http://www.veganchic.com/products/Camo-High-Top-Sneaker-by-The-Critical-Slide-Societ+80758-0180.html"))
    }

    func testWhenHostIsValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl("test.com"))
        XCTAssertTrue(URL.isWebUrl("121.33.2.11"))
        XCTAssertTrue(URL.isWebUrl("localhost"))
        XCTAssertTrue(URL.isWebUrl("myhost.local"))
    }

    func testWhenHostIsInvalidThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl("t est.com"))
        XCTAssertFalse(URL.isWebUrl("test!com.com"))
        XCTAssertFalse(URL.isWebUrl("121.33.33."))
        XCTAssertFalse(URL.isWebUrl("localhostt"))
        XCTAssertFalse(URL.isWebUrl("localserver"))
    }

    func testWhenSchemeIsValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl("http://test.com"))
        XCTAssertTrue(URL.isWebUrl("http://121.33.2.11"))
        XCTAssertTrue(URL.isWebUrl("http://localhost"))
        XCTAssertTrue(URL.isWebUrl("http://localserver"))
    }

    func testWhenSchemeIsInvalidThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl("asdas://test.com"))
        XCTAssertFalse(URL.isWebUrl("asdas://121.33.2.11"))
        XCTAssertFalse(URL.isWebUrl("asdas://localhost"))
    }

    func testWhenTextIsIncompleteSchemeThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl("http"))
        XCTAssertFalse(URL.isWebUrl("http:"))
        XCTAssertFalse(URL.isWebUrl("http:/"))
        XCTAssertFalse(URL.isWebUrl("https"))
        XCTAssertFalse(URL.isWebUrl("https:"))
        XCTAssertFalse(URL.isWebUrl("https:/"))
    }

    func testWhenPathIsValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl("http://test.com/path"))
        XCTAssertTrue(URL.isWebUrl("http://121.33.2.11/path"))
        XCTAssertTrue(URL.isWebUrl("http://localhost/path"))
        XCTAssertTrue(URL.isWebUrl("test.com/path"))
        XCTAssertTrue(URL.isWebUrl("121.33.2.11/path"))
        XCTAssertTrue(URL.isWebUrl("localhost/path"))
    }

    func testWhenParamsAreValidThenIsWebUrlIsTrue() {
        XCTAssertTrue(URL.isWebUrl("http://test.com?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl("http://121.33.2.11?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl("http://localhost?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl("test.com?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl("121.33.2.11?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl("localhost?s=dafas&d=342"))
        XCTAssertTrue(URL.isWebUrl("https://m.facebook.com/?refsrc=https%3A%2F%2Fwww.facebook.com%2F&_rdr"))
    }

    func testWhenGivenSimpleStringThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl("randomtext"))
    }

    func testWhenGivenStringWithDotPrefixThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl(".randomtext"))
    }

    func testWhenGivenStringWithDotSuffixThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl("randomtext."))
    }

    func testWhenGivenNumberThenIsWebUrlIsFalse() {
        XCTAssertFalse(URL.isWebUrl("33"))
    }

    func testWhenWebUrlCalledWithValidURLThenSameUrlIsReturned() {
        let input = "http://test.com"
        let result = URL.webUrl(from: input)
        XCTAssertNotNil(result)
        XCTAssertEqual(input, result?.absoluteString)
    }

    func testWhenWebUrlCalledWithInvalidURLThenNilIsReturned() {
        let result = URL.webUrl(from: "http://test .com")
        XCTAssertNil(result)
    }

    func testWhenWebUrlCalledWithoutSchemeThenSchemeIsAdded() {
        let result = URL.webUrl(from: "test.com")
        XCTAssertNotNil(result)
        XCTAssertEqual("http://test.com", result?.absoluteString)
    }

    func testWhenDecodingThenPercentageEncodedTextIsReversed() {
        let input = "test%20%22%25-.%3C%3E%5C%5E_%60%7B%7C~"
        let expected = "test \"%-.<>\\^_`{|~"
        let actual = URL.decode(query: input)
        XCTAssertEqual(expected, actual)
    }

    func testWhenUrlProtocolIsHttpThenIsHttpsIsFalse() {
        let url = URL(string: "http://test.com")!
        XCTAssertFalse(url.isHttps)
    }

    func testWhenUrlProtocolIsHttpsThenIsHttpsIsTrue() {
        let url = URL(string: "https://test.com")!
        XCTAssertTrue(url.isHttps)
    }

    func testWhenUrlProtocolIsNonHttpThenIsHttpsIsFalse() {
        let url = URL(string: "mailto://test.com")!
        XCTAssertFalse(url.isHttps)
    }
    
    func testWhenHostMatchesDomainThenIsPartOfDomainIsTrue() {
        let url = URL(string: "http://example.com/index.html")!
        XCTAssertTrue(url.isPart(ofDomain: "example.com"))
    }
    
    func testWhenHostIsSubdomainThenIsPartOfDomainIsTrue() {
        let url = URL(string: "http://subdomain.example.com/index.html")!
        XCTAssertTrue(url.isPart(ofDomain: "example.com"))
    }
    
    func testWhenHostDoesNotMatchThenIsPartOfDomainIsFalse() {
        let url = URL(string: "http://notexample.com/index.html")!
        XCTAssertFalse(url.isPart(ofDomain: "example.com"))
    }

    func testWhenBookmarkletIsValid() {
        let alert = "javascript:(function() { alert(1) })()".toEncodedBookmarklet()!
        let allowReferenceError = "javascript:document".toEncodedBookmarklet()!
        XCTAssertTrue(URL.isValidBookmarklet(url: alert))
        XCTAssertTrue(URL.isValidBookmarklet(url: allowReferenceError))
    }

    func testWhenBookmarkletIsNotValid() {
        let invalidSyntax = "javascript:(fun() { alert(1) })()".toEncodedBookmarklet()!
        let invalidSyntax2 = "javascript:/".toEncodedBookmarklet()!
        XCTAssertFalse(URL.isValidBookmarklet(url: invalidSyntax))
        XCTAssertFalse(URL.isValidBookmarklet(url: invalidSyntax2))
    }

    func testWhenNormalizingURLWithNoParametersThenURLIsUnchanged() {
        let url = URL(string: "http://example.com/index.html")!
        let normalized = url.normalized()

        XCTAssertEqual(url, normalized)
    }

    func testWhenNormalizingURLWithParametersThenParametersAreRemoved() {
        let url = URL(string: "https://example.com/Path?abc=xyz")!
        let expected = URL(string: "https://example.com/Path")!
        let normalized = url.normalized()

        XCTAssertEqual(normalized, expected)
    }

    func testWhenNormalizingURLWithNoFragmentThenURLIsUnchanged() {
        let url = URL(string: "http://example.com/index.html")!
        let normalized = url.normalized()

        XCTAssertEqual(url, normalized)
    }

    func testWhenNormalizingURLWithFragmentThenFragmentIsRemoved() {
        let url = URL(string: "https://example.com/Path#fragment")!
        let expected = URL(string: "https://example.com/Path")!
        let normalized = url.normalized()

        XCTAssertEqual(normalized, expected)
    }

    func testWhenNormalizingURLWithParametersAndFragmentThenBothAreRemoved() {
        let url = URL(string: "https://example.com/Path#fragment&firstParam=1&secondParam=2")!
        let expected = URL(string: "https://example.com/Path")!
        let normalized = url.normalized()

        XCTAssertEqual(normalized, expected)
    }

}

extension URL {
    static func isWebUrl(_ text: String) -> Bool {
        return webUrl(from: text) != nil
    }
}
