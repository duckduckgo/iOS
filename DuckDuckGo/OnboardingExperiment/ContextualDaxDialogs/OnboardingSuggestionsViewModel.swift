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

    init(
        suggestedSearchesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSearchesProvider(),
        delegate: OnboardingNavigationDelegate? = nil) {
        self.suggestedSearchesProvider = suggestedSearchesProvider
        self.delegate = delegate
    }

    var itemsList: [ContextualOnboardingListItem] {
        suggestedSearchesProvider.list
    }

    func listItemPressed(_ item: ContextualOnboardingListItem) {
        delegate?.searchFor(item.title)
    }
}

struct OnboardingSiteSuggestionsViewModel {
    let suggestedSitesProvider: OnboardingSuggestionsItemsProviding
    weak var delegate: OnboardingNavigationDelegate?

    init(
        suggestedSitesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSitesProvider(),
        delegate: OnboardingNavigationDelegate? = nil) {
        self.suggestedSitesProvider = suggestedSitesProvider
        self.delegate = delegate
    }

    var itemsList: [ContextualOnboardingListItem] {
        suggestedSitesProvider.list
    }

    func listItemPressed(_ item: ContextualOnboardingListItem) {
        var urlString = item.title
        var components = URLComponents(string: urlString)
        if components?.scheme == nil {
            components?.scheme = "https"
        }
        guard let url = components?.url else { return }
        delegate?.navigateTo(url: url)
    }
}
