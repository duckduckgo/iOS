//
//  AppDeepLinksTests.swift
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

class AppDeepLinksTests: XCTestCase {

    func testWhenLinkIsLowercaseQuickLinkThenDetected() {
        XCTAssertEqual(AppDeepLinkSchemes.fromURL(URL(string: "ddgquicklink://foo.bar")!),
                       .quickLink)
    }

    func testWhenLinkIsUppercaseQuicklinkThenDetected() {
        XCTAssertEqual(AppDeepLinkSchemes.fromURL(URL(string: "DDGQUICKLINK://foo.bar")!),
                      .quickLink)
    }

    func testWhenLinkIsCamelCaseQuickLinkThenDetected() {
        XCTAssertEqual(AppDeepLinkSchemes.fromURL(URL(string: "ddgQuickLink://foo.bar")!),
                       .quickLink)
    }

    func testWhenLinkIsNotKnownSchemeThenNotDetected() {
        XCTAssertNil(AppDeepLinkSchemes.fromURL(URL(string: "someOtherType://foo.bar")!))
    }

    func testWhenLinkIsLowercaseQuickLinkThenQueryIsExtracted() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar")!), "foo.bar")
    }

    func testWhenLinkIsUppercaseQuickLinkThenQueryIsExtracted() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "DDGQUICKLINK://foo.bar")!), "foo.bar")
    }

    func testWhenLinkIsCamelCaseQuickLinkThenQueryIsExtracted() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "ddgQuickLink://foo.bar")!), "foo.bar")
    }

    func testWhenLinkIsNotQuickLinkThenQueryIsSame() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "someOtherType://foo.bar")!), "someOtherType://foo.bar")
    }

    func testWhenQuickLinkIsExtractedThenURLSchemeIsPreserved() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "ddgquicklink://https://foo.bar")!), "https://foo.bar")
    }

    func testWhenQuickLinkIsExtractedThenURLPathPreserved() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar/baz/123")!), "foo.bar/baz/123")
    }

    func testWhenQuickLinkIsExtractedThenURLQueryPreserved() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar/baz/123?A=b&c=D")!), "foo.bar/baz/123?A=b&c=D")
    }

    func testWhenQuickLinkIsExtractedThenURLFragmentPreserved() {
        XCTAssertEqual(AppDeepLinkSchemes.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar/baz/123#hello-world?A=b&c=D")!),
                       "foo.bar/baz/123#hello-world?A=b&c=D")
    }

}
