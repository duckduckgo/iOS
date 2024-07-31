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

protocol OnboardingCustomSearchPixelReporting {
    func trackCustomSearch()
    func trackCustomSite()
    func trackSecondSiteVisit()
}

protocol OnboardingPrivacyDashboardPixelReporting {
    func trackPrivacyDashboardOpen()
}

// MARK: - Implementation

final class OnboardingPixelReporter {
    private let pixel: OnboardingPixelFiring.Type
    private let uniquePixel: OnboardingPixelFiring.Type
    private let daysSinceInstallProvider: DaysSinceInstallProviding
    private let userDefaults: UserDefaults
    private let siteVisitedUserDefaultsKey = "com.duckduckgo.ios.site-visited"

    init(
        pixel: OnboardingPixelFiring.Type = Pixel.self,
        uniquePixel: OnboardingPixelFiring.Type = UniquePixel.self,
        daysSinceInstallProvider: DaysSinceInstallProviding = DaysSinceInstallProvider(),
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.pixel = pixel
        self.uniquePixel = uniquePixel
        self.daysSinceInstallProvider = daysSinceInstallProvider
        self.userDefaults = userDefaults
    }

    private func fire(event: Pixel.Event, unique: Bool, additionalParameters: [String: String] = [:]) {
        let parameters: [Pixel.QueryParameters] = [.appVersion, .atb]
        if unique {
            uniquePixel.fire(pixel: event, withAdditionalParameters: additionalParameters, includedParameters: parameters)
        } else {
            pixel.fire(pixel: event, withAdditionalParameters: additionalParameters, includedParameters: parameters)
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

// MARK: - OnboardingPixelReporter + Custom Search

extension OnboardingPixelReporter: OnboardingCustomSearchPixelReporting {
    
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

}

// MARK: - OnboardingPixelReporter + Privacy Dashboard

extension OnboardingPixelReporter: OnboardingPrivacyDashboardPixelReporting {

    func trackPrivacyDashboardOpen() {
        guard let daysSinceInstall = daysSinceInstallProvider.daysSinceInstall else { return }
        fire(event: .privacyDashboardOpened, unique: true, additionalParameters: ["daysSinceInstall": String(daysSinceInstall)])
    }

}

protocol DaysSinceInstallProviding {
    var daysSinceInstall: Int? { get }
}

final class DaysSinceInstallProvider: DaysSinceInstallProviding {
    private let store: StatisticsStore
    private let dateProvider: () -> Date

    init(store: StatisticsStore = StatisticsUserDefaults(), dateProvider: @escaping () -> Date = Date.init) {
        self.store = store
        self.dateProvider = dateProvider
    }

    var daysSinceInstall: Int? {
        guard let installDate = store.installDate else { return nil }
        return Calendar.current.numberOfDaysBetween(installDate, and: dateProvider())
    }
}
