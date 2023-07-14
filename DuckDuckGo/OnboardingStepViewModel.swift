//
//  OnboardingStepViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

#if APP_TRACKING_PROTECTION

struct OnboardingStepViewModel {
    let title: String
    let paragraph1: Text
    let paragraph2: Text
    let auxButtonTitle: String?
    let primaryButtonTitle: String
    let pictogramName: String
    
    static let onboardingData: [OnboardingStepViewModel] = [
        OnboardingStepViewModel(
            title: UserText.appTPOnboardingTitle1,
            paragraph1: {
                Text(UserText.appTPOnboardingPage1Info1)
                    .fontWeight(.bold)
                + Text(UserText.appTPOnboardingPage1Info2)
            }(),
            paragraph2: {
                Text(UserText.appTPOnboardingPage1Info3)
            }(),
            auxButtonTitle: nil,
            primaryButtonTitle: UserText.appTPOnboardingContinueButton,
            pictogramName: "AppTPWatching-Blocked"
        ),
        OnboardingStepViewModel(
            title: UserText.appTPOnboardingTitle2,
            paragraph1: {
                Text(UserText.appTPOnboardingPage2Info1)
                + Text(UserText.appTPOnboardingPage2Info2)
                    .fontWeight(.bold)
                + Text(UserText.appTPOnboardingPage2Info3)
            }(),
            paragraph2: {
                Text(UserText.appTPOnboardingPage2Info4)
                    .fontWeight(.bold)
                + Text(UserText.appTPOnboardingPage2Info5)
                + Text(UserText.appTPOnboardingPage2Info6)
                    .fontWeight(.bold)
            }(),
            auxButtonTitle: nil,
            primaryButtonTitle: UserText.appTPOnboardingContinueButton,
            pictogramName: "AppTPRadar"
        ),
        OnboardingStepViewModel(
            title: UserText.appTPOnboardingTitle3,
            paragraph1: {
                Text(UserText.appTPOnboardingPage3Info1)
                    .fontWeight(.bold)
                + Text(UserText.appTPOnboardingPage3Info2)
            }(),
            paragraph2: {
                Text(UserText.appTPOnboardingPage3Info3)
                + Text(UserText.appTPOnboardingPage3Info4)
                    .fontWeight(.bold)
            }(),
            auxButtonTitle: UserText.appTPOnboardingLearnMoreButton,
            primaryButtonTitle: UserText.appTPOnboardingEnableButton,
            pictogramName: "AppTPSwitch"
        )
    ]
}

extension OnboardingStepViewModel: Equatable {
    static func == (lhs: OnboardingStepViewModel, rhs: OnboardingStepViewModel) -> Bool {
        lhs.title == rhs.title
    }
}

#endif
