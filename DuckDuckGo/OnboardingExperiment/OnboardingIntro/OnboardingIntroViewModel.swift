//
//  OnboardingIntroViewModel.swift
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
import Core
import class UIKit.UIApplication

final class OnboardingIntroViewModel: ObservableObject {
    @Published private(set) var state: OnboardingView.ViewState = .landing

    let copy: Copy
    var onCompletingOnboardingIntro: (() -> Void)?
    private var introSteps: [OnboardingIntroStep]

    private let pixelReporter: OnboardingIntroPixelReporting
    private let onboardingManager: OnboardingHighlightsManaging
    private let isIpad: Bool
    private let urlOpener: URLOpener

    init(
        pixelReporter: OnboardingIntroPixelReporting,
        onboardingManager: OnboardingHighlightsManaging = OnboardingManager(),
        isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad,
        urlOpener: URLOpener = UIApplication.shared
    ) {
        self.pixelReporter = pixelReporter
        self.onboardingManager = onboardingManager
        self.isIpad = isIpad
        self.urlOpener = urlOpener
        introSteps = if onboardingManager.isOnboardingHighlightsEnabled {
            isIpad ? OnboardingIntroStep.highlightsIPadFlow : OnboardingIntroStep.highlightsIPhoneFlow
        } else {
            OnboardingIntroStep.defaultFlow
        }

        copy = onboardingManager.isOnboardingHighlightsEnabled ? .highlights : .default
    }

    func onAppear() {
        state = makeViewState(for: .introDialog)
        pixelReporter.trackOnboardingIntroImpression()
    }

    func startOnboardingAction() {
        state = makeViewState(for: .browserComparison)
        pixelReporter.trackBrowserComparisonImpression()
    }

    func setDefaultBrowserAction() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            urlOpener.open(url)
        }
        pixelReporter.trackChooseBrowserCTAAction()

        handleSetDefaultBrowserAction()
    }

    func cancelSetDefaultBrowserAction() {
        handleSetDefaultBrowserAction()
    }

    func appIconPickerContinueAction() {
        if isIpad {
            onCompletingOnboardingIntro?()
        } else {
            state = makeViewState(for: .addressBarPositionSelection)
        }
    }

    func selectAddressBarPositionAction() {
        onCompletingOnboardingIntro?()
    }

}

// MARK: - Private

private extension OnboardingIntroViewModel {

    func makeViewState(for introStep: OnboardingIntroStep) -> OnboardingView.ViewState {
        
        func stepInfo() -> OnboardingView.ViewState.Intro.StepInfo {
            guard
                let currentStepIndex = introSteps.firstIndex(of: introStep),
                    onboardingManager.isOnboardingHighlightsEnabled
            else {
                return .hidden
            }

            // Remove startOnboardingDialog from the count of total steps since we don't show the progress for that step.
            return OnboardingView.ViewState.Intro.StepInfo(currentStep: currentStepIndex, totalSteps: introSteps.count - 1)
        }

        let viewState = switch introStep {
        case .introDialog:
            OnboardingView.ViewState.onboarding(.init(type: .startOnboardingDialog, step: .hidden))
        case .browserComparison:
            OnboardingView.ViewState.onboarding(.init(type: .browsersComparisonDialog, step: stepInfo()))
        case .appIconSelection:
            OnboardingView.ViewState.onboarding(.init(type: .chooseAppIconDialog, step: stepInfo()))
        case .addressBarPositionSelection:
            OnboardingView.ViewState.onboarding(.init(type: .chooseAddressBarPositionDialog, step: stepInfo()))
        }

        return viewState
    }

    func handleSetDefaultBrowserAction() {
        if onboardingManager.isOnboardingHighlightsEnabled {
            state = makeViewState(for: .appIconSelection)
        } else {
            onCompletingOnboardingIntro?()
        }
    }

}

// MARK: - OnboardingIntroStep

private enum OnboardingIntroStep {
    case introDialog
    case browserComparison
    case appIconSelection
    case addressBarPositionSelection

    static let defaultFlow: [OnboardingIntroStep] = [.introDialog, .browserComparison]
    static let highlightsIPhoneFlow: [OnboardingIntroStep] = [.introDialog, .browserComparison, .appIconSelection, .addressBarPositionSelection]
    static let highlightsIPadFlow: [OnboardingIntroStep] = [.introDialog, .browserComparison, .appIconSelection]
}

// MARK: OnboardingIntroViewModel + Copy

extension OnboardingIntroViewModel {
    struct Copy {
        let introTitle: String
        let browserComparisonTitle: String
        let trackerBlockers: String
        let cookiePopups: String
        let creepyAds: String
        let eraseBrowsingData: String
    }
}

extension OnboardingIntroViewModel.Copy {
    
    static let `default` = OnboardingIntroViewModel.Copy(
        introTitle: UserText.DaxOnboardingExperiment.Intro.title,
        browserComparisonTitle: UserText.DaxOnboardingExperiment.BrowsersComparison.title,
        trackerBlockers: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.trackerBlockers,
        cookiePopups: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.cookiePopups,
        creepyAds: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.creepyAds,
        eraseBrowsingData: UserText.DaxOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData
    )

    static let highlights = OnboardingIntroViewModel.Copy(
        introTitle: UserText.HighlightsOnboardingExperiment.Intro.title,
        browserComparisonTitle: UserText.HighlightsOnboardingExperiment.BrowsersComparison.title,
        trackerBlockers: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.trackerBlockers,
        cookiePopups: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.cookiePopups,
        creepyAds: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.creepyAds,
        eraseBrowsingData: UserText.HighlightsOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData
    )
}
