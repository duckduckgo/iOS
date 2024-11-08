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
import Onboarding
import class UIKit.UIApplication

final class OnboardingIntroViewModel: ObservableObject {
    @Published private(set) var state: OnboardingView.ViewState = .landing

    let copy: Copy
    let gradientType: OnboardingGradientType
    var onCompletingOnboardingIntro: (() -> Void)?
    private let introSteps: [OnboardingIntroStep]
    private var currentStep: OnboardingIntroStep {
        didSet {
            state = makeViewState(for: currentStep)
            trackCurrentDialogImpression()
        }
    }

    private let pixelReporter: OnboardingIntroPixelReporting & OnboardingAddToDockReporting
    private let onboardingManager: OnboardingHighlightsManaging & OnboardingAddToDockManaging
    private let isIpad: Bool
    private let urlOpener: URLOpener
    private let appIconProvider: () -> AppIcon
    private let addressBarPositionProvider: () -> AddressBarPosition

    init(
        pixelReporter: OnboardingIntroPixelReporting & OnboardingAddToDockReporting,
        onboardingManager: OnboardingHighlightsManaging & OnboardingAddToDockManaging = OnboardingManager(),
        isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad,
        urlOpener: URLOpener = UIApplication.shared,
        appIconProvider: @escaping () -> AppIcon = { AppIconManager.shared.appIcon },
        addressBarPositionProvider: @escaping () -> AddressBarPosition = { AppUserDefaults().currentAddressBarPosition }
    ) {
        self.pixelReporter = pixelReporter
        self.onboardingManager = onboardingManager
        self.isIpad = isIpad
        self.urlOpener = urlOpener
        self.appIconProvider = appIconProvider
        self.addressBarPositionProvider = addressBarPositionProvider

        introSteps = if onboardingManager.isOnboardingHighlightsEnabled && onboardingManager.addToDockEnabledState == .intro {
            isIpad ? OnboardingIntroStep.highlightsIPadFlow : OnboardingIntroStep.highlightsAddToDockIphoneFlow
        } else if onboardingManager.isOnboardingHighlightsEnabled {
            isIpad ? OnboardingIntroStep.highlightsIPadFlow : OnboardingIntroStep.highlightsIPhoneFlow
        } else {
            OnboardingIntroStep.defaultFlow
        }

        copy = onboardingManager.isOnboardingHighlightsEnabled ? .highlights : .default
        gradientType = onboardingManager.isOnboardingHighlightsEnabled ? .highlights : .default

        currentStep = introSteps.first ?? .landing
        state = makeViewState(for: currentStep)
    }

    func onAppear() {
        nextStep()
    }

    func startOnboardingAction() {
        nextStep()
    }

    func setDefaultBrowserAction() {
        pixelReporter.trackChooseBrowserCTAAction()

        if let url = URL(string: UIApplication.openSettingsURLString) {
            urlOpener.open(url)
        }
        nextStep()
    }

    func cancelSetDefaultBrowserAction() {
        nextStep()

        if currentStep == .addToDockPromo {
            pixelReporter.trackAddToDockPromoImpression()
        } else if currentStep == .appIconSelection {
            pixelReporter.trackChooseAppIconImpression()
        }
    }

    func addtoDockShowTutorialAction() {
        // This is a substep so no need to change view state
        pixelReporter.trackAddToDockPromoShowTutorialCTAAction()
    }

    func addToDockContinueAction(isShowingAddToDockTutorial: Bool) {
        nextStep()
    }

    func appIconPickerContinueAction() {
        nextStep()

        if appIconProvider() != .defaultAppIcon {
            pixelReporter.trackChooseCustomAppIconColor()
        }
    }

    func selectAddressBarPositionAction() {
        if addressBarPositionProvider() == .bottom {
            pixelReporter.trackChooseBottomAddressBarPosition()
        }
        nextStep()
    }

}

// MARK: - Private

private extension OnboardingIntroViewModel {

    func nextStep() {
        guard
            let currentStepIndex = introSteps.firstIndex(of: currentStep),
            introSteps.indices.contains(currentStepIndex),
            let nextStep = introSteps[safe: currentStepIndex+1]
        else {
            dismiss()
            return
        }

        currentStep = nextStep
    }

    func dismiss() {
        onCompletingOnboardingIntro?()
    }

    func makeViewState(for introStep: OnboardingIntroStep) -> OnboardingView.ViewState {
        
        func stepInfo() -> OnboardingView.ViewState.Intro.StepInfo {
            guard
                let currentStepIndex = introSteps.firstIndex(of: introStep),
                    onboardingManager.isOnboardingHighlightsEnabled
            else {
                return .hidden
            }

            // Remove .landing from the count of the current step
            // Remove .landing and .startOnboardingDialog from the count of total steps since we don't show the progress for that step.
            return OnboardingView.ViewState.Intro.StepInfo(currentStep: currentStepIndex - 1, totalSteps: introSteps.count - 2)
        }

        let viewState = switch introStep {
        case .landing:
            OnboardingView.ViewState.landing
        case .introDialog:
            OnboardingView.ViewState.onboarding(.init(type: .startOnboardingDialog, step: .hidden))
        case .browserComparison:
            OnboardingView.ViewState.onboarding(.init(type: .browsersComparisonDialog, step: stepInfo()))
        case .addToDockPromo:
            OnboardingView.ViewState.onboarding(.init(type: .addToDockPromoDialog, step: stepInfo()))
        case .appIconSelection:
            OnboardingView.ViewState.onboarding(.init(type: .chooseAppIconDialog, step: stepInfo()))
        case .addressBarPositionSelection:
            OnboardingView.ViewState.onboarding(.init(type: .chooseAddressBarPositionDialog, step: stepInfo()))
        }

        return viewState
    }

    func trackCurrentDialogImpression() {
        switch currentStep {
        case .landing:
            break
        case .introDialog:
            pixelReporter.trackOnboardingIntroImpression()
        case .browserComparison:
            pixelReporter.trackBrowserComparisonImpression()
        case .appIconSelection:
            pixelReporter.trackChooseAppIconImpression()
        case .addressBarPositionSelection:
            pixelReporter.trackAddressBarPositionSelectionImpression()
        case .addToDockPromo:
            pixelReporter.trackAddToDockPromoImpression()
        }
    }

}

// MARK: - OnboardingIntroStep

private enum OnboardingIntroStep {
    case landing
    case introDialog
    case browserComparison
    case appIconSelection
    case addressBarPositionSelection
    case addToDockPromo

    static let defaultFlow: [OnboardingIntroStep] = [.landing, .introDialog, .browserComparison]
    static let highlightsIPhoneFlow: [OnboardingIntroStep] = [.landing, .introDialog, .browserComparison, .appIconSelection, .addressBarPositionSelection]
    static let highlightsIPadFlow: [OnboardingIntroStep] = [.landing, .introDialog, .browserComparison, .appIconSelection]
    static let highlightsAddToDockIphoneFlow: [OnboardingIntroStep] = [.landing, .introDialog, .browserComparison, .addToDockPromo, .appIconSelection, .addressBarPositionSelection]
}
