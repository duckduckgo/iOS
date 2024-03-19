//
//  AddressDisplayHelperTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class AddressDisplayHelperTests: XCTestCase {

    private typealias AddressHelper = OmniBar.AddressDisplayHelper

    func testShortURL() {

        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "https://www.duckduckgo.com")!), "duckduckgo.com")
        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "https://www.duckduckgo.com/some/path")!), "duckduckgo.com")
        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "https://www.subdomain.duckduckgo.com/some/path")!), "subdomain.duckduckgo.com")
        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "https://m.duckduckgo.com/some/path")!), "m.duckduckgo.com")
        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "http://some-other.sub.domain.duck.eu/with/path")!), "some-other.sub.domain.duck.eu")
        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "http://duckduckgo.com:1234")!), "duckduckgo.com")
        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "https://192.168.0.1:1234")!), "192.168.0.1")

        XCTAssertEqual(AddressHelper.shortURLString(URL(string: "https://www.com")!), "com") // This is an exception we are ok with)

        XCTAssertNil(AddressHelper.shortURLString(URL(string: "file:///some/path")!))
        XCTAssertNil(AddressHelper.shortURLString(URL(string: "somescheme:///some/path")!))
        XCTAssertNil(AddressHelper.shortURLString(URL(string: "blob:https://www.my.com/111-222-333-444")!))
        XCTAssertNil(AddressHelper.shortURLString(URL(string: "data:text/plain;charset=UTF-8;page=21,the%20data:12345")!))
    }

    func testShortensURLWhenShortVersionExpected() {
        let addressForDisplay = AddressHelper.addressForDisplay(url: URL(string: "http://some.domain.eu/with/path")!, showsFullURL: false)

        XCTAssertEqual(addressForDisplay, "some.domain.eu")
    }

    func testDoesNotShortenURLWhenFullVersionExpected() {
        let addressForDisplay = AddressHelper.addressForDisplay(url: URL(string: "http://some.domain.eu/with/path")!, showsFullURL: true)

        XCTAssertEqual(addressForDisplay, "http://some.domain.eu/with/path")
    }

    func testFallsBackToLongURLWhenCannotProduceShortURL() {
        let addressForDisplay = AddressHelper.addressForDisplay(url: URL(string: "file:///some/path")!, showsFullURL: false)

        XCTAssertEqual(addressForDisplay, "file:///some/path")
    }
}
