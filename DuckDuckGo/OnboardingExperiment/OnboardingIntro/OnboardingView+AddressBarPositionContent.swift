//
//  OnboardingView+AddressBarPositionContent.swift
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

private enum Metrics {
    static let titleFont = Font.system(size: 20, weight: .semibold)
}

extension OnboardingView {

    struct AddressBarPositionContentState {
        var animateTitle = true
        var showContent = false
    }

    struct AddressBarPositionContent: View {

        private var animateTitle: Binding<Bool>
        private var showContent: Binding<Bool>
        private let action: () -> Void

        init(
            animateTitle: Binding<Bool> = .constant(true),
            showContent: Binding<Bool> = .constant(true),
            action: @escaping () -> Void
        ) {
            self.animateTitle = animateTitle
            self.showContent = showContent
            self.action = action
        }

        var body: some View {
            VStack(spacing: 16.0) {
                AnimatableTypingText(UserText.Onboarding.AddressBarPosition.title, startAnimating: animateTitle) {
                    showContent.wrappedValue = true
                }
                .foregroundColor(.primary)
                .font(Metrics.titleFont)

                VStack(spacing: 24) {
                    OnboardingAddressBarPositionPicker()

                    Button(action: action) {
                        Text(verbatim: UserText.Onboarding.AddressBarPosition.cta)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .visibility(showContent.wrappedValue ? .visible : .invisible)
            }
        }
    }

}

// MARK: - Preview

#Preview {
    OnboardingView.AddressBarPositionContent(action: {})
}
