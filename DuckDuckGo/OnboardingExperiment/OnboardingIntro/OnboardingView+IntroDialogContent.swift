//
//  OnboardingView+IntroDialogContent.swift
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

    struct IntroDialogContent: View {

        private let title: String
        private var animateText: Binding<Bool>
        private var showCTA: Binding<Bool>
        private let action: () -> Void

        init(title: String, animateText: Binding<Bool> = .constant(true), showCTA: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
            self.title = title
            self.animateText = animateText
            self.showCTA = showCTA
            self.action = action
        }

        var body: some View {
            VStack(spacing: 24.0) {
                AnimatableTypingText(title, startAnimating: animateText) {
                    withAnimation {
                        showCTA.wrappedValue = true
                    }
                }
                .foregroundColor(.primary)
                .font(Font.system(size: 20, weight: .bold))

                Button(action: action) {
                    Text(UserText.Onboarding.Intro.cta)
                }
                .buttonStyle(PrimaryButtonStyle())
                .visibility(showCTA.wrappedValue ? .visible : .invisible)
            }
        }
    }

}
