//
//  OnboardingIntroViewModel+Copy.swift
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

extension OnboardingIntroViewModel {
    struct Copy {
        let introTitle: String
        let browserComparisonTitle: String
        let trackerBlockers: String
        let cookiePopups: String
        let creepyAds: String
        let eraseBrowsingData: String
    }
}

extension OnboardingIntroViewModel.Copy {

    static let `default` = OnboardingIntroViewModel.Copy(
        introTitle: UserText.DaxOnboardingExperiment.Intro.title,
        browserComparisonTitle: UserText.DaxOnboardingExperiment.BrowsersComparison.title,
        trackerBlockers: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.trackerBlockers,
        cookiePopups: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.cookiePopups,
        creepyAds: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.creepyAds,
        eraseBrowsingData: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData
    )

    static let highlights = OnboardingIntroViewModel.Copy(
        introTitle: UserText.HighlightsOnboardingExperiment.Intro.title,
        browserComparisonTitle: UserText.HighlightsOnboardingExperiment.BrowsersComparison.title,
        trackerBlockers: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.trackerBlockers,
        cookiePopups: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.cookiePopups,
        creepyAds: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.creepyAds,
        eraseBrowsingData: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData
    )
}
