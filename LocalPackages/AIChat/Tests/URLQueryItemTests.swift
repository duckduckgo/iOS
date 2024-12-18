//
//  URLQueryItemTests.swift
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
@testable import AIChat

class URLQueryItemTests: XCTestCase {

    func testAddingQueryItemToEmptyURL() {
        let url = URL(string: "https://example.com")!
        let queryItem = URLQueryItem(name: "key", value: "value")
        let result = url.addingOrReplacingQueryItem(queryItem)

        XCTAssertEqual(result.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
        XCTAssertEqual(result.queryItemsDictionary, ["key": "value"])
    }

    func testReplacingExistingQueryItem() {
        let url = URL(string: "https://example.com?key=oldValue")!
        let queryItem = URLQueryItem(name: "key", value: "newValue")
        let result = url.addingOrReplacingQueryItem(queryItem)

        XCTAssertEqual(result.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
        XCTAssertEqual(result.queryItemsDictionary, ["key": "newValue"])
    }

    func testAddingQueryItemToExistingQuery() {
        let url = URL(string: "https://example.com?existingKey=existingValue")!
        let queryItem = URLQueryItem(name: "newKey", value: "newValue")
        let result = url.addingOrReplacingQueryItem(queryItem)

        XCTAssertEqual(result.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
        XCTAssertEqual(result.queryItemsDictionary, ["existingKey": "existingValue", "newKey": "newValue"])
    }

    func testReplacingOneOfMultipleQueryItems() {
        let url = URL(string: "https://example.com?key1=value1&key2=value2")!
        let queryItem = URLQueryItem(name: "key1", value: "newValue1")
        let result = url.addingOrReplacingQueryItem(queryItem)

        XCTAssertEqual(result.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
        XCTAssertEqual(result.queryItemsDictionary, ["key1": "newValue1", "key2": "value2"])
    }

    func testAddingQueryItemWithNilValue() {
        let url = URL(string: "https://example.com")!
        let queryItem = URLQueryItem(name: "key", value: nil)
        let result = url.addingOrReplacingQueryItem(queryItem)

        XCTAssertEqual(result.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
        XCTAssertEqual(result.queryItemsDictionary, ["key": ""])
    }

    func testReplacingQueryItemWithNilValue() {
        let url = URL(string: "https://example.com?key=value")!
        let queryItem = URLQueryItem(name: "key", value: nil)
        let result = url.addingOrReplacingQueryItem(queryItem)

        XCTAssertEqual(result.scheme, "https")
        XCTAssertEqual(result.host, "example.com")
        XCTAssertEqual(result.queryItemsDictionary, ["key": ""])
    }
}

extension URL {
    var queryItemsDictionary: [String: String] {
        var dict = [String: String]()
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                dict[item.name] = item.value ?? ""
            }
        }
        return dict
    }
}
