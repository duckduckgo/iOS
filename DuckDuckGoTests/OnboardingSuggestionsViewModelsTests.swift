//
//  OnboardingSuggestionsViewModelsTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Core
@testable import DuckDuckGo

final class OnboardingSuggestionsViewModelsTests: XCTestCase {
    var suggestionsProvider: MockOnboardingSuggestionsProvider!
    var navigationDelegate: CapturingOnboardingNavigationDelegate!
    var searchSuggestionsVM: OnboardingSearchSuggestionsViewModel!
    var siteSuggestionsVM: OnboardingSiteSuggestionsViewModel!
    var pixelReporterMock: OnboardingSuggestionsPixelReporterMock!

    override func setUp() {
        suggestionsProvider = MockOnboardingSuggestionsProvider()
        navigationDelegate = CapturingOnboardingNavigationDelegate()
        pixelReporterMock = OnboardingSuggestionsPixelReporterMock()
        searchSuggestionsVM = OnboardingSearchSuggestionsViewModel(suggestedSearchesProvider: suggestionsProvider, delegate: navigationDelegate, pixelReporter: pixelReporterMock)
        siteSuggestionsVM = OnboardingSiteSuggestionsViewModel(title: "", suggestedSitesProvider: suggestionsProvider, delegate: navigationDelegate, pixelReporter: pixelReporterMock)
    }

    override func tearDown() {
        suggestionsProvider = nil
        navigationDelegate = nil
        pixelReporterMock = nil
        searchSuggestionsVM = nil
        siteSuggestionsVM = nil
    }

    func testSearchSuggestionsViewModelReturnsExpectedSuggestionsList() {
        // GIVEN
        let expectedSearchList = [
            ContextualOnboardingListItem.search(title: "search something"),
            ContextualOnboardingListItem.surprise(title: "search something else")
        ]
        suggestionsProvider.list = expectedSearchList

        // THEN
        XCTAssertEqual(searchSuggestionsVM.itemsList, expectedSearchList)
    }

    func testSearchSuggestionsViewModelOnListItemPressed_AsksDelegateToSearchForQuery() {
        // GIVEN
        let item1 = ContextualOnboardingListItem.search(title: "search something")
        let item2 = ContextualOnboardingListItem.surprise(title: "search something else")
        suggestionsProvider.list = [item1, item2]
        let randomItem = [item1, item2].randomElement()!

        // WHEN
        searchSuggestionsVM.listItemPressed(randomItem)

        // THEN
        XCTAssertEqual(navigationDelegate.suggestedSearchQuery, randomItem.title)
    }

    func testSiteSuggestionsViewModelReturnsExpectedSuggestionsList() {
        // GIVEN
        let expectedSiteList = [
            ContextualOnboardingListItem.site(title: "somesite.com"),
            ContextualOnboardingListItem.surprise(title: "someothersite.com")
        ]
        suggestionsProvider.list = expectedSiteList

        // THEN
        XCTAssertEqual(siteSuggestionsVM.itemsList, expectedSiteList)
    }

    func testSiteSuggestionsViewModelOnListItemPressed_AsksDelegateToNavigateToURL() {
        // GIVEN
        let item1 = ContextualOnboardingListItem.site(title: "somesite.com")
        let item2 = ContextualOnboardingListItem.surprise(title: "someothersite.com")
        suggestionsProvider.list = [item1, item2]
        let randomItem = [item1, item2].randomElement()!

        // WHEN
        siteSuggestionsVM.listItemPressed(randomItem)

        // THEN
        XCTAssertNotNil(navigationDelegate.urlToNavigateTo)
        XCTAssertEqual(navigationDelegate.urlToNavigateTo, URL(string: randomItem.title))
    }

    // MARK: - Pixels

