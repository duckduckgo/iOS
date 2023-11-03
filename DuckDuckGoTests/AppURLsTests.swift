//
//  AppURLsTests.swift
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
@testable import BrowserServicesKit
@testable import Core

final class AppURLsTests: XCTestCase {

    var mockStatisticsStore: MockStatisticsStore!
    var appConfig: PrivacyConfiguration!

    override func setUp() {
        super.setUp()
        mockStatisticsStore = MockStatisticsStore()
        
        let gpcFeature = PrivacyConfigurationData.PrivacyFeature(state: "enabled",
                                                                 exceptions: [],
                                                                 settings: [
                "gpcHeaderEnabledSites": [
                    "washingtonpost.com",
                    "nytimes.com",
                    "global-privacy-control.glitch.me"
                ]
        ])
        let privacyData = PrivacyConfigurationData(features: [PrivacyFeature.gpc.rawValue: gpcFeature],
                                                   unprotectedTemporary: [],
                                                   trackerAllowlist: [:])
        let localProtection = MockDomainsProtectionStore()
        appConfig = AppPrivacyConfiguration(data: privacyData,
                                            identifier: "",
                                            localProtection: localProtection,
                                            internalUserDecider: DefaultInternalUserDecider())
    }

    func testWhenRemoveInternalSearchParametersFromSearchUrlThenUrlIsChanged() throws {
        let searchUrl = URL.makeSearchURL(text: "example")!
        let searchUrlWithSearchHeader = searchUrl.applyingSearchHeaderParams()
        let result = searchUrlWithSearchHeader.removingInternalSearchParameters()

        XCTAssertNil(result.getParameter(named: "atb"))
        XCTAssertNil(result.getParameter(named: "t"))
        XCTAssertNil(result.getParameter(named: "ko"))
    }

    func testWhenRemoveInternalSearchParametersFromNonSearchUrlThenUrlIsUnchanged() {
        let example = URL(string: "https://duckduckgo.com?atb=x&t=y&ko=z")!
        let result = example.removingInternalSearchParameters()
        XCTAssertEqual(example.absoluteString, result.absoluteString)
    }
    
    func testWhenPixelUrlRequestThenCorrectURLIsReturned() throws {
        mockStatisticsStore.atb = "x"
        let pixelUrl = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .makePixelURL(pixelName: "ml", formFactor: "formfactor")
        
        XCTAssertEqual("improving.duckduckgo.com", pixelUrl.host)
        XCTAssertEqual("/t/ml_ios_formfactor", pixelUrl.path)
        XCTAssertEqual("x", pixelUrl.getParameter(named: "atb"))
    }

    func testBaseUrlDoesNotHaveSubDomain() {
        XCTAssertEqual(URL.ddg, URL(string: "https://duckduckgo.com"))
    }

    func testWhenMobileStatsParamsAreAppliedThenTheyReturnAnUpdatedUrl() throws {
        mockStatisticsStore.atb = "x"
        let actual = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .applyingStatsParams(to: URL(string: "http://duckduckgo.com?atb=wrong&t=wrong")!)
        XCTAssertEqual(actual.getParameter(named: "atb"), "x")
        XCTAssertEqual(actual.getParameter(named: "t"), "ddg_ios")
    }

    func testWhenAtbMatchesThenHasMobileStatsParamsIsTrue() {
        mockStatisticsStore.atb = "x"
        let result = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_ios")!)
        XCTAssertTrue(result)
    }

    func testWhenAtbIsMismatchedThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "y"
        let result = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_ios")!)
        XCTAssertFalse(result)
    }

    func testWhenAtbIsMissingThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "x"
        let result = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?t=ddg_ios")!)
        XCTAssertFalse(result)
    }

    func testWhenSourceIsMismatchedThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "x"
        let result = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=x&t=ddg_desktop")!)
        XCTAssertFalse(result)
    }

    func testWhenSourceIsMissingThenHasMobileStatsParamsIsFalse() {
        mockStatisticsStore.atb = "x"
        let result = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .hasCorrectMobileStatsParams(url: URL(string: "http://duckduckgo.com?atb=y")!)
        XCTAssertFalse(result)
    }

    func testWhenUrlIsDdgWithASearchParamThenIsSearchIsTrue() {
        let result = URL(string: "http://duckduckgo.com?q=hello")!.isDuckDuckGoSearch
        XCTAssertTrue(result)
    }

    func testWhenUrlHasNoSearchParamsThenIsSearchIsFalse() {
        let result = URL(string: "http://duckduckgo.com?test=hello")!.isDuckDuckGoSearch
        XCTAssertFalse(result)
    }

    func testWhenUrlIsNonDdgThenIsSearchIsFalse() {
        let result = URL(string: "http://www.example.com?q=hello")!.isDuckDuckGoSearch
        XCTAssertFalse(result)
    }

    func testWhenNonDdgUrlHasDdgParamThenIsDdgIsFalse() {
        let result = URL(string: "http://www.example.com?x=duckduckgo.com")!.isDuckDuckGo
        XCTAssertFalse(result)
    }

    func testWhenDdgUrlIsHttpThenIsDddgIsTrue() {
        let result = URL(string: "http://duckduckgo.com")!.isDuckDuckGo
        XCTAssertTrue(result)
    }

    func testWhenDdgUrlIsHttpsThenIsDddgIsTrue() {
        let result = URL(string: "https://duckduckgo.com")!.isDuckDuckGo
        XCTAssertTrue(result)
    }

    func testWhenDdgUrlHasSubdomainThenIsDddgIsTrue() {
        let result = URL(string: "http://www.duckduckgo.com")!.isDuckDuckGo
        XCTAssertTrue(result)
    }
    
    func testAutocompleteUrlCreatesCorrectUrlWithParams() throws {
        let actual = try URL.makeAutocompleteURL(for: "a term")
        XCTAssertTrue(actual.isDuckDuckGo)
        XCTAssertEqual("/ac", actual.path)
        XCTAssertEqual("a term", actual.getParameter(named: "q"))
    }

    func testInitialAtbDoesNotContainAtbParams() throws {
        let url = URL.atb
        XCTAssertNil(url.getParameter(named: "atb"))
        XCTAssertNil(url.getParameter(named: "set_atb"))
        XCTAssertNil(url.getParameter(named: "ua"))
    }

    func testWhenAtbNotPersistsedThenSearchRetentionAtbUrlIsNil() {
        XCTAssertNil(StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeSearchAtbURL())
    }

    func testWhenAtbPersistsedThenSearchRetentionUrlHasCorrectParams() throws {
        mockStatisticsStore.atb = "x"
        mockStatisticsStore.searchRetentionAtb = "y"
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeSearchAtbURL()
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.getParameter(named: "atb"), "x")
        XCTAssertEqual(url!.getParameter(named: "set_atb"), "y")
        XCTAssertNil(url!.getParameter(named: "ua"))
    }
    
    func testWhenAtbNotPersistsedThenAppRetentionAtbUrlIsNil() {
        XCTAssertNil(StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeAppAtbURL())
    }
    
    func testWhenAtbPersistsedThenAppRetentionUrlHasCorrectParams() throws {
        mockStatisticsStore.atb = "x"
        mockStatisticsStore.appRetentionAtb = "y"
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeAppAtbURL()
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.getParameter(named: "atb"), "x")
        XCTAssertEqual(url!.getParameter(named: "set_atb"), "y")
        XCTAssertEqual(url!.getParameter(named: "at"), "app_use")
    }

    func testSearchUrlCreatesUrlWithQueryParam() throws {
        let url = URL.makeSearchURL(text: "query")!
        XCTAssertEqual(url.getParameter(named: "q"), "query")
    }

    func testExtiUrlCreatesUrlWithAtbParam() throws {
        let url = URL.makeExtiURL(atb: "x")
        XCTAssertEqual(url.getParameter(named: "atb"), "x")
    }

    func testSearchUrlCreatesUrlWithSourceParam() throws {
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeSearchURL(text: "query")!
        XCTAssertEqual(url.getParameter(named: "t"), "ddg_ios")
    }
    
    func testWhenExistingQueryUsesVerticalThenItIsAppliedToNewOne() throws {
        let contextURL = URL(string: "https://duckduckgo.com/?q=query&iar=images&ko=-1&ia=images")!
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .makeSearchURL(query: "query", queryContext: contextURL)!
        
        XCTAssertEqual(url.getParameter(named: "t"), "ddg_ios")
        XCTAssertEqual(url.getParameter(named: "iar"), "images")
    }
    
    func testWhenExistingQueryUsesVerticalWithMapsThenTheseAreIgnored() throws {
        let contextURL = URL(string: "https://duckduckgo.com/?q=query&iar=images&ko=-1&ia=images&iaxm=maps")!
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .makeSearchURL(query: "query", queryContext: contextURL)!
        
        XCTAssertEqual(url.getParameter(named: "t"), "ddg_ios")
        XCTAssertNil(url.getParameter(named: "ia"))
        XCTAssertNil(url.getParameter(named: "iaxm"))
        XCTAssertNil(url.getParameter(named: "iar"))
    }
    
    func testWhenExistingQueryHasNoVerticalThenItIsAbsentInNewOne() throws {
        let contextURL = URL(string: "https://example.com")!
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore)
            .makeSearchURL(query: "query", queryContext: contextURL)!
        
        XCTAssertEqual(url.getParameter(named: "t"), "ddg_ios")
        XCTAssertNil(url.getParameter(named: "iar"))
    }

    func testWhenAtbValuesExistInStatisticsStoreThenSearchUrlCreatesUrlWithAtb() throws {
        mockStatisticsStore.atb = "x"
        let urlWithAtb = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeSearchURL(text: "query")!
        XCTAssertEqual(urlWithAtb.getParameter(named: "atb"), "x")
    }

    func testWhenAtbIsAbsentFromStatisticsStoreThenSearchUrlCreatesUrlWithoutAtb() throws {
        let url = StatisticsDependentURLFactory(statisticsStore: mockStatisticsStore).makeSearchURL(text: "query")!
        XCTAssertNil(url.getParameter(named: "atb"))
    }

    func testWhenDdgUrlWithSearchParamThenSearchQueryReturned() {
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let expected = "some search"
        let actual = url.searchQuery
        XCTAssertEqual(actual, expected)
    }

    func testWhenNoSearchParamInDdgUrlThenSearchQueryReturnsNil() {
        let url = URL(string: "https://www.duckduckgo.com/?ko=-1&kl=wt-wt")!
        let result = url.searchQuery
        XCTAssertNil(result)
    }

    func testWhenNotDdgUrlThenSearchQueryReturnsNil() {
        let url = URL(string: "https://www.test.com/?ko=-1&kl=wt-wt&q=some%20search")!
        let result = url.searchQuery
        XCTAssertNil(result)
    }
    
    func testExternalDependencyURLsNotChanged() {
        XCTAssertEqual(URL.surrogates.absoluteString, "https://staticcdn.duckduckgo.com/surrogates.txt")
        XCTAssertEqual(URL.privacyConfig.absoluteString, "https://staticcdn.duckduckgo.com/trackerblocking/config/v4/ios-config.json")
        XCTAssertEqual(URL.trackerDataSet.absoluteString, "https://staticcdn.duckduckgo.com/trackerblocking/v5/current/ios-tds.json")
        XCTAssertEqual(URL.bloomFilter.absoluteString, "https://staticcdn.duckduckgo.com/https/https-mobile-v2-bloom.bin")
        XCTAssertEqual(URL.bloomFilterSpec.absoluteString, "https://staticcdn.duckduckgo.com/https/https-mobile-v2-bloom-spec.json")
        XCTAssertEqual(URL.bloomFilterExcludedDomains.absoluteString, "https://staticcdn.duckduckgo.com/https/https-mobile-v2-false-positives.json")
    }
}
