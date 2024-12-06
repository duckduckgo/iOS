//
//  OnboardingGradient.swift
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

import SwiftUI
import Onboarding

struct OnboardingGradientView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        switch colorScheme {
        case .dark:
            OnboardingGradient()
        case .light:
            // iOS 15 doesn't render properly the light EllipticalGradient while the Dark gradient is rendered correctly
            // https://app.asana.com/0/1206329551987282/1208839072951158/f
            if #available(iOS 16, *) {
                OnboardingGradient()
            } else {
                Image(.onboardingGradientLight)
                    .resizable()
            }
        @unknown default:
            OnboardingGradient()
        }
    }

}
