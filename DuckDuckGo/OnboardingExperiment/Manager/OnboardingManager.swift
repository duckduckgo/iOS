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

enum OnboardingAddToDockState: String, Equatable, CaseIterable, CustomStringConvertible {
    case disabled
    case intro
    case contextual

    var description: String {
        switch self {
        case .disabled:
            "Disabled"
        case .intro:
            "Onboarding Intro"
        case .contextual:
            "Dax Dialogs"
        }
    }
}

final class OnboardingManager {
    private var appDefaults: AppDebugSettings
    private let featureFlagger: FeatureFlagger
    private let variantManager: VariantManager
    private let isIphone: Bool

    init(
        appDefaults: AppDebugSettings = AppDependencyProvider.shared.appSettings,
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
        variantManager: VariantManager = DefaultVariantManager(),
        isIphone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    ) {
        self.appDefaults = appDefaults
        self.featureFlagger = featureFlagger
        self.variantManager = variantManager
        self.isIphone = isIphone
    }
}

// MARK: - Add to Dock

protocol OnboardingAddToDockManaging: AnyObject {
    var addToDockEnabledState: OnboardingAddToDockState { get }
}

protocol OnboardingAddToDockDebugging: AnyObject {
    var addToDockLocalFlagState: OnboardingAddToDockState { get set }
    var isAddToDockFeatureFlagEnabled: Bool { get }
}

extension OnboardingManager: OnboardingAddToDockManaging, OnboardingAddToDockDebugging {

    var addToDockEnabledState: OnboardingAddToDockState {
        // Check if the variant supports Add to Dock
        if variantManager.isSupported(feature: .addToDockIntro) {
            return .intro
        } else if variantManager.isSupported(feature: .addToDockContextual) {
            return .contextual
        }

        // If the variant does not support Add to Dock check if it's enabled for internal users.
        guard isAddToDockFeatureFlagEnabled && isIphone else { return .disabled }

        return addToDockLocalFlagState
    }

    var addToDockLocalFlagState: OnboardingAddToDockState {
        get {
            appDefaults.onboardingAddToDockState
        }
        set {
            appDefaults.onboardingAddToDockState = newValue
        }
    }

    var isAddToDockFeatureFlagEnabled: Bool {
        featureFlagger.isFeatureOn(.onboardingAddToDock)
    }

}
