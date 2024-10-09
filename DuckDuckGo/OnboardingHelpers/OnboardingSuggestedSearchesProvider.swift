//
//  OnboardingSuggestedSearchesProvider.swift
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
import Onboarding

struct OnboardingSuggestedSearchesProvider: OnboardingSuggestionsItemsProviding {
    private static let imageSearch = "!image "

    private let countryAndLanguageProvider: OnboardingRegionAndLanguageProvider
    private let onboardingManager: OnboardingHighlightsManaging

    init(
        countryAndLanguageProvider: OnboardingRegionAndLanguageProvider = Locale.current,
        onboardingManager: OnboardingHighlightsManaging = OnboardingManager()
    ) {
        self.countryAndLanguageProvider = countryAndLanguageProvider
        self.onboardingManager = onboardingManager
    }

    var list: [ContextualOnboardingListItem] {
        if onboardingManager.isOnboardingHighlightsEnabled {
            [
               option1,
               option2,
               surpriseMe
           ]
        } else {
            [
               option1,
               option2,
               option3,
               surpriseMe
           ]
        }
    }

    private var country: String? {
        countryAndLanguageProvider.regionCode
    }
    private var language: String? {
        countryAndLanguageProvider.languageCode
    }

    private var option1: ContextualOnboardingListItem {
        var search: String
        if language == "en" {
            search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOption1English
        } else {
            search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOption1International
        }
        return ContextualOnboardingListItem.search(title: search)
    }

    private var option2: ContextualOnboardingListItem {
        var search: String
        // ISO 3166-1 Region capitalized.
        // https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html
        if isUSCountry {
            search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOption2English
        } else {
            search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOption2International
        }
        return ContextualOnboardingListItem.search(title: search)
    }

    private var option3: ContextualOnboardingListItem {
        let search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOption3
        return ContextualOnboardingListItem.search(title: search)
    }

    private var surpriseMe: ContextualOnboardingListItem {
        let search = if onboardingManager.isOnboardingHighlightsEnabled {
            Self.imageSearch + UserText.HighlightsOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMe
        } else {
            isUSCountry ?
            UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeEnglish :
            UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeInternational
        }

        return ContextualOnboardingListItem.surprise(title: search, visibleTitle: UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeTitle)
    }

    private var isUSCountry: Bool {
        // ISO 3166-1 Region capitalized.
        // https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html
        country == "US"
    }

}
