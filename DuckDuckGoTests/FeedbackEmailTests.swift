//
//  FeedbackEmailTests.swift
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
@testable import DuckDuckGo

class FeedbackEmailTests: XCTestCase {
    
    var testee: FeedbackEmail!
    
    let expectedEmail = "ios@duckduckgo.com"
    let expectedSubject = "DuckDuckGo for iOS feedback"
    let expectedBody = "I'm running DuckDuckGo 7 (567) \"v1\" on an iPhone 6 (iOS 10.6). Here's my feedback:\n"
    
    override func setUp() {
        testee = FeedbackEmail(appVersion: "DuckDuckGo 7 (567)", variant: "v1", device: "iPhone 6", osName: "iOS", osVersion: "10.6")
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
}
