//
//  ContentBlockerEntryTests.swift
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

class ContentBlockerEntryTests: XCTestCase {
    
    private struct Constants {
        static let aDomain = "adomain.com"
        static let anotherDomain = "anotherdomain.com"
        static let aUrl = "www.aurl.com"
        static let anotherUrl = "www.anotherurl.com"
        static let category = ContentBlockerCategory.social
        static let anotherCategory = ContentBlockerCategory.advertising
    }
    
    func testThatEqualsIsTrueWhenUrlsAndDomainAreSame() {
        let lhs = ContentBlockerEntry(category: Constants.category, domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(category: Constants.category, domain: Constants.aDomain, url: Constants.aUrl)
        XCTAssertEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenDomainsDifferent() {
        let lhs = ContentBlockerEntry(category: Constants.category, domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(category: Constants.category, domain: Constants.anotherDomain, url: Constants.anotherUrl)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenUrlsDifferent() {
        let lhs = ContentBlockerEntry(category: Constants.category, domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(category: Constants.category, domain: Constants.aDomain, url: Constants.anotherUrl)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testThatEqualsFailsWhenCategoriesAreDifferent() {
        let lhs = ContentBlockerEntry(category: Constants.category, domain: Constants.aDomain, url: Constants.aUrl)
        let rhs = ContentBlockerEntry(category: Constants.anotherCategory, domain: Constants.aDomain, url: Constants.aUrl)
        XCTAssertNotEqual(lhs, rhs)
    }
}
