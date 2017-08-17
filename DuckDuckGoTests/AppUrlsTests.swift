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
    
    var mockStatisticsStore = MockStatisticsStore()
    
    func testAutocompleteUrlCreatesCorrectUrlWithParams() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.autocompleteUrl(forText: "a term").absoluteString
        let expected = "https://duckduckgo.com/ac/?q=a%20term"
        XCTAssertEqual(actual, expected)
    }

    func testSearchUrlCreatesUrlWithQueryParam() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertEqual(url.getParam(name: "q"), "query")
    }
    
    func testSearchUrlCreatesUrlWithSourceParam() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertEqual(url.getParam(name: "t"), "ddg_ios")
    }

    func testSearchUrlCreatesUrlWithAppVersionParam() {
        let mockBundle = MockBundle()
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: "657")
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: "1.2.9")
        
        let testee = AppUrls(version: AppVersion(bundle: mockBundle), statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertEqual(url.getParam(name: "tappv"), "ios_1.2.9_657")
    }

    func testSearchUrlCreatesUrlWithCohortIfCapmaignExistsInStatisticsStore() {
        mockStatisticsStore.cohortVersion = "556"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let urlWithCohort = testee.searchUrl(text: "query")
        XCTAssertEqual(urlWithCohort.getParam(name: "atb"), "556")
    }

    func testSearchUrlCreatesUrlWithoutCohortIfNoCapmaignInStatisticsStore() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertNil(url.getParam(name: "atb"))
    }

    func testSearchQueryReturnsSearchParamInDdgUrl() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let expected = "some search"
        let actual = testee.searchQuery(fromUrl: url)
        XCTAssertEqual(actual, expected)
    }
    
    func testSearchQueryReturnsNilIfNoSearchParamInDdgUrl() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt")!
        let result = testee.searchQuery(fromUrl: url)
        XCTAssertNil(result)
    }
    
    func testSearchQueryReturnsNilIfNotDdgUrl() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = URL(string: "https://www.test.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let result = testee.searchQuery(fromUrl: url)
        XCTAssertNil(result)
    }
}
