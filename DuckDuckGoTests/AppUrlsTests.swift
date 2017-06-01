//
//  AppUrlsManagerTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
