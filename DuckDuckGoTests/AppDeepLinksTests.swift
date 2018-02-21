//
//  AppDeepLinksTests.swift
//  UnitTests
//
//  Created by Tim Johnsen on 2/20/18.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
