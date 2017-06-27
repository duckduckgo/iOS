//
//  AppUrlsManagerTests.swift
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

class AppUrlsTests: XCTestCase {
    
    func testSearchUrlCreatesCorrectUrlWithParams() {
        let filters = MockSearchFilterStore()
        let actual = AppUrls.searchUrl(text: "some search", filters: filters)?.absoluteString
        let expected = "https://www.duckduckgo.com/?ko=-1&kl=wt-wt&q=some%20search"
        XCTAssertEqual(actual, expected)
    }
    
    func testAutocompleteUrlCreatesCorrectUrlWithParams() {
        let actual = AppUrls.autocompleteUrl(forText: "a term")?.absoluteString
        let expected = "https://duckduckgo.com/ac/?q=a%20term"
        XCTAssertEqual(actual, expected)
    }
    
    func testSearchQueryReturnsSearchParamInDdgUrl() {
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let expected = "some search"
        let actual = AppUrls.searchQuery(fromUrl: url)
        XCTAssertEqual(actual, expected)
    }
    
    func testSearchQueryReturnsNilIfNoSearchParamInDdgUrl() {
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt")!
        let result = AppUrls.searchQuery(fromUrl: url)
        XCTAssertNil(result)
    }
    
    func testSearchQueryReturnsNilIfNotDdgUrl() {
        let url = URL(string: "https://www.test.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let result = AppUrls.searchQuery(fromUrl: url)
        XCTAssertNil(result)
    }
    
    struct MockSearchFilterStore: SearchFilterStore {
        var safeSearchEnabled = true
        var regionFilter: String? = nil
        var dateFilter: String? = nil
    }
}
