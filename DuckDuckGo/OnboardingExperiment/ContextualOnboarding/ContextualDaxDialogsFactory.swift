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
import Core
import Onboarding

// MARK: - ContextualOnboardingEventDelegate

/// A delegate to inform about specific events happening during the contextual onboarding.
protocol ContextualOnboardingEventDelegate: AnyObject {
    func didAcknowledgeContextualOnboardingSearch()
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
    func makeView(for spec: DaxDialogs.BrowsingSpec, delegate: ContextualOnboardingDelegate, onSizeUpdate: @escaping () -> Void) -> UIHostingController<AnyView>
}

final class ExperimentContextualDaxDialogsFactory: ContextualDaxDialogsFactory {
    private let contextualOnboardingLogic: ContextualOnboardingLogic
    private let contextualOnboardingSettings: ContextualOnboardingSettings
    private let contextualOnboardingPixelReporter: OnboardingPixelReporting
    private let contextualOnboardingSiteSuggestionsProvider: OnboardingSuggestionsItemsProviding
    private let onboardingManager: OnboardingAddToDockManaging

    init(
        contextualOnboardingLogic: ContextualOnboardingLogic,
        contextualOnboardingSettings: ContextualOnboardingSettings = DefaultDaxDialogsSettings(),
        contextualOnboardingPixelReporter: OnboardingPixelReporting,
        contextualOnboardingSiteSuggestionsProvider: OnboardingSuggestionsItemsProviding = OnboardingSuggestedSitesProvider(surpriseItemTitle: UserText.Onboarding.ContextualOnboarding.tryASearchOptionSurpriseMeTitle),
        onboardingManager: OnboardingAddToDockManaging = OnboardingManager()
    ) {
        self.contextualOnboardingSettings = contextualOnboardingSettings
        self.contextualOnboardingLogic = contextualOnboardingLogic
        self.contextualOnboardingPixelReporter = contextualOnboardingPixelReporter
        self.contextualOnboardingSiteSuggestionsProvider = contextualOnboardingSiteSuggestionsProvider
        self.onboardingManager = onboardingManager
    }

    func makeView(for spec: DaxDialogs.BrowsingSpec, delegate: ContextualOnboardingDelegate, onSizeUpdate: @escaping () -> Void) -> UIHostingController<AnyView> {
        let rootView: AnyView
        switch spec.type {
        case .afterSearch:
            rootView = AnyView(
                afterSearchDialog(
                    shouldFollowUpToWebsiteSearch: !contextualOnboardingSettings.userHasSeenTrackersDialog,
                    delegate: delegate,
                    afterSearchPixelEvent: spec.pixelName,
                    onSizeUpdate: onSizeUpdate
                )
            )
        case .visitWebsite:
            rootView = AnyView(tryVisitingSiteDialog(delegate: delegate))
        case .siteIsMajorTracker, .siteOwnedByMajorTracker, .withMultipleTrackers, .withOneTracker, .withoutTrackers:
            rootView = AnyView(
                withTrackersDialog(
                    for: spec,
                    shouldFollowUpToFireDialog: !contextualOnboardingSettings.userHasSeenFireDialog,
                    delegate: delegate,
                    onSizeUpdate: onSizeUpdate
                )
            )
        case .fire:
            rootView = AnyView(fireDialog(pixelName: spec.pixelName))
        case .final:
            rootView = AnyView(endOfJourneyDialog(delegate: delegate, pixelName: spec.pixelName))
        }

        let viewWithBackground = rootView
            .onboardingDaxDialogStyle()
            .onboardingContextualBackgroundStyle(background: .gradientOnly)
        let hostingController = UIHostingController(rootView: AnyView(viewWithBackground))
        if #available(iOS 16.0, *) {
            hostingController.sizingOptions = [.intrinsicContentSize]
        }

