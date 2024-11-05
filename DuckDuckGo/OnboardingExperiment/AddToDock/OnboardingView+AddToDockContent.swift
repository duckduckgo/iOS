//
//  OnboardingView+AddToDockContent.swift
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

extension OnboardingView {

    struct AddToDockPromoContentState {
        var animateTitle = true
        var animateMessage = false
        var showContent = false
    }

    struct AddToDockPromoContent: View {

        @State private var showAddToDockTutorial = false

        private var animateTitle: Binding<Bool>
        private var animateMessage: Binding<Bool>
        private var showContent: Binding<Bool>
        private let dismissAction: (_ fromAddToDock: Bool) -> Void

        init(
            animateTitle: Binding<Bool> = .constant(true),
            animateMessage: Binding<Bool> = .constant(true),
            showContent: Binding<Bool> = .constant(false),
            dismissAction: @escaping (_ fromAddToDock: Bool) -> Void
        ) {
            self.animateTitle = animateTitle
            self.animateMessage = animateMessage
            self.showContent = showContent
            self.dismissAction = dismissAction
        }

        var body: some View {
            if showAddToDockTutorial {
                OnboardingAddToDockTutorialContent(cta: UserText.AddToDockOnboarding.Intro.tutorialDismissCTA) {
                    dismissAction(true)
                }
            } else {
                ContextualDaxDialogContent(
                    title: UserText.AddToDockOnboarding.Intro.title,
                    titleFont: Font(UIFont.daxTitle3()),
                    message: NSAttributedString(string: UserText.AddToDockOnboarding.Intro.message),
                    messageFont: Font.system(size: 16),
                    customView: AnyView(addToDockPromoView),
                    customActionView: AnyView(customActionView)
                )
            }
        }

        private var addToDockPromoView: some View {
            AddToDockPromoView()
                .aspectRatio(contentMode: .fit)
                .padding(.vertical)
        }

        private var customActionView: some View {
            VStack {
                OnboardingCTAButton(
                    title: UserText.AddToDockOnboarding.Buttons.addToDockTutorial,
                    action: {
                        showAddToDockTutorial = true
                    }
                )

                OnboardingCTAButton(
                    title: UserText.AddToDockOnboarding.Intro.skipCTA,
                    buttonStyle: .ghost,
                    action: {
                        dismissAction(false)
                    }
                )
            }
        }

    }

}
