//
//  LinkTests.swift
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
@testable import Core

class LinkTests: XCTestCase {

    struct Constants {
        static let title = "A title"
        static let anotherTitle = "Another title"
        static let url = URL(string: "https://example.com")!
        static let anotherUrl = URL(string: "https://anothertUrl.com")!
        static let wwwUrl = URL(string: "https://www.example.com")!
    }

    func testWhenTitleIsNilAndUrlIsBadThenDisplayTitleUsesUrl() {
        
        let link = Link(title: nil, url: URL(string: "/bad/url")!)
        XCTAssertEqual("/bad/url", link.displayTitle)
        
    }

    func testWhenTitleIsNilThenDisplayTitleUsesUrlHostWithWWWPrefixDropped() {
        
        let link = Link(title: nil, url: Constants.wwwUrl)
        XCTAssertEqual("example.com", link.displayTitle)
        
    }

    func testWhenTitleIsNilThenDisplayTitleUsesUrlHost() {
        
        let link = Link(title: nil, url: Constants.url)
        XCTAssertEqual("example.com", link.displayTitle)
        
    }
    
    func testWhenTitleIsSetThenDisplayTitleUsesTitle() {
        
        let link = Link(title: "hello", url: Constants.wwwUrl)
        XCTAssertEqual("hello", link.displayTitle)
        
    }

    func testWhenSameObjectThenEqualsPasses() {
        let link = Link(title: Constants.title, url: Constants.url)
        XCTAssertEqual(link, link)
    }

    func testWhenSameDataThenEqualsPasses() {
        let lhs = Link(title: Constants.title, url: Constants.url)
        let rhs = Link(title: Constants.title, url: Constants.url)
        XCTAssertEqual(lhs, rhs)
    }

    func testWhenTitleDifferentThenEqualsFails() {
        let lhs = Link(title: Constants.title, url: Constants.url)
        let rhs = Link(title: Constants.anotherTitle, url: Constants.url)
        XCTAssertNotEqual(lhs, rhs)
    }

    func testWhenUrlDifferentThenEqualsFails() {
        let lhs = Link(title: Constants.title, url: Constants.url)
        let rhs = Link(title: Constants.title, url: Constants.anotherUrl)
        XCTAssertNotEqual(lhs, rhs)
    }

    func testWhenDifferentTypeThenEqualsFails() {
        let link = Link(title: Constants.title, url: Constants.url)
        XCTAssertFalse(link.isEqual(NSObject()))
    }

    func testWhenMergingWithSameUrlAndBothHaveTitlesThenPrimaryTitleIsUsed() {
        let primay = Link(title: "primary", url: URL(string: "www.example.com")!)
        let secondary = Link(title: "secondary", url: URL(string: "www.example.com")!)
        let result = primay.merge(with: secondary)
        XCTAssertEqual(result.title, "primary")
    }

    func testWhenMergingWithSameUrlAndOnlyPrimaryHasTitleThenPrimaryTitleIsUsed() {
        let primay = Link(title: "primary", url: URL(string: "www.example.com")!)
        let secondary = Link(title: nil, url: URL(string: "www.example.com")!)
        let result = primay.merge(with: secondary)
        XCTAssertEqual(result.title, "primary")
    }

    func testWhenMergingWithSameUrlAndOnlySecondaryHasTitleThenSecondaryTitleIsUsed() {
        let primay = Link(title: nil, url: URL(string: "www.example.com")!)
        let secondary = Link(title: "secondary", url: URL(string: "www.example.com")!)
        let result = primay.merge(with: secondary)
        XCTAssertEqual(result.title, "secondary")
    }

    func testWhenMergingDifferentUrlsThenSecondaryDataIsIgnored() {
        let primay = Link(title: nil, url: URL(string: "www.primary.example.com")!)
        let secondary = Link(title: "secondary", url: URL(string: "www.seconday.example.com")!)
        let result = primay.merge(with: secondary)
        XCTAssertNil(result.title)
    }
}
