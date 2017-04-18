//
//  FeedbackEmailTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
import WebKit

class FeedbackEmailTests: XCTestCase {
    
    var testee: FeedbackEmail!
    
    let expectedEmail = "help@duckduckgo.com"
    let expectedSubject = "DuckDuckGo for iOS feedback"
    let expectedBody = "I'm running DuckDuckGo 7 (567) on an iPhone 6 (iOS 10.6). Here's my feedback:\n"
    
    override func setUp() {
        testee = FeedbackEmail(appVersion: "DuckDuckGo 7 (567)", device: "iPhone 6", osName: "iOS", osVersion: "10.6")
    }
    
    func testThatMailToIsCorrect() {
        XCTAssertEqual(testee.mailTo, expectedEmail)
    }
    
    func testThatSubjectIsCorrect() {
        XCTAssertEqual(testee.subject, expectedSubject)
    }
    
    func testThatBodyIsCorrect() {
        XCTAssertEqual(testee.body, expectedBody)
    }
    
    func testThatUrlIsCorrectWithEncodedParameters() {
        let subject = URL.encode(queryText: expectedSubject) ?? ""
        let body = URL.encode(queryText: expectedBody) ?? ""
        let expectedUrl = "mailto:help@duckduckgo.com?subject=\(subject)&body=\(body)"
        XCTAssertEqual(testee.url!.absoluteString, expectedUrl)
    }
}
