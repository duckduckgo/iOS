//
//  AppUrlsTests.swift
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
import BrowserServicesKit
@testable import Core

// swiftlint:disable type_body_length
class AppUrlsTests: XCTestCase {

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
        appConfig = AppPrivacyConfiguration(data: privacyData, identifier: "", localProtection: localProtection)
    }

    func testWhenCanDetectBlogUrl() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)

        XCTAssertTrue(testee.isBlog(url: URL(string: "https://www.spreadprivacy.com/introducing-email-protection-beta")!))
        XCTAssertTrue(testee.isBlog(url: URL(string: "https://spreadprivacy.com")!))
        XCTAssertFalse(testee.isBlog(url: URL(string: "https://notspreadprivacy.com")!))

    }

    func testWhenRemoveInternalSearchParametersFromSearchUrlThenUrlIsChanged() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)

        let searchUrl = testee.searchUrl(text: "example")
        let searchUrlWithSearchHeader = testee.applySearchHeaderParams(for: searchUrl!)
        let result = testee.removeInternalSearchParameters(fromUrl: searchUrlWithSearchHeader)

        XCTAssertNil(try result.getParameter(name: "atb"))
        XCTAssertNil(try result.getParameter(name: "t"))
        XCTAssertNil(try result.getParameter(name: "ko"))
    }

    func testWhenRemoveInternalSearchParametersFromNonSearchUrlThenUrlIsUnchanged() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let example = "https://duckduckgo.com?atb=x&t=y&ko=z"
        let result = testee.removeInternalSearchParameters(fromUrl: URL(string: example)!)
        XCTAssertEqual(example, result.absoluteString)
    }
    
    func testWhenPixelUrlRequestThenCorrectURLIsReturned() throws {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let pixelUrl = testee.pixelUrl(forPixelNamed: "ml", formFactor: "formfactor")
        
        XCTAssertEqual("improving.duckduckgo.com", pixelUrl.host)
        XCTAssertEqual("/t/ml_ios_formfactor", pixelUrl.path)
        XCTAssertEqual("x", try pixelUrl.getParameter(name: "atb"))
    }

    func testBaseUrlDoesNotHaveSubDomain() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        XCTAssertEqual(testee.base, URL(string: "https://duckduckgo.com"))
    }

    func testWhenMobileStatsParamsAreAppliedThenTheyReturnAnUpdatedUrl() throws {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = testee.applyStatsParams(for: URL(string: "http://duckduckgo.com?atb=wrong&t=wrong")!)
        XCTAssertEqual(try actual.getParameter(name: "atb"), "x")
        XCTAssertEqual(try actual.getParameter(name: "t"), "ddg_ios")
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
    
    func testWhenGPCEnableDomainIsHttpThenISGPCEnabledTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isGPCEnabled(url: URL(string: "https://www.washingtonpost.com")!, config: appConfig)
        XCTAssertTrue(result)
    }
    
    func testWhenGPCEnableDomainIsHttpsThenISGPCEnabledTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isGPCEnabled(url: URL(string: "http://www.washingtonpost.com")!, config: appConfig)
        XCTAssertTrue(result)
    }
    
    func testWhenGPCEnableDomainHasNoSubDomainThenISGPCEnabledTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isGPCEnabled(url: URL(string: "http://washingtonpost.com")!, config: appConfig)
        XCTAssertTrue(result)
    }
    
    func testWhenGPCEnableDomainHasPathThenISGPCEnabledTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isGPCEnabled(url: URL(string: "http://www.washingtonpost.com/test/somearticle.html")!,
                                         config: appConfig)
        XCTAssertTrue(result)
    }
    
    func testWhenGPCEnableDomainHasCorrectSubdomainThenISGPCEnabledTrue() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isGPCEnabled(url: URL(string: "http://global-privacy-control.glitch.me")!, config: appConfig)
        XCTAssertTrue(result)
    }
    
    func testWhenGPCEnableDomainHasWrongSubdomainThenISGPCEnabledFalse() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let result = testee.isGPCEnabled(url: URL(string: "http://glitch.me")!, config: appConfig)
        XCTAssertFalse(result)
    }
    
    func testAutocompleteUrlCreatesCorrectUrlWithParams() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let actual = try testee.autocompleteUrl(forText: "a term")
        XCTAssertTrue(testee.isDuckDuckGo(url: actual))
        XCTAssertEqual("/ac", actual.path)
        XCTAssertEqual("a term", try actual.getParameter(name: "q"))
    }

    func testInitialAtbDoesNotContainAtbParams() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.initialAtb
        XCTAssertNil(try url.getParameter(name: "atb"))
        XCTAssertNil(try url.getParameter(name: "set_atb"))
        XCTAssertNil(try url.getParameter(name: "ua"))
    }

    func testWhenAtbNotPersistsedThenSearchRetentionAtbUrlIsNil() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        XCTAssertNil(testee.searchAtb)
    }

    func testWhenAtbPersistsedThenSearchRetentionUrlHasCorrectParams() throws {
        mockStatisticsStore.atb = "x"
        mockStatisticsStore.searchRetentionAtb = "y"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchAtb
        XCTAssertNotNil(url)
        XCTAssertEqual(try url!.getParameter(name: "atb"), "x")
        XCTAssertEqual(try url!.getParameter(name: "set_atb"), "y")
        XCTAssertNil(try url!.getParameter(name: "ua"))
    }
    
    func testWhenAtbNotPersistsedThenAppRetentionAtbUrlIsNil() {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        XCTAssertNil(testee.appAtb)
    }
    
    func testWhenAtbPersistsedThenAppRetentionUrlHasCorrectParams() throws {
        mockStatisticsStore.atb = "x"
        mockStatisticsStore.appRetentionAtb = "y"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.appAtb
        XCTAssertNotNil(url)
        XCTAssertEqual(try url!.getParameter(name: "atb"), "x")
        XCTAssertEqual(try url!.getParameter(name: "set_atb"), "y")
        XCTAssertEqual(try url!.getParameter(name: "at"), "app_use")
    }

    func testSearchUrlCreatesUrlWithQueryParam() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")!
        XCTAssertEqual(try url.getParameter(name: "q"), "query")
    }

    func testExtiUrlCreatesUrlWithAtbParam() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.exti(forAtb: "x")
        XCTAssertEqual(try url.getParameter(name: "atb"), "x")
    }

    func testSearchUrlCreatesUrlWithSourceParam() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")!
        XCTAssertEqual(try url.getParameter(name: "t"), "ddg_ios")
    }
    
    func testWhenExistingQueryUsesVerticalThenItIsAppliedToNewOne() throws {
        let mock = MockVariantManager(isSupportedReturns: true)
        let testee = AppUrls(statisticsStore: mockStatisticsStore, variantManager: mock)
        let contextURL = URL(string: "https://duckduckgo.com/?q=query&iar=images&ko=-1&ia=images")!
        let url = testee.url(forQuery: "query", queryContext: contextURL)!
        
        XCTAssertEqual(try url.getParameter(name: "t"), "ddg_ios")
        XCTAssertEqual(try url.getParameter(name: "iar"), "images")
    }
    
    func testWhenExistingQueryUsesVerticalWithMapsThenTheseAreIgnored() throws {
        let mock = MockVariantManager(isSupportedReturns: true)
        let testee = AppUrls(statisticsStore: mockStatisticsStore, variantManager: mock)
        let contextURL = URL(string: "https://duckduckgo.com/?q=query&iar=images&ko=-1&ia=images&iaxm=maps")!
        let url = testee.url(forQuery: "query", queryContext: contextURL)!
        
        XCTAssertEqual(try url.getParameter(name: "t"), "ddg_ios")
        XCTAssertNil(try url.getParameter(name: "ia"))
        XCTAssertNil(try url.getParameter(name: "iaxm"))
        XCTAssertNil(try url.getParameter(name: "iar"))
    }
    
    func testWhenExistingQueryHasNoVerticalThenItIsAbsentInNewOne() throws {
        let mock = MockVariantManager(isSupportedReturns: true)
        let testee = AppUrls(statisticsStore: mockStatisticsStore, variantManager: mock)
        let contextURL = URL(string: "https://example.com")!
        let url = testee.url(forQuery: "query", queryContext: contextURL)!
        
        XCTAssertEqual(try url.getParameter(name: "t"), "ddg_ios")
        XCTAssertNil(try url.getParameter(name: "iar"))
    }

    func testWhenAtbValuesExistInStatisticsStoreThenSearchUrlCreatesUrlWithAtb() throws {
        mockStatisticsStore.atb = "x"
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let urlWithAtb = testee.searchUrl(text: "query")!
        XCTAssertEqual(try urlWithAtb.getParameter(name: "atb"), "x")
    }

    func testWhenAtbIsAbsentFromStatisticsStoreThenSearchUrlCreatesUrlWithoutAtb() throws {
        let testee = AppUrls(statisticsStore: mockStatisticsStore)
        let url = testee.searchUrl(text: "query")!
        XCTAssertNil(try url.getParameter(name: "atb"))
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
// swiftlint:enable type_body_length
