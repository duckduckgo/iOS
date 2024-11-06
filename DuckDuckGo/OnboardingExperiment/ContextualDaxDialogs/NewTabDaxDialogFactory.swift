//
//  NewTabDaxDialogFactory.swift
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

protocol NewTabDaxDialogProvider {
    associatedtype DaxDialog: View
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec, onDismiss: @escaping () -> Void) -> DaxDialog
}

final class NewTabDaxDialogFactory: NewTabDaxDialogProvider {
    private var delegate: OnboardingNavigationDelegate?
    private let contextualOnboardingLogic: ContextualOnboardingLogic
    private let onboardingPixelReporter: OnboardingPixelReporting
    private let onboardingManager: OnboardingHighlightsManaging & OnboardingAddToDockManaging

    private var gradientType: OnboardingGradientType {
        onboardingManager.isOnboardingHighlightsEnabled ? .highlights : .default
    }

    init(
        delegate: OnboardingNavigationDelegate?,
        contextualOnboardingLogic: ContextualOnboardingLogic,
        onboardingPixelReporter: OnboardingPixelReporting,
        onboardingManager: OnboardingHighlightsManaging & OnboardingAddToDockManaging = OnboardingManager()
    ) {
        self.delegate = delegate
        self.contextualOnboardingLogic = contextualOnboardingLogic
        self.onboardingPixelReporter = onboardingPixelReporter
        self.onboardingManager = onboardingManager
    }

    @ViewBuilder
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec, onDismiss: @escaping () -> Void) -> some View {
        switch homeDialog {
        case .initial:
            createInitialDialog()
        case .addFavorite:
            createAddFavoriteDialog(message: homeDialog.message)
        case .subsequent:
            createSubsequentDialog()
        case .final:
            createFinalDialog(onDismiss: onDismiss)
        default:
            EmptyView()
        }
    }

    private func createInitialDialog() -> some View {
        let viewModel = OnboardingSearchSuggestionsViewModel(suggestedSearchesProvider: OnboardingSuggestedSearchesProvider(), delegate: delegate, pixelReporter: onboardingPixelReporter)
        let message = onboardingManager.isOnboardingHighlightsEnabled ? UserText.HighlightsOnboardingExperiment.ContextualOnboarding.onboardingTryASearchMessage : UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASearchMessage
        return FadeInView {
            OnboardingTrySearchDialog(message: message, viewModel: viewModel)
                .onboardingDaxDialogStyle()
        }
        .onboardingContextualBackgroundStyle(background: .illustratedGradient(gradientType))
        .onFirstAppear { [weak self] in
            self?.onboardingPixelReporter.trackScreenImpression(event: .onboardingContextualTrySearchUnique)
        }
    }

    private func createSubsequentDialog() -> some View {
        let viewModel = OnboardingSiteSuggestionsViewModel(title: UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingTryASiteNTPTitle, suggestedSitesProvider: OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.DaxOnboardingExperiment.ContextualOnboarding.tryASearchOptionSurpriseMeTitle), delegate: delegate, pixelReporter: onboardingPixelReporter)
        return FadeInView {
            OnboardingTryVisitingSiteDialog(logoPosition: .top, viewModel: viewModel)
                .onboardingDaxDialogStyle()
        }
        .onboardingContextualBackgroundStyle(background: .illustratedGradient(gradientType))
        .onFirstAppear { [weak self] in
            self?.onboardingPixelReporter.trackScreenImpression(event: .onboardingContextualTryVisitSiteUnique)
        }
    }

    private func createAddFavoriteDialog(message: String) -> some View {
        FadeInView {
            DaxDialogView(logoPosition: .top) {
                ContextualDaxDialogContent(message: NSAttributedString(string: message))
            }
            .padding()
        }
    }

    private func createFinalDialog(onDismiss: @escaping () -> Void) -> some View {
        let shouldShowAddToDock = onboardingManager.addToDockEnabledState == .contextual

        let (message, cta) = if shouldShowAddToDock {
            (UserText.AddToDockOnboarding.EndOfJourney.message, UserText.AddToDockOnboarding.Buttons.dismiss)
        } else {
            (
                onboardingManager.isOnboardingHighlightsEnabled ?  UserText.HighlightsOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenMessage : UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenMessage,
                UserText.DaxOnboardingExperiment.ContextualOnboarding.onboardingFinalScreenButton
            )
        }

        let showAddToDockTutorialAction: () -> Void = { [weak self] in
            self?.onboardingPixelReporter.trackAddToDockPromoShowTutorialCTAAction()
        }

        let dismissAction = { [weak self] isDismissedFromAddToDockTutorial in
            if isDismissedFromAddToDockTutorial {
                self?.onboardingPixelReporter.trackAddToDockTutorialDismissCTAAction()
            } else {
                self?.onboardingPixelReporter.trackEndOfJourneyDialogCTAAction()
                if shouldShowAddToDock {
                    self?.onboardingPixelReporter.trackAddToDockPromoDismissCTAAction()
                }
            }
            onDismiss()
        }

        return FadeInView {
            OnboardingFinalDialog(
                logoPosition: .top,
                message: message,
                cta: cta,
                canShowAddToDockTutorial: shouldShowAddToDock,
                showAddToDockTutorialAction: showAddToDockTutorialAction,
                dismissAction: dismissAction
            )
        }
        .onboardingContextualBackgroundStyle(background: .illustratedGradient(gradientType))
        .onFirstAppear { [weak self] in
            self?.contextualOnboardingLogic.setFinalOnboardingDialogSeen()
            self?.onboardingPixelReporter.trackScreenImpression(event: .daxDialogsEndOfJourneyNewTabUnique)
            if shouldShowAddToDock {
                self?.onboardingPixelReporter.trackAddToDockPromoImpression()
            }
        }
    }
}

struct FadeInView<Content: View>: View {
    var content: Content
    @State private var opacity: Double = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) {
                    opacity = 1.0
                }
            }
    }
}
