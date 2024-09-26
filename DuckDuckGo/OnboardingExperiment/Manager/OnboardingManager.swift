//
//  OnboardingManager.swift
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

import BrowserServicesKit
import Core

protocol OnboardingHighlightsManaging: AnyObject {
    var isOnboardingHighlightsEnabled: Bool { get }
}

protocol OnboardingHighlightsDebugging: OnboardingHighlightsManaging {
    var isLocalFlagEnabled: Bool { get set }
    var isFeatureFlagEnabled: Bool { get }
}

final class OnboardingManager: OnboardingHighlightsManaging, OnboardingHighlightsDebugging {
    private var appDefaults: AppDebugSettings
    private let featureFlagger: FeatureFlagger
    private let variantManager: VariantManager

    init(
        appDefaults: AppDebugSettings = AppDependencyProvider.shared.appSettings,
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
        variantManager: VariantManager = DefaultVariantManager()
    ) {
        self.appDefaults = appDefaults
        self.featureFlagger = featureFlagger
        self.variantManager = variantManager
    }

    var isOnboardingHighlightsEnabled: Bool {
        variantManager.isOnboardingHighlightsExperiment || (isLocalFlagEnabled && isFeatureFlagEnabled)
    }

    var isLocalFlagEnabled: Bool {
        get {
            appDefaults.onboardingHighlightsEnabled
        }
        set {
            appDefaults.onboardingHighlightsEnabled = newValue
        }
    }

    var isFeatureFlagEnabled: Bool {
        featureFlagger.isFeatureOn(.onboardingHighlights)
    }
}
