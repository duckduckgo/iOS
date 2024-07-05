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

extension OnboardingView {

    struct IntroDialogContent: View {

        private var animateText: Binding<Bool>
        private let action: () -> Void

        @State private var showButton = false

        init(animateText: Binding<Bool> = .constant(true), action: @escaping () -> Void) {
            self.animateText = animateText
            self.action = action
        }

        var body: some View {
            VStack(spacing: 24.0) {
                AnimatableTypingText(UserText.DaxOnboardingExperiment.Intro.title, startAnimating: animateText) {
                    withAnimation {
                        showButton = true
                    }
                }
                .foregroundColor(.primary)
                .font(Font.system(size: 20, weight: .bold))

                Button(action: action) {
                    Text(UserText.DaxOnboardingExperiment.Intro.cta)
                }
                .buttonStyle(PrimaryButtonStyle())
                .visibility(showButton ? .visible : .invisible)
            }
        }
    }

}
