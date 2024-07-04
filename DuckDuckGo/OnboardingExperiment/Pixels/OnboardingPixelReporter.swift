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

protocol OnboardingIntroPixelReporter {
    func trackOnboardingIntroImpression()
    func trackBrowserComparisonImpression()
    func trackChooseBrowserCTAAction()
}

typealias OnboardingPixelReporter = OnboardingIntroPixelReporter

// MARK: - Implementation

final class OnboardingPixelHandler {
    private let pixel: OnboardingPixelFiring.Type

    init(pixel: OnboardingPixelFiring.Type = Pixel.self) {
        self.pixel = pixel
    }

    private func fire(event: Pixel.Event, additionalParameters: [String: String] = [:]) {
        pixel.fire(pixel: event, withAdditionalParameters: additionalParameters, includedParameters: [.appVersion, .atb])
    }

}

// MARK: - OnboardingAnalytics + Intro

extension OnboardingPixelHandler: OnboardingIntroPixelReporter {

    func trackOnboardingIntroImpression() {
        fire(event: .onboardingIntroShown)
    }

    func trackBrowserComparisonImpression() {
        fire(event: .onboardingIntroComparisonChartShown)
    }

    func trackChooseBrowserCTAAction() {
        fire(event: .onboardingIntroChooseBrowserCTAPressed)
    }

}
