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

        func body(content: Content) -> some View {
            ZStack {
                OnboardingBackground()
                    .ignoresSafeArea(.keyboard)

                content
            }
        }
        
    }

    struct ListButtonStyle: ButtonStyle {
        @Environment(\.colorScheme) private var colorScheme

        public init() {}

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Font(UIFont.boldAppFont(ofSize: 15)))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .foregroundColor(foregroundColor(configuration.isPressed))
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 40)
                .background(backgroundColor(configuration.isPressed))
                .cornerRadius(8)
                .contentShape(Rectangle()) // Makes whole button area tappable, when there's no background
        }

        private func foregroundColor(_ isPressed: Bool) -> Color {
            switch (colorScheme, isPressed) {
            case (.dark, false):
                return .blue30
            case (.dark, true):
                return .blue20
            case (_, false):
                return .blueBase
            case (_, true):
                return .blue70
            }
        }

        private func backgroundColor(_ isPressed: Bool) -> Color {
            switch (colorScheme, isPressed) {
            case (.light, true):
                return .blueBase.opacity(0.2)
            case (.dark, true):
                return .blue30.opacity(0.2)
            default:
                return .clear
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

    func onboardingContextualBackgroundStyle() -> some View {
        modifier(OnboardingStyles.BackgroundStyle())
    }
    
}
