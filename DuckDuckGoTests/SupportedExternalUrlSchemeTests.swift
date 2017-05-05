//
//  SupportedExternalUrlSchemeTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 05/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest

class SupportedExternalUrlScheme: XCTestCase {
    
    func testThatEmailIsSupported() {
        let url = URL(string: "mailto://someurl")!
        XCTAssertTrue(SupportedExternalURLScheme.isSupported(url: url))
    }
    
    func testThatSmsIsSupported() {
        let url = URL(string: "sms://someurl")!
        XCTAssertTrue(SupportedExternalURLScheme.isSupported(url: url))
    }

    func testThatMapsAreSupported() {
        let url = URL(string: "maps://someurl")!
        XCTAssertTrue(SupportedExternalURLScheme.isSupported(url: url))
    }
    
    func testThatCallsAreSupported() {
        let url = URL(string: "tel://someurl")!
        XCTAssertTrue(SupportedExternalURLScheme.isSupported(url: url))
    }
    
    func testThatUrlsWithNoSchemeAreNotSupported() {
        let url = URL(string: "telzzz")!
        XCTAssertFalse(SupportedExternalURLScheme.isSupported(url: url))
    }
    
    func testThatUnknownSchemesAreNotSupported() {
        let url = URL(string: "other://")!
        XCTAssertFalse(SupportedExternalURLScheme.isSupported(url: url))
    }
}
