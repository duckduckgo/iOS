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

protocol OnboardingRegionAndLanguageProvider {
    var regionCode: String? { get }
    var languageCode: String? { get }
}

protocol OnboardingSuggestedSearchesProviding {
    var searchesList: [ContextualOnboardingListItem] { get }
}

struct OnboardingSuggestedSearchesProvider {
    private let countryAndLanguageProvider: OnboardingRegionAndLanguageProvider

    init(countryAndLanguageProvider: OnboardingRegionAndLanguageProvider = Locale.current) {
        self.countryAndLanguageProvider = countryAndLanguageProvider
    }

    var searchesList: [ContextualOnboardingListItem] {
        return [
            option1,
            option2,
            option3,
            surpriseMe
        ]
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
        if country == "us" {
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
        var search: String
        if country == "us" {
            search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeEnglish
        } else {
            search = UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeInternational
        }
        return ContextualOnboardingListItem.surprise(title: search)
    }

}

extension Locale: OnboardingRegionAndLanguageProvider {}