        return hostingController
    }

    private func afterSearchDialog(
        shouldFollowUpToWebsiteSearch: Bool,
        delegate: ContextualOnboardingDelegate,
        afterSearchPixelEvent: Pixel.Event,
        onSizeUpdate: @escaping () -> Void
    ) -> some View {

        func dialogMessage() -> NSAttributedString {
            let message = UserText.Onboarding.ContextualOnboarding.onboardingFirstSearchDoneMessage
            let boldRange = message.range(of: "DuckDuckGo Search")
            return message.attributed.with(attribute: .font, value: UIFont.daxBodyBold(), in: boldRange)
        }

        let viewModel = OnboardingSiteSuggestionsViewModel(title: UserText.Onboarding.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: contextualOnboardingSiteSuggestionsProvider, delegate: delegate, pixelReporter: contextualOnboardingPixelReporter)

        // If should not show websites search after searching inform the delegate that the user dimissed the dialog, otherwise let the dialog handle it.
        let gotItAction: () -> Void = if shouldFollowUpToWebsiteSearch {
            { [weak delegate, weak self] in
                onSizeUpdate()
                delegate?.didAcknowledgeContextualOnboardingSearch()
                self?.contextualOnboardingPixelReporter.trackScreenImpression(event: .onboardingContextualTryVisitSiteUnique)
            }
        } else {
            { [weak delegate] in
                delegate?.didTapDismissContextualOnboardingAction()
            }
        }

        return OnboardingFirstSearchDoneDialog(message: dialogMessage(), shouldFollowUp: shouldFollowUpToWebsiteSearch, viewModel: viewModel, gotItAction: gotItAction)
            .onFirstAppear { [weak self] in
                self?.contextualOnboardingPixelReporter.trackScreenImpression(event: afterSearchPixelEvent)
            }
    }

    private func tryVisitingSiteDialog(delegate: ContextualOnboardingDelegate) -> some View {
        let viewModel = OnboardingSiteSuggestionsViewModel(title: UserText.Onboarding.ContextualOnboarding.onboardingTryASiteTitle, suggestedSitesProvider: contextualOnboardingSiteSuggestionsProvider, delegate: delegate, pixelReporter: contextualOnboardingPixelReporter)
        return OnboardingTryVisitingSiteDialog(logoPosition: .left, viewModel: viewModel)
            .onFirstAppear { [weak self] in
                self?.contextualOnboardingPixelReporter.trackScreenImpression(event: .onboardingContextualTryVisitSiteUnique)
            }
    }

    private func withTrackersDialog(for spec: DaxDialogs.BrowsingSpec, shouldFollowUpToFireDialog: Bool, delegate: ContextualOnboardingDelegate, onSizeUpdate: @escaping () -> Void) -> some View {
        let attributedMessage = spec.message.attributedStringFromMarkdown(color: ThemeManager.shared.currentTheme.daxDialogTextColor)
        return OnboardingTrackersDoneDialog(shouldFollowUp: shouldFollowUpToFireDialog, message: attributedMessage, blockedTrackersCTAAction: { [weak self, weak delegate] in
            // If the user has not seen the fire dialog yet proceed to the fire dialog, otherwise dismiss the dialog.
            if self?.contextualOnboardingSettings.userHasSeenFireDialog == true {
                delegate?.didTapDismissContextualOnboardingAction()
            } else {
                onSizeUpdate()
                delegate?.didAcknowledgeContextualOnboardingTrackersDialog()
                self?.contextualOnboardingPixelReporter.trackScreenImpression(event: .daxDialogsFireEducationShownUnique)
            }
        })
        .onAppear { [weak delegate] in
            delegate?.didShowContextualOnboardingTrackersDialog()
        }
        .onFirstAppear { [weak self] in
            self?.contextualOnboardingPixelReporter.trackScreenImpression(event: spec.pixelName)
        }
    }

    private func fireDialog(pixelName: Pixel.Event) -> some View {
        OnboardingFireDialog()
            .onFirstAppear { [weak self] in
                self?.contextualOnboardingPixelReporter.trackScreenImpression(event: pixelName)
            }
    }

    private func endOfJourneyDialog(delegate: ContextualOnboardingDelegate, pixelName: Pixel.Event) -> some View {
        let shouldShowAddToDock = onboardingManager.addToDockEnabledState == .contextual

        let (message, cta) = if shouldShowAddToDock {
            (UserText.AddToDockOnboarding.Promo.contextualMessage, UserText.AddToDockOnboarding.Buttons.startBrowsing)
        } else {
            (
                UserText.Onboarding.ContextualOnboarding.onboardingFinalScreenMessage,
                UserText.Onboarding.ContextualOnboarding.onboardingFinalScreenButton
            )
        }

        let showAddToDockTutorialAction: () -> Void = { [weak self] in
            self?.contextualOnboardingPixelReporter.trackAddToDockPromoShowTutorialCTAAction()
        }

        let dismissAction = { [weak delegate, weak self] isDismissedFromAddToDockTutorial in
            delegate?.didTapDismissContextualOnboardingAction()
            if isDismissedFromAddToDockTutorial {
                self?.contextualOnboardingPixelReporter.trackAddToDockTutorialDismissCTAAction()
            } else {
                self?.contextualOnboardingPixelReporter.trackEndOfJourneyDialogCTAAction()
                if shouldShowAddToDock {
                    self?.contextualOnboardingPixelReporter.trackAddToDockPromoDismissCTAAction()
                }
            }
        }

        return OnboardingFinalDialog(
            logoPosition: .left,
            message: message,
            cta: cta,
            canShowAddToDockTutorial: shouldShowAddToDock,
            showAddToDockTutorialAction: showAddToDockTutorialAction,
            dismissAction: dismissAction
        )
        .onFirstAppear { [weak self] in
            self?.contextualOnboardingLogic.setFinalOnboardingDialogSeen()
            self?.contextualOnboardingPixelReporter.trackScreenImpression(event: pixelName)
            if shouldShowAddToDock {
                self?.contextualOnboardingPixelReporter.trackAddToDockPromoImpression()
            }
        }
    }

}

// MARK: - Contextual Onboarding Settings

protocol ContextualOnboardingSettings {
    var userHasSeenTrackersDialog: Bool { get }
    var userHasSeenFireDialog: Bool { get }
}

extension DefaultDaxDialogsSettings: ContextualOnboardingSettings {
    
    var userHasSeenTrackersDialog: Bool {
        browsingWithTrackersShown ||
        browsingWithoutTrackersShown ||
        browsingMajorTrackingSiteShown
    }
    
    var userHasSeenFireDialog: Bool {
        fireMessageExperimentShown
    }

}
