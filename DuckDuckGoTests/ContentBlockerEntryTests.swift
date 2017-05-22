//
//  ContentBlockerEntryTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 23/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class ContentBlockerEntryTests: XCTestCase {
    
    private struct Constants {
        static let aDomain = "adomain.com"
        static let anotherDomain = "anotherdomain.com"
        static let aUrl = "www.aurl.com"
        static let anotherUrl = "www.anotherurl.com"
    }
    
    func testThatEqualsIsTrueWhenUrlsAndDomainAreSame() {
        let lhs = ContentBlockerEntry(domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(domain: Constants.aDomain, url: Constants.aUrl)
        XCTAssertEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenDomainsDifferent() {
        let lhs = ContentBlockerEntry(domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(domain: Constants.anotherDomain, url: Constants.anotherUrl)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenUrlsDifferent() {
        let lhs = ContentBlockerEntry(domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(domain: Constants.aDomain, url: Constants.anotherUrl)
        XCTAssertNotEqual(lhs, rhs)
    }
}
