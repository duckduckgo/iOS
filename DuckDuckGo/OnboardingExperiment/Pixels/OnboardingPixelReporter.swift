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

// MARK: - Pixel Fire Interface

protocol OnboardingPixelFiring {
    static func fire(pixel: Pixel.Event, withAdditionalParameters params: [String: String], includedParameters: [Pixel.QueryParameters])
}

extension Pixel: OnboardingPixelFiring {
    static func fire(pixel: Event, withAdditionalParameters params: [String: String], includedParameters: [QueryParameters]) {
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

// MARK: - Implementation

final class OnboardingPixelReporter {
    private let store: OnboardingPixelReporterStorage
    private let pixel: OnboardingPixelFiring.Type

    init(store: OnboardingPixelReporterStorage = OnboardingPixelReporterStore(), pixel: OnboardingPixelFiring.Type = Pixel.self) {
        self.store = store
        self.pixel = pixel
    }

    private func fire(event: Pixel.Event, additionalParameters: [String: String] = [:]) {
        pixel.fire(pixel: event, withAdditionalParameters: additionalParameters, includedParameters: [.appVersion, .atb])
    }

    private func fireUnique(event: Pixel.Event, for keypath: ReferenceWritableKeyPath<OnboardingPixelReporterStorage, Bool>, additionalParameters: [String: String] = [:]) {
        guard !store[keyPath: keypath] else { return }
        fire(event: event, additionalParameters: additionalParameters)
        store[keyPath: keypath] = true
    }

}

// MARK: - OnboardingAnalytics + Intro

extension OnboardingPixelReporter: OnboardingIntroPixelReporting {

    func trackOnboardingIntroImpression() {
        fireUnique(event: .onboardingIntroShownUnique, for: \.hasFiredIntroScreenShownPixel)
    }

    func trackBrowserComparisonImpression() {
        fireUnique(event: .onboardingIntroComparisonChartShownUnique, for: \.hasFiredComparisonChartShownPixel)
    }

    func trackChooseBrowserCTAAction() {
        fire(event: .onboardingIntroChooseBrowserCTAPressed)
    }

}
