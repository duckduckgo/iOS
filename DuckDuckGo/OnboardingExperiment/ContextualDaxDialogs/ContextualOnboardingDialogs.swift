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
import Onboarding
import DuckUI

struct OnboardingTrySearchDialog: View {
    let title = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASearchTitle
    let message: String
    let viewModel: OnboardingSearchSuggestionsViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: .top) {
                ContextualDaxDialogContent(
                    title: title,
                    titleFont: Font(UIFont.daxTitle3()),
                    message: NSAttributedString(string: message),
                    list: viewModel.itemsList,
                    listAction: viewModel.listItemPressed
                )
            }
            .padding()
        }
    }
}

struct OnboardingTryVisitingSiteDialog: View {
    let logoPosition: DaxDialogLogoPosition
    let viewModel: OnboardingSiteSuggestionsViewModel

    var body: some View {
        ScrollView(.vertical) {
            DaxDialogView(logoPosition: logoPosition) {
                OnboardingTryVisitingSiteDialogContent(viewModel: viewModel)
            }
            .padding()
        }
    }
}

struct OnboardingTryVisitingSiteDialogContent: View {
    let message = NSAttributedString(string: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteMessage)

    let viewModel: OnboardingSiteSuggestionsViewModel

    var body: some View {
        ContextualDaxDialogContent(
            title: viewModel.title,
            titleFont: Font(UIFont.daxTitle3()),
            message: message,
            list: viewModel.itemsList,
            listAction: viewModel.listItemPressed)
    }
}

struct OnboardingFireButtonDialogContent: View {
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
        ContextualDaxDialogContent(
            message: attributedMessage)
    }
}

struct OnboardingFirstSearchDoneDialog: View {
    let cta = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingGotItButton
    let message: NSAttributedString

    @State private var showNextScreen: Bool = false

    let shouldFollowUp: Bool
    let viewModel: OnboardingSiteSuggestionsViewModel
    let gotItAction: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: .left) {
                VStack {
                    if showNextScreen {
                        OnboardingTryVisitingSiteDialogContent(viewModel: viewModel)
                    } else {
                        ContextualDaxDialogContent(
                            message: message,
                            customActionView: AnyView(
                                OnboardingCTAButton(title: cta) {
                                    gotItAction()
                                    withAnimation {
                                        if shouldFollowUp {
                                            showNextScreen = true
                                        }
                                    }
                                }
                            )
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct OnboardingFireDialog: View {
   
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: .left) {
                VStack {
                    OnboardingFireButtonDialogContent()
                }
            }
            .padding()
        }
    }
}

struct OnboardingTrackersDoneDialog: View {
    let cta = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingGotItButton

    @State private var showNextScreen: Bool = false

    let shouldFollowUp: Bool
    let message: NSAttributedString
    let blockedTrackersCTAAction: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: .left) {
                VStack {
                    if showNextScreen {
                        OnboardingFireButtonDialogContent()
                    } else {
                        ContextualDaxDialogContent(
                            message: message,
                            customActionView: AnyView(
                                OnboardingCTAButton(title: cta) {
                                    blockedTrackersCTAAction()
                                    if shouldFollowUp {
                                        withAnimation {
                                            showNextScreen = true
                                        }
                                    }
                                }
                            )
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct OnboardingFinalDialog: View {
    let title = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenTitle
    let message: String
    let cta = UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenButton
    
    let highFiveAction: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: .left) {
                ContextualDaxDialogContent(
                    title: title,
                    titleFont: Font(UIFont.daxTitle3()),
                    message: NSAttributedString(string: message),
                    customActionView: AnyView(
                        OnboardingCTAButton(
                            title: cta,
                            action: highFiveAction
                        )
                    )
                )
            }
            .padding()
        }
    }
}

struct OnboardingCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(PrimaryButtonStyle(compact: true))
    }

}

// MARK: - Preview

#Preview("Try Search") {
    OnboardingTrySearchDialog(message: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASearchMessage, viewModel: OnboardingSearchSuggestionsViewModel(suggestedSearchesProvider: OnboardingSuggestedSearchesProvider(), pixelReporter: OnboardingPixelReporter()))
        .padding()
}

#Preview("Try Site Top") {
    OnboardingTryVisitingSiteDialog(logoPosition: .top, viewModel: OnboardingSiteSuggestionsViewModel(title: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), pixelReporter: OnboardingPixelReporter()))
        .padding()
}

#Preview("Try Site Left") {
    OnboardingTryVisitingSiteDialog(logoPosition: .left, viewModel: OnboardingSiteSuggestionsViewModel(title: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), pixelReporter: OnboardingPixelReporter()))
        .padding()
}

#Preview("Try Fire Button") {
    DaxDialogView(logoPosition: .left) {
        OnboardingFireButtonDialogContent()
    }
        .padding()
}

#Preview("First Search Dialog") {
    OnboardingFirstSearchDoneDialog(message: NSAttributedString(string: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFirstSearchDoneMessage), shouldFollowUp: true, viewModel: OnboardingSiteSuggestionsViewModel(title: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), pixelReporter: OnboardingPixelReporter()), gotItAction: {})
        .padding()
}

#Preview("Final Dialog") {
    OnboardingFinalDialog(message: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenMessage, highFiveAction: {})
        .padding()
}

#Preview("Trackers Dialog") {
    OnboardingTrackersDoneDialog(
        shouldFollowUp: true,
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
