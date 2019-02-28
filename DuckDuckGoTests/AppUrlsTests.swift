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

    func testWhenRemoveATBAndSourceFromSearchUrlThenUrlIsUnchanged() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let searchUrl = testee.searchUrl(text: "example")
        let result = testee.removeATBAndSource(fromUrl: searchUrl)
        XCTAssertNil(result.getParam(name: "atb"))
        XCTAssertNil(result.getParam(name: "t"))
    }

    func testWhenRemoveATBAndSourceFromNonSearchUrlThenUrlIsUnchanged() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let example = "https://duckduckgo.com?atb=x&t=y"
        let result = testee.removeATBAndSource(fromUrl: URL(string: example)!)
        XCTAssertEqual(example, result.absoluteString)
    }
    
    func testWhenPixelUrlRequestThenCorrectURLIsReturned() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let pixelUrl = testee.pixelUrl(forPixelNamed: "ml", formFactor: "formfactor")
        
        XCTAssertEqual("improving.duckduckgo.com", pixelUrl.host)
        XCTAssertEqual("/t/ml_ios_formfactor", pixelUrl.path)
        XCTAssertEqual("x", pixelUrl.getParam(name: "atb"))
    }
    
    func testWhenFaviconUrlForDomainRequestedThenCorrectDomainIsCreated() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let faviconURL = testee.faviconUrl(forDomain: "example.com")
        XCTAssertEqual("https://duckduckgo.com/ip3/example.com.ico", faviconURL.absoluteString)
    }

    func testBaseUrlDoesNotHaveSubDomain() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        XCTAssertEqual(testee.base, URL(string: "https://duckduckgo.com"))
    }

    func testWhenMobileStatsParamsAreAppliedThenTheyReturnAnUpdatedUrl() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.applyStatsParams(for: URL(string: "http://duckduckgo.com?atb=wrong&t=wrong")!)
        XCTAssertEqual(actual.getParam(name: "atb"), "x")
        XCTAssertEqual(actual.getParam(name: "t"), "ddg_ios")
    }

    func testWhenAtbMatchesThenHasMobileStatsParamsIsTrue() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_ios")!)
        XCTAssertTrue(result)
    }

    func testWhenAtbIsMismatchedThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "y"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_ios")!)
        XCTAssertFalse(result)
    }

    func testWhenAtbIsMissingThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?t=ddg_ios")!)
        XCTAssertFalse(result)
    }

    func testWhenSourceIsMismatchedThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_desktop")!)
        XCTAssertFalse(result)
    }

    func testWhenSourceIsMissingThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y")!)
        XCTAssertFalse(result)
    }

    func testWhenUrlIsDdgWithASearchParamThenIsSearchIsTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGoSearch(url: URL(string: "http://duckduckgo.com?q=hello")!)
        XCTAssertTrue(result)
    }

    func testWhenUrlHasNoSearchParamsThenIsSearchIsFalse() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGoSearch(url: URL(string: "http://duckduckgo.com?test=hello")!)
        XCTAssertFalse(result)
    }

    func testWhenUrlIsNonDdgThenIsSearchIsFalse() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGoSearch(url: URL(string: "http://www.example.com?q=hello")!)
        XCTAssertFalse(result)
    }

    func testWhenNonDdgUrlHasDdgParamThenIsDdgIsFalse() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGo(url: URL(string: "http://www.example.com?x=duckduckgo.com")!)
        XCTAssertFalse(result)
    }

    func testWhenDdgUrlIsHttpThenIsDddgIsTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGo(url: URL(string: "http://duckduckgo.com")!)
        XCTAssertTrue(result)
    }

    func testWhenDdgUrlIsHttpsThenIsDddgIsTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGo(url: URL(string: "https://duckduckgo.com")!)
        XCTAssertTrue(result)
    }

    func testWhenDdgUrlHasSubdomainThenIsDddgIsTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isDuckDuckGo(url: URL(string: "http://www.duckduckgo.com")!)
        XCTAssertTrue(result)
    }

    func testAutocompleteUrlCreatesCorrectUrlWithParams() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.autocompleteUrl(forText: "a term")
        XCTAssertTrue(testee.isDuckDuckGo(url: actual))
        XCTAssertEqual("/ac", actual.path)
        XCTAssertEqual("a term", actual.getParam(name: "q"))
    }

    func testInitialAtbDoesNotContainAtbParams() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.initialAtb
        XCTAssertNil(url.getParam(name: "atb"))
        XCTAssertNil(url.getParam(name: "set_atb"))
        XCTAssertNil(url.getParam(name: "ua"))
    }

    func testWhenAtbNotPersistsedThenSearchRetentionAtbUrlIsNil() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        XCTAssertNil(testee.searchAtb)
    }

    func testWhenAtbPersistsedThenSearchRetentionUrlHasCorrectParams() {
        mockStatisticsStore.atb = "x"
        mockStatisticsStore.searchRetentionAtb = "y"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchAtb
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.getParam(name: "atb"), "x")
        XCTAssertEqual(url!.getParam(name: "set_atb"), "y")
        XCTAssertNil(url!.getParam(name: "ua"))
    }
    
    func testWhenAtbNotPersistsedThenAppRetentionAtbUrlIsNil() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        XCTAssertNil(testee.appAtb)
    }
    
    func testWhenAtbPersistsedThenAppRetentionUrlHasCorrectParams() {
        mockStatisticsStore.atb = "x"
        mockStatisticsStore.appRetentionAtb = "y"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.appAtb
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.getParam(name: "atb"), "x")
        XCTAssertEqual(url!.getParam(name: "set_atb"), "y")
        XCTAssertEqual(url!.getParam(name: "type"), "app_use")
    }

    func testSearchUrlCreatesUrlWithQueryParam() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertEqual(url.getParam(name: "q"), "query")
    }

    func testExtiUrlCreatesUrlWithAtbParam() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.exti(forAtb: "x")
        XCTAssertEqual(url.getParam(name: "atb"), "x")
    }

    func testSearchUrlCreatesUrlWithSourceParam() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertEqual(url.getParam(name: "t"), "ddg_ios")
    }

    func testWhenAtbValuesExistInStatisticsStoreThenSearchUrlCreatesUrlWithAtb() {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let urlWithAtb = testee.searchUrl(text: "query")
        XCTAssertEqual(urlWithAtb.getParam(name: "atb"), "x")
    }

    func testWhenAtbIsAbsentFromStatisticsStoreThenSearchUrlCreatesUrlWithoutAtb() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")
        XCTAssertNil(url.getParam(name: "atb"))
    }

    func testWhenDdgUrlWithSearchParamThenSearchQueryReturned() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let expected = "some search"
        let actual = testee.searchQuery(fromUrl: url)
        XCTAssertEqual(actual, expected)
    }

    func testWhenNoSearchParamInDdgUrlThenSearchQueryReturnsNil() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt")!
        let result = testee.searchQuery(fromUrl: url)
        XCTAssertNil(result)
    }

    func testWhenNotDdgUrlThenSearchQueryReturnsNil() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = URL(string: "https://www.test.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let result = testee.searchQuery(fromUrl: url)
        XCTAssertNil(result)
    }
}