    func testWhenSearchSuggestionsTapped_ThenPixelReporterIsCalled() {
        // GIVEN
        let searches: [ContextualOnboardingListItem] = [
            ContextualOnboardingListItem.search(title: "First"),
            ContextualOnboardingListItem.search(title: "Second"),
            ContextualOnboardingListItem.search(title: "Third"),
            ContextualOnboardingListItem.surprise(title: "Surprise"),
        ]
        suggestionsProvider.list = searches
        XCTAssertFalse(pixelReporterMock.didCallTrackSearchSayDuck)
        XCTAssertFalse(pixelReporterMock.didCallTrackSearchMightyDuck)
        XCTAssertFalse(pixelReporterMock.didCallTrackSearchWeather)
        XCTAssertFalse(pixelReporterMock.didCallTrackSearchSurpriseMe)

        // WHEN
        searches.forEach { searchItem in
            searchSuggestionsVM.listItemPressed(searchItem)
        }

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackSearchSayDuck)
        XCTAssertTrue(pixelReporterMock.didCallTrackSearchMightyDuck)
        XCTAssertTrue(pixelReporterMock.didCallTrackSearchWeather)
        XCTAssertTrue(pixelReporterMock.didCallTrackSearchSurpriseMe)
    }

    func testWhenSiteSuggestionsTapped_ThenPixelReporterIsCalled() {
        // GIVEN
        let searches: [ContextualOnboardingListItem] = [
            ContextualOnboardingListItem.site(title: "First"),
            ContextualOnboardingListItem.site(title: "Second"),
            ContextualOnboardingListItem.site(title: "Third"),
            ContextualOnboardingListItem.surprise(title: "Surprise"),
        ]
        suggestionsProvider.list = searches
        XCTAssertFalse(pixelReporterMock.didCallTrackSiteESPN)
        XCTAssertFalse(pixelReporterMock.didCallTrackSiteYahoo)
        XCTAssertFalse(pixelReporterMock.didCallTrackSiteEbay)
        XCTAssertFalse(pixelReporterMock.didCallTrackSiteSurpriseMe)

        // WHEN
        searches.forEach { searchItem in
            siteSuggestionsVM.listItemPressed(searchItem)
        }

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackSiteESPN)
        XCTAssertTrue(pixelReporterMock.didCallTrackSiteYahoo)
        XCTAssertTrue(pixelReporterMock.didCallTrackSiteEbay)
        XCTAssertTrue(pixelReporterMock.didCallTrackSiteSurpriseMe)
    }

}

class MockOnboardingSuggestionsProvider: OnboardingSuggestionsItemsProviding {
    var list: [ContextualOnboardingListItem] = []
}

class CapturingOnboardingNavigationDelegate: OnboardingNavigationDelegate {
    var suggestedSearchQuery: String?
    var urlToNavigateTo: URL?

    func searchFor(_ query: String) {
        suggestedSearchQuery = query
    }
    
    func navigateTo(url: URL) {
        urlToNavigateTo = url
    }
}

final class OnboardingSuggestionsPixelReporterMock: OnboardingSiteSuggestionsPixelReporting, OnboardingSearchSuggestionsPixelReporting {
    private(set) var didCallTrackSearchSayDuck = false
    private(set) var didCallTrackSearchMightyDuck = false
    private(set) var didCallTrackSearchWeather = false
    private(set) var didCallTrackSearchSurpriseMe = false

    private(set) var didCallTrackSiteESPN = false
    private(set) var didCallTrackSiteYahoo = false
    private(set) var didCallTrackSiteEbay = false
    private(set) var didCallTrackSiteSurpriseMe = false

    func trackSearchSuggestionSayDuck() {
        didCallTrackSearchSayDuck = true
    }

    func trackSearchSuggestionMightyDuck() {
        didCallTrackSearchMightyDuck = true
    }

    func trackSearchSuggestionWeather() {
        didCallTrackSearchWeather = true
    }

    func trackSearchSuggestionSurpriseMe() {
        didCallTrackSearchSurpriseMe = true
    }

    func trackSiteSuggestionESPN() {
        didCallTrackSiteESPN = true
    }
    
    func trackSiteSuggestionYahoo() {
        didCallTrackSiteYahoo = true
    }
    
    func trackSiteSuggestionEbay() {
        didCallTrackSiteEbay = true
    }
    
    func trackSiteSuggestionSurpriseMe() {
        didCallTrackSiteSurpriseMe = true
    }

}
