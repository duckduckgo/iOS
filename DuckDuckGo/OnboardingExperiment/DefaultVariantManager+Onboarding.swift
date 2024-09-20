//
//  DefaultVariantManager+Onboarding.swift
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
import BrowserServicesKit

extension VariantManager {

    var isNewIntroFlow: Bool {
        isSupported(feature: .newOnboardingIntro) || isSupported(feature: .newOnboardingIntroHighlights)
    }

    var isOnboardingHighlightsExperiment: Bool {
        isSupported(feature: .newOnboardingIntroHighlights)
    }

    var shouldShowDaxDialogs: Bool {
        // Disable Dax Dialogs if only feature supported is .newOnboardingIntro
        guard let features = currentVariant?.features else { return true }
        return !(features.count == 1 && features.contains(.newOnboardingIntro))
    }

    var isContextualDaxDialogsEnabled: Bool {
        isSupported(feature: .contextualDaxDialogs)
    }

}
