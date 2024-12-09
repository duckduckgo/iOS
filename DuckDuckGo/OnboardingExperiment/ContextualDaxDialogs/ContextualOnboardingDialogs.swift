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
    let title = UserText.Onboarding.ContextualOnboarding.onboardingTryASearchTitle
    let message: String
    let viewModel: OnboardingSearchSuggestionsViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: .top) {
                ContextualDaxDialogContent(
                    title: title,
                    titleFont: Font(UIFont.daxTitle3()),
                    message: NSAttributedString(string: message),
                    messageFont: Font.system(size: 16),
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
    let message = NSAttributedString(string: UserText.Onboarding.ContextualOnboarding.onboardingTryASiteMessage)

    let viewModel: OnboardingSiteSuggestionsViewModel

    var body: some View {
        ContextualDaxDialogContent(
            title: viewModel.title,
            titleFont: Font(UIFont.daxTitle3()),
            message: message,
            messageFont: Font.system(size: 16),
            list: viewModel.itemsList,
            listAction: viewModel.listItemPressed)
    }
}

struct OnboardingFireButtonDialogContent: View {
    private let attributedMessage: NSAttributedString = {
        let firstString = UserText.Onboarding.ContextualOnboarding.onboardingTryFireButtonMessage
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
            message: attributedMessage,
            messageFont: Font.system(size: 16)
        )
    }
}

struct OnboardingFirstSearchDoneDialog: View {
    let cta = UserText.Onboarding.ContextualOnboarding.onboardingGotItButton
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
                            messageFont: Font.system(size: 16),
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
    let cta = UserText.Onboarding.ContextualOnboarding.onboardingGotItButton

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
                            messageFont: Font.system(size: 16),
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
    let logoPosition: DaxDialogLogoPosition
    let message: String
    let cta: String
    let canShowAddToDockTutorial: Bool
    let showAddToDockTutorialAction: () -> Void
    let dismissAction: (_ fromAddToDock: Bool) -> Void

    @State private var showAddToDockTutorial = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            DaxDialogView(logoPosition: logoPosition) {
                if showAddToDockTutorial {
                    OnboardingAddToDockTutorialContent(cta: UserText.AddToDockOnboarding.Buttons.startBrowsing) {
                        dismissAction(true)
                    }
                } else {
                    ContextualDaxDialogContent(
                        title: canShowAddToDockTutorial ? UserText.AddToDockOnboarding.Promo.title : UserText.Onboarding.ContextualOnboarding.onboardingFinalScreenTitle,
                        titleFont: Font(UIFont.daxTitle3()),
                        message: NSAttributedString(string: message),
                        messageFont: Font.system(size: 16),
                        customView: AnyView(customView),
                        customActionView: AnyView(customActionView)
                    )
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var customView: some View {
        if canShowAddToDockTutorial {
            AddToDockPromoView()
                .aspectRatio(contentMode: .fill)
                .padding(.vertical)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var customActionView: some View {
        VStack {
            if canShowAddToDockTutorial {
                OnboardingCTAButton(
                    title: UserText.AddToDockOnboarding.Buttons.tutorial,
                    action: {
                        showAddToDockTutorialAction()
                        showAddToDockTutorial = true
                    }
                )
            }
            OnboardingCTAButton(
                title: cta,
                buttonStyle: canShowAddToDockTutorial ? .ghost : .primary,
                action: {
                    dismissAction(false)
                }
            )
        }
    }
}

struct OnboardingCTAButton: View {
    enum ButtonStyle {
        case primary
        case ghost
    }

    let title: String
    var buttonStyle: ButtonStyle = .primary
    let action: () -> Void


    var body: some View {
        let button = Button(action: action) {
            Text(title)
        }

        switch buttonStyle {
        case .primary:
            button.buttonStyle(PrimaryButtonStyle(compact: true))
        case .ghost:
            button.buttonStyle(GhostButtonStyle())
        }
    }

}

struct OnboardingAddToDockTutorialContent: View {
    let title = UserText.AddToDockOnboarding.Tutorial.title
    let message = UserText.AddToDockOnboarding.Tutorial.message

    let cta: String
    let dismissAction: () -> Void

    var body: some View {
        AddToDockTutorialView(
            title: title,
            message: message,
            cta: cta,
            action: dismissAction
        )
    }
}

// MARK: - Preview

#Preview("Try Search") {
    OnboardingTrySearchDialog(message: UserText.Onboarding.ContextualOnboarding.onboardingTryASearchMessage, viewModel: OnboardingSearchSuggestionsViewModel(suggestedSearchesProvider: OnboardingSuggestedSearchesProvider(), pixelReporter: OnboardingPixelReporter()))
        .padding()
}

#Preview("Try Site Top") {
    OnboardingTryVisitingSiteDialog(logoPosition: .top, viewModel: OnboardingSiteSuggestionsViewModel(title: UserText.Onboarding.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.Onboarding.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), pixelReporter: OnboardingPixelReporter()))
        .padding()
}

#Preview("Try Site Left") {
    OnboardingTryVisitingSiteDialog(logoPosition: .left, viewModel: OnboardingSiteSuggestionsViewModel(title: UserText.Onboarding.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.Onboarding.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), pixelReporter: OnboardingPixelReporter()))
        .padding()
}

#Preview("Try Fire Button") {
    DaxDialogView(logoPosition: .left) {
        OnboardingFireButtonDialogContent()
    }
        .padding()
}

#Preview("First Search Dialog") {
    let attributedMessage = {
        let message = UserText.Onboarding.ContextualOnboarding.onboardingFirstSearchDoneMessage
        let boldRange = message.range(of: "DuckDuckGo Search")
        return message.attributed.with(attribute: .font, value: UIFont.daxBodyBold(), in: boldRange)
    }()

    return OnboardingFirstSearchDoneDialog(message: attributedMessage, shouldFollowUp: true, viewModel: OnboardingSiteSuggestionsViewModel(title: UserText.Onboarding.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.Onboarding.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), pixelReporter: OnboardingPixelReporter()), gotItAction: {})
        .padding()
}

#Preview("Final Dialog - No Add to Dock Tutorial") {
    OnboardingFinalDialog(
        logoPosition: .top,
        message: UserText.Onboarding.ContextualOnboarding.onboardingFinalScreenMessage,
        cta: UserText.Onboarding.ContextualOnboarding.onboardingFinalScreenButton,
        canShowAddToDockTutorial: false,
        showAddToDockTutorialAction: {},
        dismissAction: { _ in }
    )
    .padding()
}

#Preview("Final Dialog - Add to Dock Tutorial") {
    OnboardingFinalDialog(
        logoPosition: .left,
        message: UserText.AddToDockOnboarding.Promo.contextualMessage,
        cta: UserText.AddToDockOnboarding.Buttons.startBrowsing,
        canShowAddToDockTutorial: true,
        showAddToDockTutorialAction: {},
        dismissAction: { _ in }
    )
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

#Preview("Add To Dock Tutorial - Light") {
    OnboardingAddToDockTutorialContent(cta: UserText.AddToDockOnboarding.Buttons.startBrowsing, dismissAction: {})
        .preferredColorScheme(.light)
}

#Preview("Add To Dock Tutorial - Dark") {
    OnboardingAddToDockTutorialContent(cta: UserText.AddToDockOnboarding.Buttons.startBrowsing, dismissAction: {})
        .preferredColorScheme(.dark)
}
