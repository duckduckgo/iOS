//
//  ContextualDaxDialogsFactory.swift
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

// MARK: - ContextualOnboardingEventDelegate

/// A delegate to inform about specific events happening during the contextual onboarding.
protocol ContextualOnboardingEventDelegate: AnyObject {
    /// Inform the delegate that a dialog for blocked trackers have been shown to the user.
    func didShowContextualOnboardingTrackersDialog()
    /// Inform the delegate that the user did acknowledge the dialog for blocked trackers.
    func didAcknowledgeContextualOnboardingTrackersDialog()
    /// Inform the delegate that the user dismissed the contextual dialog.
    func didTapDismissContextualOnboardingAction()
}

// Composed delegate for Contextual Onboarding to decorate events also needed in New Tab Page.
typealias ContextualOnboardingDelegate = OnboardingNavigationDelegate & ContextualOnboardingEventDelegate

// MARK: - Contextual Dialogs Factory

protocol ContextualDaxDialogsFactory {
    func makeView(for spec: DaxDialogs.BrowsingSpec, delegate: ContextualOnboardingDelegate) -> UIViewController
}

final class ExperimentContextualDaxDialogsFactory: ContextualDaxDialogsFactory {

    func makeView(for spec: DaxDialogs.BrowsingSpec, delegate: ContextualOnboardingDelegate) -> UIViewController {
        let rootView: AnyView
        switch spec.type {
        case .afterSearch:
            rootView = AnyView(afterSearchDialog(shouldFollowUpToWebsiteSearch: false, delegate: delegate))
        case .afterSearchWithWebsitesFollowUp:
            rootView = AnyView(afterSearchDialog(shouldFollowUpToWebsiteSearch: true, delegate: delegate))
        case .siteIsMajorTracker, .siteOwnedByMajorTracker, .withMultipleTrackers, .withOneTracker, .withoutTrackers:
            rootView = AnyView(withTrackersDialog(for: spec, delegate: delegate))
        case .final:
            rootView = AnyView(endOfJourneyDialog(delegate: delegate))
        }

        let viewWithBackground = rootView.withOnboardingBackground()
        let hostingController = UIHostingController(rootView: viewWithBackground)
        if #available(iOS 16.0, *) {
            hostingController.sizingOptions = [.intrinsicContentSize]
        }

        return hostingController
    }

    private func afterSearchDialog(shouldFollowUpToWebsiteSearch: Bool, delegate: ContextualOnboardingDelegate) -> some View {
        let viewModel = OnboardingSiteSuggestionsViewModel(delegate: delegate)
        // If should not show websites search after searching inform the delegate that the user dimissed the dialog, otherwise let the dialog handle it.
        let gotItAction: () -> Void = if shouldFollowUpToWebsiteSearch { {} } else { { [weak delegate] in delegate?.didTapDismissContextualOnboardingAction() } }
        return OnboardingFirstSearchDoneDialog(shouldFollowUp: shouldFollowUpToWebsiteSearch, viewModel: viewModel, gotItAction: gotItAction)
    }

    private func withTrackersDialog(for spec: DaxDialogs.BrowsingSpec, delegate: ContextualOnboardingDelegate) -> some View {
        let attributedMessage = spec.message.attributedStringFromMarkdown(color: ThemeManager.shared.currentTheme.daxDialogTextColor)
        return OnboardingTrackersDoneDialog(message: attributedMessage, blockedTrackersCTAAction: { [weak delegate] in
            delegate?.didAcknowledgeContextualOnboardingTrackersDialog()
        })
        .onAppear { [weak delegate] in
            delegate?.didShowContextualOnboardingTrackersDialog()
        }
    }

    private func endOfJourneyDialog(delegate: ContextualOnboardingDelegate) -> some View {
        OnboardingFinalDialog(highFiveAction: { [weak delegate] in
            delegate?.didTapDismissContextualOnboardingAction()
        })
    }

}

// MARK: - View + Onboarding Bacgkround

private extension View {

    func withOnboardingBackground() -> some View {
        self
            .padding()
            .background(OnboardingBackground())
    }

}
