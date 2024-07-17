//
//  ContextualOnboardingDialogs.swift
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

import Foundation
import SwiftUI

struct OnboardingTrySearchDialog: View {
    let title = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASearchTitle
    let message = NSAttributedString(string: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASearchMessage)
    let viewModel: OnboardingSearchSuggestionsViewModel

    var body: some View {
        ContextualDaxDialog(
            logoPosition: .top,
            title: title,
            message: message,
            list: viewModel.itemsList,
            listAction: viewModel.listItemPressed)
    }
}

struct OnboardingTryVisitingSiteDialog: View {
    let title = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteTitle
    let message = NSAttributedString(string: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteMessage)

    let logoPosition: DaxDialogLogoPosition
    let viewModel: OnboardingSiteSuggestionsViewModel

    var body: some View {
        ContextualDaxDialog(
            logoPosition: logoPosition,
            title: title,
            message: message,
            list: viewModel.itemsList,
            listAction: viewModel.listItemPressed)
    }
}

struct OnboardingFireButtonDialog: View {
    private let attributedMessage: NSAttributedString = {
        let firstString = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryFireButtonMessage
        let boldString = "Fire Button."
        let attributedString = NSMutableAttributedString(string: firstString)
        let boldFontAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.daxBodyBold()
        ]
        if let boldRange = firstString.range(of: boldString) {
            let nsBoldRange = NSRange(boldRange, in: firstString)
            attributedString.addAttributes(boldFontAttribute, range: nsBoldRange)
        }

        return attributedString
    }()

    var body: some View {
        ContextualDaxDialog(
            message: attributedMessage)
    }
}

struct OnboardingFirstSearchDoneDialog: View {
    let message = NSAttributedString(string: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFirstSearchDoneMessage)
    let cta = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingGotItButton

    @State private var showNextScreen: Bool = false
    @State private var shouldFollowUp: Bool = true

    let viewModel: OnboardingSiteSuggestionsViewModel
    let gotItAction: () -> Void

    var body: some View {
        if showNextScreen {
            OnboardingTryVisitingSiteDialog(logoPosition: .left, viewModel: viewModel)
        } else {
            ContextualDaxDialog(
                message: message,
                cta: cta) {
                    if shouldFollowUp {
                        showNextScreen = true
                    } else {
                        gotItAction()
                    }
            }
        }
    }
}

struct OnboardingTrackersDoneDialog: View {
    let cta = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingGotItButton

    @State private var showNextScreen: Bool = false

    let message: NSAttributedString
    let blockedTrackersCTAAction: () -> Void

    var body: some View {
        if showNextScreen {
            OnboardingFireButtonDialog()
        } else {
            ContextualDaxDialog(
                message: message,
                cta: cta) {
                    showNextScreen = true
                    blockedTrackersCTAAction()
            }
        }
    }
}

struct OnboardingFinalDialog: View {
    let title = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenTitle
    let message = NSAttributedString(string: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenMessage)
    let cta = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenButton
    let imageName = "Success-128"
    
    let highFiveAction: () -> Void

    var body: some View {
        ContextualDaxDialog(
            title: title,
            message: message,
            imageName: imageName,
            cta: cta,
            action: highFiveAction
        )
    }
}

// MARK: - Preview

#Preview("Try Search") {
    OnboardingTrySearchDialog(viewModel: OnboardingSearchSuggestionsViewModel())
        .padding()
}

#Preview("Try Site Top") {
    OnboardingTryVisitingSiteDialog(logoPosition: .top, viewModel: OnboardingSiteSuggestionsViewModel())
        .padding()
}

#Preview("Try Site Left") {
    OnboardingTryVisitingSiteDialog(logoPosition: .left, viewModel: OnboardingSiteSuggestionsViewModel())
        .padding()
}

#Preview("Try Fire Button") {
    OnboardingFireButtonDialog()
        .padding()
}

#Preview("First Search Dialog") {
    OnboardingFirstSearchDoneDialog(viewModel: OnboardingSiteSuggestionsViewModel(), gotItAction: {})
        .padding()
}

#Preview("Final Dialog") {
    OnboardingFinalDialog(highFiveAction: {})
        .padding()
}

#Preview("Trackers Dialog") {
    OnboardingTrackersDoneDialog(
        message: NSAttributedString(string: """
            Heads up! Instagram.com is owned by Facebook.\n\n
            Facebook’s trackers lurk on about 40% of top websites 😱 but don’t worry!\n\n
            I’ll block Facebook from seeing your activity on those sites.
            """
        ),
        blockedTrackersCTAAction: { }
    )
    .padding()
}
