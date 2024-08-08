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
        pixelReporter.trackSearchSuggetionOptionTapped()
        delegate?.searchFor(item.title)
    }
}

struct OnboardingSiteSuggestionsViewModel {
    let suggestedSitesProvider: OnboardingSuggestionsItemsProviding
    weak var delegate: OnboardingNavigationDelegate?
    private let pixelReporter: OnboardingSiteSuggestionsPixelReporting

    init(
        title: String,
        suggestedSitesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSitesProvider(),
        delegate: OnboardingNavigationDelegate? = nil,
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
        pixelReporter.trackSiteSuggetionOptionTapped()
        delegate?.navigateTo(url: url)
    }
}
