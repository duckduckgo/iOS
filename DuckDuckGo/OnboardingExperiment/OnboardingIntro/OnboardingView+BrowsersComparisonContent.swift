//
//  OnboardingView+BrowsersComparisonContent.swift
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

    struct BrowsersComparisonContent: View {

        private let title: String
        private var animateText: Binding<Bool>
        private var showContent: Binding<Bool>
        private let setAsDefaultBrowserAction: () -> Void
        private let cancelAction: () -> Void

        init(
            title: String,
            animateText: Binding<Bool> = .constant(true),
            showContent: Binding<Bool> = .constant(false),
            setAsDefaultBrowserAction: @escaping () -> Void,
            cancelAction: @escaping () -> Void
        ) {
            self.title = title
            self.animateText = animateText
            self.showContent = showContent
            self.setAsDefaultBrowserAction = setAsDefaultBrowserAction
            self.cancelAction = cancelAction
        }

        var body: some View {
            VStack(spacing: 16.0) {
                AnimatableTypingText(title, startAnimating: animateText) {
                    withAnimation {
                        showContent.wrappedValue = true
                    }
                }
                .foregroundColor(.primary)
                .font(Font.system(size: 20, weight: .bold))


                VStack(spacing: 24) {
                    BrowsersComparisonChart(privacyFeatures: BrowsersComparisonModel.privacyFeatures)

                    OnboardingActions(
                        viewModel: .init(
                            primaryButtonTitle: UserText.Onboarding.BrowsersComparison.cta,
                            secondaryButtonTitle: UserText.onboardingSkip
                        ),
                        primaryAction: setAsDefaultBrowserAction,
                        secondaryAction: cancelAction
                    )

                }
                .visibility(showContent.wrappedValue ? .visible : .invisible)
            }
        }

    }

}
