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

    var mockStatisticsStore: MockStatisticsStore!
    
    override func setUp() {
        super.setUp()
        mockStatisticsStore = MockStatisticsStore()
    }
    
    private var versionWithMockBundle: AppVersion {
        let mockBundle = MockBundle()
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: "7")
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: "900")
        return AppVersion(bundle: mockBundle)
    }

    func testHasMobileStatsParamsWithMatchingCohort() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y&t=ddg_ios&tappv=ios_7_900")!)
        let expected = true
        XCTAssertEqual(actual, expected)
    }

    func testHasMobileStatsParamsWithMismatchedCohort() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_ios&tappv=ios_7_900")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }

    func testHasMobileStatsParamsWithNoCohort() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?t=ddg_ios&tappv=ios_7_900")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }
    
    func testHasMobileStatsParamsWithMismatchedSource() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y&t=ddg_desktop&tappv=ios_7_900")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }
    
    func testHasMobileStatsParamsWithNoSource() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y&tappv=ios_7_900")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }
    
    func testHasMobileStatsParamsWithMismatchedVersion() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y&t=ddg_ios&tappv=ios_1_100")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }
    
    func testHasMobileStatsParamsWithNoVersion() {
        mockStatisticsStore.cohortVersion = "y"
        let testee = AppUrls(version: versionWithMockBundle, statisticsStore: mockStatisticsStore)
        let actual = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y&t=ddg_ios")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }
    
    func testIsSearchUrl() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGoSearch(url: URL(string: "http://duckduckgo.com?q=hello")!)
        let expected = true
        XCTAssertEqual(actual, expected)
    }

    func testIsSearchUrlWithDDGURLNoSearchParams() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGoSearch(url: URL(string: "http://duckduckgo.com?test=hello")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }

    func testIsSearchUrlWithNonDDGURL() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGoSearch(url: URL(string: "http://www.example.com")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }

    func testIsDuckDuckGoURLAsParam() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGo(url: URL(string: "http://www.example.com?x=duckduckgo.com")!)
        let expected = false
        XCTAssertEqual(actual, expected)
    }

    func testIsDuckDuckGoURLHttps() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGo(url: URL(string: "https://duckduckgo.com")!)
        let expected = true
        XCTAssertEqual(actual, expected)
    }

    func testIsDuckDuckGoURLWithSubdomain() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGo(url: URL(string: "http://www.duckduckgo.com")!)
        let expected = true
        XCTAssertEqual(actual, expected)
    }

    func testIsDuckDuckGoURL() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.isDuckDuckGo(url: URL(string: "http://duckduckgo.com")!)
        let expected = true
        XCTAssertEqual(actual, expected)
    }
    
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
