//
//  OnboardingSuggestedSearchesProviderTests.swift
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
import Onboarding
@testable import DuckDuckGo

class OnboardingSuggestedSearchesProviderTests: XCTestCase {
    private var onboardingManagerMock: OnboardingManagerMock!
    let userText = UserText.DaxOnboardingExperiment.ContextualOnboarding.self
    let highlightsUserText = UserText.HighlightsOnboardingExperiment.ContextualOnboarding.self
    static let imageSearch = "!image "

    override func setUpWithError() throws {
        try super.setUpWithError()
        onboardingManagerMock = OnboardingManagerMock()
    }

    override func tearDownWithError() throws {
        onboardingManagerMock = nil
        try super.tearDownWithError()
    }

    func testSearchesListForEnglishLanguageAndUsRegion() {
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "US", languageCode: "en")
        let provider = OnboardingSuggestedSearchesProvider(countryAndLanguageProvider: mockProvider, onboardingManager: onboardingManagerMock)

        let expectedSearches = [
            ContextualOnboardingListItem.search(title: userText.tryASearchOption1English),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption2English),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption3),
            ContextualOnboardingListItem.surprise(title: userText.tryASearchOptionSurpriseMeEnglish, visibleTitle: "Surprise me!")
        ]

        XCTAssertEqual(provider.list, expectedSearches)
    }

    func testSearchesListForNonEnglishLanguageAndNonUSRegion() {
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "FR", languageCode: "fr")
        let provider = OnboardingSuggestedSearchesProvider(countryAndLanguageProvider: mockProvider, onboardingManager: onboardingManagerMock)

        let expectedSearches = [
            ContextualOnboardingListItem.search(title: userText.tryASearchOption1International),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption2International),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption3),
            ContextualOnboardingListItem.surprise(title: userText.tryASearchOptionSurpriseMeInternational, visibleTitle: "Surprise me!")
        ]

        XCTAssertEqual(provider.list, expectedSearches)
    }

    func testSearchesListForUSRegionAndNonEnglishLanguage() {
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "US", languageCode: "es")
        let provider = OnboardingSuggestedSearchesProvider(countryAndLanguageProvider: mockProvider, onboardingManager: onboardingManagerMock)

        let expectedSearches = [
            ContextualOnboardingListItem.search(title: userText.tryASearchOption1International),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption2English),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption3),
            ContextualOnboardingListItem.surprise(title: userText.tryASearchOptionSurpriseMeEnglish, visibleTitle: "Surprise me!")
        ]

        XCTAssertEqual(provider.list, expectedSearches)
    }

    // MARK: - Higlights Experiment

    func testWhenHighlightsOnboardingAndSearchesListForEnglishLanguageAndUsRegionThenDoNotReturnOption3() {
        onboardingManagerMock.isOnboardingHighlightsEnabled = true
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "US", languageCode: "en")
        let provider = OnboardingSuggestedSearchesProvider(countryAndLanguageProvider: mockProvider, onboardingManager: onboardingManagerMock)

        let expectedSearches = [
            ContextualOnboardingListItem.search(title: userText.tryASearchOption1English),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption2English),
            ContextualOnboardingListItem.surprise(title: Self.imageSearch + highlightsUserText.tryASearchOptionSurpriseMe, visibleTitle: "Surprise me!")
        ]

        XCTAssertEqual(provider.list, expectedSearches)
    }

    func testWhenHighlightsOnboardingAndSearchesListForNonEnglishLanguageAndNonUSRegionThenDoNotReturnOption3() {
        onboardingManagerMock.isOnboardingHighlightsEnabled = true
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "FR", languageCode: "fr")
        let provider = OnboardingSuggestedSearchesProvider(countryAndLanguageProvider: mockProvider, onboardingManager: onboardingManagerMock)

        let expectedSearches = [
            ContextualOnboardingListItem.search(title: userText.tryASearchOption1International),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption2International),
            ContextualOnboardingListItem.surprise(title: Self.imageSearch + highlightsUserText.tryASearchOptionSurpriseMe, visibleTitle: "Surprise me!")
        ]

        XCTAssertEqual(provider.list, expectedSearches)
    }

    func testWhenHighlightsOnboardingAndSearchesListForUSRegionAndNonEnglishLanguageThenDoNotReturnOption3() {
        onboardingManagerMock.isOnboardingHighlightsEnabled = true
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "US", languageCode: "es")
        let provider = OnboardingSuggestedSearchesProvider(countryAndLanguageProvider: mockProvider, onboardingManager: onboardingManagerMock)

        let expectedSearches = [
            ContextualOnboardingListItem.search(title: userText.tryASearchOption1International),
            ContextualOnboardingListItem.search(title: userText.tryASearchOption2English),
            ContextualOnboardingListItem.surprise(title: Self.imageSearch + highlightsUserText.tryASearchOptionSurpriseMe, visibleTitle: "Surprise me!")
        ]

        XCTAssertEqual(provider.list, expectedSearches)
    }

}

class MockOnboardingRegionAndLanguageProvider: OnboardingRegionAndLanguageProvider {
    var regionCode: String?
    var languageCode: String?

    init(regionCode: String?, languageCode: String?) {
        self.regionCode = regionCode
        self.languageCode = languageCode
    }
}
