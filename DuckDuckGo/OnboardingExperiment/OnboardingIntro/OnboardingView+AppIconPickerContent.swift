//
//  OnboardingView+AppIconPickerContent.swift
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
import DuckUI
import Onboarding

extension OnboardingView {

    struct AppIconPickerContentState {
        var animateTitle = true
        var animateMessage = false
        var showContent = false
    }

    struct AppIconPickerContent: View {

        private var animateTitle: Binding<Bool>
        private var animateMessage: Binding<Bool>
        private var showContent: Binding<Bool>
        private let action: () -> Void

        init(
            animateTitle: Binding<Bool> = .constant(true),
            animateMessage: Binding<Bool> = .constant(true),
            showContent: Binding<Bool> = .constant(false),
            action: @escaping () -> Void
        ) {
            self.animateTitle = animateTitle
            self.animateMessage = animateMessage
            self.showContent = showContent
            self.action = action
        }

        var body: some View {
            VStack(spacing: 16.0) {
                AnimatableTypingText(UserText.Onboarding.AppIconSelection.title, startAnimating: animateTitle) {
                    animateMessage.wrappedValue = true
                }
                .foregroundColor(.primary)
                .font(Metrics.titleFont)

                AnimatableTypingText(UserText.Onboarding.AppIconSelection.message, startAnimating: animateMessage) {
                    withAnimation {
                        showContent.wrappedValue = true
                    }
                }
                .foregroundColor(.primary)
                .font(Metrics.messageFont)

                VStack(spacing: 24) {
                    AppIconPicker()

                    Button(action: action) {
                        Text(UserText.Onboarding.AppIconSelection.cta)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .visibility(showContent.wrappedValue ? .visible : .invisible)
            }
        }

    }

}

private enum Metrics {
    static let titleFont = Font.system(size: 20, weight: .semibold)
    static let messageFont = Font.system(size: 16)
}
