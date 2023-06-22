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

struct OnboardingStepViewModel {
    let title: String
    let paragraph1: Text
    let paragraph2: Text
    let auxButtonTitle: String?
    let primaryButtonTitle: String
    let pictogramName: String
    
    static let onboardingData: [OnboardingStepViewModel] = [
        OnboardingStepViewModel(
            title: "One easy step for better app privacy!",
            paragraph1: {
                Text("Over 85% of free iOS apps")
                    .fontWeight(.semibold)
                + Text(" we’ve tested allow other companies to track your personal information, even when you’re sleeping.")
            }(),
            paragraph2: {
                Text("See who we catch trying to track you in your apps and take back control.")
            }(),
            auxButtonTitle: nil,
            primaryButtonTitle: "Continue",
            pictogramName: "AppTPWatching-Blocked"
        ),
        OnboardingStepViewModel(
            title: "How does it work?",
            paragraph1: {
                Text("App Tracking Protection ")
                + Text("detects and blocks app trackers from other companies,")
                    .fontWeight(.semibold)
                + Text(" like when Google attempts to track you in a health app.")
            }(),
            paragraph2: {
                Text("It’s free,")
                    .fontWeight(.semibold)
                + Text(" and you can enjoy your apps as you normally would. Working in the background, it helps ")
                + Text("protect you night and day.")
                    .fontWeight(.semibold)
            }(),
            auxButtonTitle: nil,
            primaryButtonTitle: "Continue",
            pictogramName: "AppTPRadar"
        ),
        OnboardingStepViewModel(
            title: "Who sees your data?",
            paragraph1: {
                Text("App Tracking Protection is not a VPN.")
                    .fontWeight(.semibold)
                + Text(" However, your device will recognize it as one. This is because it uses a local VPN connection to work.")
            }(),
            paragraph2: {
                Text("App Tracking Protection is different. ")
                + Text("It never routes app data through an external server.")
                    .fontWeight(.semibold)
            }(),
            auxButtonTitle: "Learn More",
            primaryButtonTitle: "Enable App Tracking Protection",
            pictogramName: "AppTPSwitch"
        )
    ]
}

extension OnboardingStepViewModel: Equatable {
    static func == (lhs: OnboardingStepViewModel, rhs: OnboardingStepViewModel) -> Bool {
        lhs.title == rhs.title
    }
}
