//
//  DaxDialogStyles.swift
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

extension OnboardingStyles {

    struct DaxDialogStyle: ViewModifier {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass

        func body(content: Content) -> some View {
            content
                .frame(maxWidth: Metrics.daxDialogMaxWidth.build(v: verticalSizeClass, h: horizontalSizeClass))
        }

    }

    struct BackgroundStyle: ViewModifier {
        let backgroundType: OnboardingBackgroundType

        func body(content: Content) -> some View {
            ZStack {
                switch backgroundType {
                case .illustratedGradient:
                    OnboardingBackground()
                        .ignoresSafeArea(.keyboard)
                case .gradientOnly:
                    OnboardingGradientView()
                        .ignoresSafeArea(.keyboard)
                }

                content
            }
        }
    }

}

private enum Metrics {
    static let daxDialogMaxWidth = MetricBuilder<CGFloat?>(iPhone: nil, iPad: 480)
}

extension View {

    func onboardingDaxDialogStyle() -> some View {
        modifier(OnboardingStyles.DaxDialogStyle())
    }

    func onboardingContextualBackgroundStyle(background: OnboardingBackgroundType) -> some View {
        modifier(OnboardingStyles.BackgroundStyle(backgroundType: background))
    }
    
}

enum OnboardingBackgroundType {
    case illustratedGradient
    case gradientOnly
}
