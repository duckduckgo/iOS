//
//  AutofillInterfaceEmailTruncatorTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Core
@testable import DuckDuckGo

class AutofillInterfaceEmailTruncatorTests: XCTestCase {

    func testRegularSizeEmailWithoutTruncating() {
        let email = "daxtheduck@duck.com"
        let expectedEmail = "daxtheduck@duck.com"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 20)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }

    func testRegularSizeEmailTruncating() {
        let email = "daxtheduck@duck.com"
        let expectedEmail = "dax...@duck.com"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 10)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
    
    func testLongEmailTruncating() {
        let email = "daxtheduckthebestduckyoucouldevermeet@duck.com"
        let expectedEmail = "dax...@duck.com"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 10)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
    
    func testLongEmailDomainTruncating() {
        let email = "daxtheduck@duckduckduckduckduckgo.com"
        let expectedEmail = "dax...@duckduckduckduckduckgo.com"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 15)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
    
    func testEmptyEmail() {
        let email = ""
        let expectedEmail = ""
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 10)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
    
    func testInvalidEmail() {
        let email = "dgfoisdfsdfsgdsgdfgfdhfghfhf"
        let expectedEmail = "dgfoisdfsdfsgdsgdfgfdhfghfhf"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 10)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
    
    func testEmailMatchingMaxLength() {
        let email = "daxtheduck@duck.com"
        let expectedEmail = "daxtheduck@duck.com"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 19)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
    
    func testEmailOffsetByOneFromMaxLength() {
        let email = "daxtheduck@duck.com"
        let expectedEmail = "daxthe...@duck.com"
        
        let result = AutofillInterfaceEmailTruncator.truncateEmail(email, maxLength: 18)
        
        XCTAssertEqual(expectedEmail, result, "emails should match")
    }
}
