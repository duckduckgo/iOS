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

import Foundation

struct OnboardingStepViewModel: Equatable {
    let title: String
    let paragraph1: String
    let paragraph2: String
    let auxButtonTitle: String?
    let primaryButtonTitle: String
    let pictogramName: String
    
    static let onboardingData: [OnboardingStepViewModel] = [
        OnboardingStepViewModel(
            title: "One easy step for better app privacy!",
            paragraph1: "Over 85% of free iOS apps we’ve tested allow other companies to track your personal information, even when you’re sleeping.",
            paragraph2: "See who we catch trying to track you in your apps and take back control.",
            auxButtonTitle: nil,
            primaryButtonTitle: "Continue",
            pictogramName: "AppTPWatching-Blocked"
        ),
        OnboardingStepViewModel(
            title: "How does it work?",
            paragraph1: "App Tracking Protection detects and blocks app trackers from other companies, like when Google attempts to track you in a health app.",
            paragraph2: "It’s free, and you can enjoy your apps as you normally would. Working in the background, it helps protect you night and day.",
            auxButtonTitle: nil,
            primaryButtonTitle: "Continue",
            pictogramName: "AppTPRadar"
        ),
        OnboardingStepViewModel(
            title: "Who sees your data?",
            paragraph1: "App Tracking Protection is not a VPN. However, your device will recognize it as one. This is because it uses a local VPN connection to work.",
            paragraph2: "App Tracking Protection is different. It never routes app data through an external server.",
            auxButtonTitle: "Learn More",
            primaryButtonTitle: "Enable App Tracking Protection",
            pictogramName: "AppTPSwitch"
        )
    ]
}
