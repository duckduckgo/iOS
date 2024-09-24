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

    private let type: OnboardingGradientType

    init(type: OnboardingGradientType) {
        self.type = type
    }

    var body: some View {
        switch (type, colorScheme) {
        case (.default, .light):
            linearLightGradient
        case (.default, .dark):
            linearDarkGradient
        case (.highlights, _):
            // If highlights experiment use new common gradient for iOS and macOS
            OnboardingGradient()
        @unknown default:
            linearLightGradient
        }
    }

    private var linearLightGradient: some View {
        gradient(colorStops: [
            .init(color: Color(red: 1, green: 0.9, blue: 0.87), location: 0.00),
            .init(color: Color(red: 0.99, green: 0.89, blue: 0.87), location: 0.28),
            .init(color: Color(red: 0.99, green: 0.89, blue: 0.87), location: 0.46),
            .init(color: Color(red: 0.96, green: 0.87, blue: 0.87), location: 0.72),
            .init(color: Color(red: 0.9, green: 0.84, blue: 0.92), location: 1.00),
        ])
    }

    private var linearDarkGradient: some View {
        gradient(colorStops: [
            .init(color: Color(red: 0.29, green: 0.19, blue: 0.25), location: 0.00),
            .init(color: Color(red: 0.35, green: 0.23, blue: 0.32), location: 0.28),
            .init(color: Color(red: 0.37, green: 0.25, blue: 0.38), location: 0.46),
            .init(color: Color(red: 0.2, green: 0.15, blue: 0.32), location: 0.72),
            .init(color: Color(red: 0.16, green: 0.15, blue: 0.34), location: 1.00),
        ])
    }

    private func gradient(colorStops: [SwiftUI.Gradient.Stop]) -> some View {
        LinearGradient(
            stops: colorStops,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }

}

enum OnboardingGradientType {
    case `default`
    case highlights
}
