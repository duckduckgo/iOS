//
//  OnboardingPixelReporter.swift
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
import Core
import BrowserServicesKit

// MARK: - Pixel Fire Interface

protocol OnboardingPixelFiring {
    static func fire(pixel: Pixel.Event, withAdditionalParameters params: [String: String], includedParameters: [Pixel.QueryParameters])
}

extension Pixel: OnboardingPixelFiring {
    static func fire(pixel: Event, withAdditionalParameters params: [String: String], includedParameters: [QueryParameters]) {
        self.fire(pixel: pixel, withAdditionalParameters: params, includedParameters: includedParameters, onComplete: { _ in })
    }
}

extension UniquePixel: OnboardingPixelFiring {
    static func fire(pixel: Pixel.Event, withAdditionalParameters params: [String: String], includedParameters: [Pixel.QueryParameters]) {
        self.fire(pixel: pixel, withAdditionalParameters: params, includedParameters: includedParameters, onComplete: { _ in })
    }
}

// MARK: - OnboardingPixelReporter

protocol OnboardingIntroImpressionReporting {
    func trackOnboardingIntroImpression()
}

protocol OnboardingIntroPixelReporting: OnboardingIntroImpressionReporting {
    func trackBrowserComparisonImpression()
    func trackChooseBrowserCTAAction()
}

protocol OnboardingSearchSuggestionsPixelReporting {
    func trackSearchSuggetionOptionTapped()
}

protocol OnboardingSiteSuggestionsPixelReporting {
    func trackSiteSuggetionOptionTapped()
}

protocol OnboardingCustomInteractionPixelReporting {
    func trackCustomSearch()
    func trackCustomSite()
    func trackSecondSiteVisit()
    func trackPrivacyDashboardOpenedForFirstTime()
}

protocol OnboardingScreenImpressionReporting {
    func trackScreenImpression(event: Pixel.Event)
}

// MARK: - Implementation

final class OnboardingPixelReporter {
    private let pixel: OnboardingPixelFiring.Type
    private let uniquePixel: OnboardingPixelFiring.Type
    private let statisticsStore: StatisticsStore
    private let calendar: Calendar
    private let dateProvider: () -> Date
    private let userDefaults: UserDefaults
    private let siteVisitedUserDefaultsKey = "com.duckduckgo.ios.site-visited"

    init(
        pixel: OnboardingPixelFiring.Type = Pixel.self,
        uniquePixel: OnboardingPixelFiring.Type = UniquePixel.self,
        statisticsStore: StatisticsStore = StatisticsUserDefaults(),
        calendar: Calendar = .current,
        dateProvider: @escaping () -> Date = Date.init,
        userDefaults: UserDefaults = UserDefaults.app
    ) {
        self.pixel = pixel
        self.uniquePixel = uniquePixel
        self.statisticsStore = statisticsStore
        self.calendar = calendar
        self.dateProvider = dateProvider
        self.userDefaults = userDefaults
    }

    private func fire(event: Pixel.Event, unique: Bool, additionalParameters: [String: String] = [:], includedParameters: [Pixel.QueryParameters] = [.appVersion, .atb]) {
        if unique {
            uniquePixel.fire(pixel: event, withAdditionalParameters: additionalParameters, includedParameters: includedParameters)
        } else {
            pixel.fire(pixel: event, withAdditionalParameters: additionalParameters, includedParameters: includedParameters)
        }
    }

}

// MARK: - OnboardingPixelReporter + Intro

extension OnboardingPixelReporter: OnboardingIntroPixelReporting {

    func trackOnboardingIntroImpression() {
        fire(event: .onboardingIntroShownUnique, unique: true)
    }

    func trackBrowserComparisonImpression() {
        fire(event: .onboardingIntroComparisonChartShownUnique, unique: true)
    }

    func trackChooseBrowserCTAAction() {
        fire(event: .onboardingIntroChooseBrowserCTAPressed, unique: false)
    }

}

// MARK: - OnboardingPixelReporter + List

extension OnboardingPixelReporter: OnboardingSearchSuggestionsPixelReporting {
    
    func trackSearchSuggetionOptionTapped() {
        fire(event: .onboardingContextualSearchOptionTappedUnique, unique: true)
    }

}

extension OnboardingPixelReporter: OnboardingSiteSuggestionsPixelReporting {
    
    func trackSiteSuggetionOptionTapped() {
        fire(event: .onboardingContextualSiteOptionTappedUnique, unique: true)
    }

}

// MARK: - OnboardingPixelReporter + Custom Interaction

extension OnboardingPixelReporter: OnboardingCustomInteractionPixelReporting {

    func trackCustomSearch() {
        fire(event: .onboardingContextualSearchCustomUnique, unique: true)
    }
    
    func trackCustomSite() {
        fire(event: .onboardingContextualSiteCustomUnique, unique: true)
    }
    
    func trackSecondSiteVisit() {
        if userDefaults.bool(forKey: siteVisitedUserDefaultsKey) {
            fire(event: .onboardingContextualSecondSiteVisitUnique, unique: true)
        } else {
            userDefaults.set(true, forKey: siteVisitedUserDefaultsKey)
        }
    }

    func trackPrivacyDashboardOpenedForFirstTime() {
        let daysSinceInstall = statisticsStore.installDate.flatMap { calendar.numberOfDaysBetween($0, and: dateProvider()) }
        let additionalParameters = [
            PixelParameters.fromOnboarding: "true",
            PixelParameters.daysSinceInstall: String(daysSinceInstall ?? 0)
        ]
        fire(event: .privacyDashboardFirstTimeOpenedUnique, unique: true, additionalParameters: additionalParameters, includedParameters: [.appVersion])
    }

}

// MARK: - OnboardingPixelReporter + Screen Impression

extension OnboardingPixelReporter: OnboardingScreenImpressionReporting {
    
    func trackScreenImpression(event: Pixel.Event) {
        fire(event: event, unique: true)
    }

}
