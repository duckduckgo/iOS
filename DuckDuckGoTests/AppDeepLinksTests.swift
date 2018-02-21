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
    
    func testLowercaseQuickLinkIsDetected() {
        XCTAssert(AppDeepLinks.isQuickLink(url: URL(string: "ddgquicklink://foo.bar")!))
    }
    
    func testUppercaseQuickLinkIsDetected() {
        XCTAssert(AppDeepLinks.isQuickLink(url: URL(string: "DDGQUICKLINK://foo.bar")!))
    }
    
    func testCamelCaseQuickLinkIsDetected() {
        XCTAssert(AppDeepLinks.isQuickLink(url: URL(string: "ddgQuickLink://foo.bar")!))
    }
    
    func testLowercaseQuickLinkQueryIsExtracted() {
        XCTAssertEqual(AppDeepLinks.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar")!), "foo.bar")
    }
    
    func testLowercaseQuickLinkQueryIsExtractedURLPathPreserved() {
        XCTAssertEqual(AppDeepLinks.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar/baz/123")!), "foo.bar/baz/123")
    }
    
    func testLowercaseQuickLinkQueryIsExtractedURLQueryPreserved() {
        XCTAssertEqual(AppDeepLinks.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar/baz/123?A=b&c=D")!), "foo.bar/baz/123?A=b&c=D")
    }
    
    func testLowercaseQuickLinkQueryIsExtractedURLFragmentPreserved() {
        XCTAssertEqual(AppDeepLinks.query(fromQuickLink: URL(string: "ddgquicklink://foo.bar/baz/123#hello-world?A=b&c=D")!), "foo.bar/baz/123#hello-world?A=b&c=D")
    }
    
}
