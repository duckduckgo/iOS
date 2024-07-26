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
    let reporter: OnboardingPixelReporter
    weak var delegate: OnboardingNavigationDelegate?

    init(
        suggestedSearchesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSearchesProvider(),
        delegate: OnboardingNavigationDelegate? = nil,
        reporter: OnboardingPixelReporter = OnboardingPixelReporter()) {
            self.suggestedSearchesProvider = suggestedSearchesProvider
            self.delegate = delegate
            self.reporter = reporter
        }

    var itemsList: [ContextualOnboardingListItem] {
        suggestedSearchesProvider.list
    }
    
    func listItemPressed(_ item: ContextualOnboardingListItem) {
        delegate?.searchFor(item.title)
        guard let event = suggestedSearchesProvider.pixelEventFor(item: item) else { return }
        reporter.fire(event: event, unique: true)
    }
}

struct OnboardingSiteSuggestionsViewModel {
    let suggestedSitesProvider: OnboardingSuggestionsItemsProviding
    let reporter: OnboardingPixelReporter
    weak var delegate: OnboardingNavigationDelegate?

    init(
        suggestedSitesProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSitesProvider(),
        delegate: OnboardingNavigationDelegate? = nil,
        reporter: OnboardingPixelReporter = OnboardingPixelReporter()) {
            self.suggestedSitesProvider = suggestedSitesProvider
            self.delegate = delegate
            self.reporter = reporter
        }

    var itemsList: [ContextualOnboardingListItem] {
        suggestedSitesProvider.list
    }

    func listItemPressed(_ item: ContextualOnboardingListItem) {
        guard let url = URL(string: item.title) else { return }
        delegate?.navigateTo(url: url)
        guard let event = suggestedSitesProvider.pixelEventFor(item: item) else { return }
        reporter.fire(event: event, unique: true)
    }
}
