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

    var body: some View {
        DaxDialogView(logoPosition: .top) {
                DaxAnimatableContent(
                    verticalSpacing: 24.0,
                    title: UserText.DaxOnboardingExperiment.Intro.title + "\n\n" + UserText.DaxOnboardingExperiment.Intro.message,
                    items: [
                        AnyView(
                            Button(action: action) {
                                Text(UserText.DaxOnboardingExperiment.Intro.cta)
                            }
                                .buttonStyle(PrimaryButtonStyle())
                        ),
                        AnyView(
                            Button(action: action) {
                                Text(UserText.DaxOnboardingExperiment.Intro.cta)
                            }
                                .buttonStyle(PrimaryButtonStyle())
                        ),
                    ]
                )
//                Group {
//                    AnimatableText(UserText.DaxOnboardingExperiment.Intro.title)
//
//                    AnimatableText(UserText.DaxOnboardingExperiment.Intro.message) {
//                        withAnimation {
//                            showButton = true
//                        }
//                    }
//                }
//                .foregroundColor(.primary)
//                .font(Font.system(size: 20, weight: .bold))

//                Button(action: action) {
//                    Text(UserText.DaxOnboardingExperiment.Intro.cta)
//                }
//                .buttonStyle(PrimaryButtonStyle())
//                .visibility(showButton ? .visible : .invisible)
            }
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

struct DaxAnimatableContent: View {
    private let title: String
    private let items: [AnyView]
    private let verticalSpacing: CGFloat
    private let animationDuration: TimeInterval

    @State private var isDisplayingBody = false
    @State private var requestedStopAnimating = false
    @State private var opacity: CGFloat = 0.0

    init(
        verticalSpacing: CGFloat,
        title: String,
        items: [AnyView],
        animationDuration: TimeInterval = 1.0
    ) {
        self.verticalSpacing = verticalSpacing
        self.title = title
        self.items = items
        self.animationDuration = animationDuration
    }

    var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            AnimatableText(title, typingDisabled: requestedStopAnimating) {
                withAnimation {
                    isDisplayingBody = true
                }
            }
            .foregroundColor(.primary)
            .font(Font.system(size: 20, weight: .bold))

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                item
                    //.visibility(isDisplayingBody ? .visible : .invisible)
                    .opacity(opacity)
                    .animation(requestedStopAnimating ? nil : .default.delay(Double(index) * animationDuration))
            }
        }
        .onTapGesture {
            withAnimation {
                requestedStopAnimating = true
                opacity = 1.0
            }
        }
    }

}

struct SequentialAnimatableContent: View {
    private let items: [AnyView]
    private let animationDuration: TimeInterval

    @State var isDisplayingContent = false

    init(items: [AnyView], animationDuration: TimeInterval = 0.3) {
        self.items = items
        self.animationDuration = animationDuration
    }

    var body: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            item
//                .visibility(isDisplayingContent ? .visible : .invisible)
                .opacity(isDisplayingContent ? 1 : 0)
                .animation(.default.delay(Double(index) * animationDuration))
        }
    }

}
