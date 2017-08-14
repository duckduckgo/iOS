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
        static let url = URL(string: "https://aurl.com")!
        static let anotherUrl = URL(string: "https://anothertUrl.com")!
        static let favicon = URL(string: "https://afavicon.com")!
        static let anotherFavicon = URL(string: "https://anothertfavicon.com")!
    }
    
    func testWhenSameObjectThenEqualsPasses() {
        let link = Link(title: Constants.title, url: Constants.url)
        XCTAssertEqual(link, link)
    }
    
    func testWhenSameDataThenEqualsPasses() {
        let lhs = Link(title: Constants.title, url: Constants.url, favicon: Constants.favicon)
        let rhs = Link(title: Constants.title, url: Constants.url, favicon: Constants.favicon)
        XCTAssertEqual(lhs, rhs)
    }
    
    func testWhenTitleDifferentThenEqualsFails() {
        let lhs = Link(title: Constants.title, url: Constants.url, favicon: Constants.favicon)
        let rhs = Link(title: Constants.anotherTitle, url: Constants.url, favicon: Constants.favicon)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testWhenUrlDifferentThenEqualsFails() {
        let lhs = Link(title: Constants.title, url: Constants.url, favicon: Constants.favicon)
        let rhs = Link(title: Constants.title, url: Constants.anotherUrl, favicon: Constants.favicon)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testWhenFaviconDifferentThenEqualsFails() {
        let lhs = Link(title: Constants.title, url: Constants.url, favicon: Constants.favicon)
        let rhs = Link(title: Constants.title, url: Constants.url, favicon: Constants.anotherFavicon)
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testWhenDifferentTypeThenEqualsFails() {
        let link = Link(title: Constants.title, url: Constants.url, favicon: Constants.favicon)
        XCTAssertFalse(link.isEqual(NSObject()))
    }
}
