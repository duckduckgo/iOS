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
    var onCompletingOnboardingIntro: (() -> Void)?
    private var introSteps: [OnboardingIntroStep]

    private let pixelReporter: OnboardingIntroPixelReporting & OnboardingAddToDockReporting
    private let onboardingManager: OnboardingAddToDockManaging
    private let isIpad: Bool
    private let urlOpener: URLOpener
    private let appIconProvider: () -> AppIcon
    private let addressBarPositionProvider: () -> AddressBarPosition

    init(
        pixelReporter: OnboardingIntroPixelReporting & OnboardingAddToDockReporting,
        onboardingManager: OnboardingAddToDockManaging = OnboardingManager(),
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

        // Add to Dock experiment assigned only to iPhone users
        introSteps = if onboardingManager.addToDockEnabledState == .intro {
            OnboardingIntroStep.addToDockIphoneFlow
        } else {
            isIpad ? OnboardingIntroStep.defaultIPadFlow : OnboardingIntroStep.defaultIPhoneFlow
        }

        copy = .default
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

    func addToDockContinueAction(isShowingAddToDockTutorial: Bool) {
        state = makeViewState(for: .appIconSelection)
        if isShowingAddToDockTutorial {
            pixelReporter.trackAddToDockTutorialDismissCTAAction()
        } else {
            pixelReporter.trackAddToDockPromoDismissCTAAction()
        }
    }

    func addtoDockShowTutorialAction() {
        pixelReporter.trackAddToDockPromoShowTutorialCTAAction()
    }

    func appIconPickerContinueAction() {
        if appIconProvider() != .defaultAppIcon {
            pixelReporter.trackChooseCustomAppIconColor()
        }

        if isIpad {
            onCompletingOnboardingIntro?()
        } else {
            state = makeViewState(for: .addressBarPositionSelection)
            pixelReporter.trackAddressBarPositionSelectionImpression()
        }
    }

    func selectAddressBarPositionAction() {
        if addressBarPositionProvider() == .bottom {
            pixelReporter.trackChooseBottomAddressBarPosition()
        }
        onCompletingOnboardingIntro?()
    }

}

// MARK: - Private

private extension OnboardingIntroViewModel {

    func makeViewState(for introStep: OnboardingIntroStep) -> OnboardingView.ViewState {
        
        func stepInfo() -> OnboardingView.ViewState.Intro.StepInfo {
            guard let currentStepIndex = introSteps.firstIndex(of: introStep) else { return .hidden }

            // Remove startOnboardingDialog from the count of total steps since we don't show the progress for that step.
            return OnboardingView.ViewState.Intro.StepInfo(currentStep: currentStepIndex, totalSteps: introSteps.count - 1)
        }

        let viewState = switch introStep {
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

    func handleSetDefaultBrowserAction() {
        if onboardingManager.addToDockEnabledState == .intro {
            state = makeViewState(for: .addToDockPromo)
            pixelReporter.trackAddToDockPromoImpression()
        } else {
            state = makeViewState(for: .appIconSelection)
            pixelReporter.trackChooseAppIconImpression()
        }
    }

}

// MARK: - OnboardingIntroStep

private enum OnboardingIntroStep {
    case introDialog
    case browserComparison
    case appIconSelection
    case addressBarPositionSelection
    case addToDockPromo

    static let defaultIPhoneFlow: [OnboardingIntroStep] = [.introDialog, .browserComparison, .appIconSelection, .addressBarPositionSelection]
    static let defaultIPadFlow: [OnboardingIntroStep] = [.introDialog, .browserComparison, .appIconSelection]
    static let addToDockIphoneFlow: [OnboardingIntroStep] = [.introDialog, .browserComparison, .addToDockPromo, .appIconSelection, .addressBarPositionSelection]
}
