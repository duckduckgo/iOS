//
//  DaxDialogIntroView.swift
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

struct DaxDialogIntroView: View {

    let action: () -> Void

    @State private var showButton = false
    @State private var animateText = true

    var body: some View {
        DaxDialogView(
            logoPosition: .top,
            onTapGesture: {
                withAnimation {
                    showButton = true
                    animateText = false
                }
            },
            content: {
                VStack(spacing: 24.0) {
                    let attString = NSAttributedString(string: UserText.DaxOnboardingExperiment.Intro.title)
                    AnimatableTypingText(attString, startAnimating: $animateText) {
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
        )
    }
}

// MARK: - Preview

#Preview("Intro Dialog - Light Mode") {
    DaxDialogIntroView(action: {})
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Intro Dialog - Dark Mode") {
    DaxDialogIntroView(action: {})
        .padding()
        .preferredColorScheme(.dark)
}
