//
//  OnboardingSuggestionsViewModel.swift
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

import Foundation

protocol OnboardingNavigationDelegate: AnyObject {
    func searchFor(_ query: String)
    func navigateTo(url: URL)
}

struct OnboardingSearchSuggestionsViewModel {
    let suggestedSearchesProvider: OnboardingSuggestionsItemsProviding
    weak var delegate: OnboardingNavigationDelegate?
    private let pixelReporter: OnboardingSearchSuggestionsPixelReporting

    init(
        suggestedSearchesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSearchesProvider(),
        delegate: OnboardingNavigationDelegate? = nil,
        pixelReporter: OnboardingSearchSuggestionsPixelReporting = OnboardingPixelReporter()
    ) {
        self.suggestedSearchesProvider = suggestedSearchesProvider
        self.delegate = delegate
        self.pixelReporter = pixelReporter
    }

    var itemsList: [ContextualOnboardingListItem] {
        suggestedSearchesProvider.list
    }

    func listItemPressed(_ item: ContextualOnboardingListItem) {
        firePixel(for: item)
        delegate?.searchFor(item.title)
    }

    // Temporary pixels, they will be removed.
    // This avoid refactoring `OnboardingSuggestedSearchesProvider` and `ContextualOnboardingListItem` when removing the pixels
    // This is covered by tests
    private func firePixel(for item: ContextualOnboardingListItem) {
        guard let index = itemsList.firstIndex(of: item) else { return }
        switch index {
        case 0:
            pixelReporter.trackSearchSuggestionSayDuck()
        case 1:
            pixelReporter.trackSearchSuggestionMightyDuck()
        case 2:
            pixelReporter.trackSearchSuggestionWeather()
        case 3:
            pixelReporter.trackSearchSuggestionSurpriseMe()
        default: break
        }
    }
}

struct OnboardingSiteSuggestionsViewModel {
    let suggestedSitesProvider: OnboardingSuggestionsItemsProviding
    weak var delegate: OnboardingNavigationDelegate?
    private let pixelReporter: OnboardingSiteSuggestionsPixelReporting

    init(
        title: String,
        suggestedSitesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSitesProvider(),
        delegate: OnboardingNavigationDelegate? = nil
        pixelReporter: OnboardingSiteSuggestionsPixelReporting = OnboardingPixelReporter()
    ) {
        self.title = title
        self.suggestedSitesProvider = suggestedSitesProvider
        self.delegate = delegate
        self.pixelReporter = pixelReporter
    }

    let title: String

    var itemsList: [ContextualOnboardingListItem] {
        suggestedSitesProvider.list
    }

    func listItemPressed(_ item: ContextualOnboardingListItem) {
        guard let url = URL(string: item.title) else { return }
        firePixel(for: item)
        delegate?.navigateTo(url: url)
    }

    // Temporary pixels, they will be removed.
    // This avoid refactoring `OnboardingSuggestedSitesProvider` and `ContextualOnboardingListItem` when removing the pixels
    // This is covered by tests
    private func firePixel(for item: ContextualOnboardingListItem) {
        guard let index = itemsList.firstIndex(of: item) else { return }
        switch index {
        case 0:
            pixelReporter.trackSiteSuggestionESPN()
        case 1:
            pixelReporter.trackSiteSuggestionYahoo()
        case 2:
            pixelReporter.trackSiteSuggestionEbay()
        case 3:
            pixelReporter.trackSiteSuggestionSurpriseMe()
        default: break
        }
    }

}
