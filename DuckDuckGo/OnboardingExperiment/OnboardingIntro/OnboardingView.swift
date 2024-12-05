//
//  OnboardingView.swift
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

// MARK: - OnboardingView

struct OnboardingView: View {

    static let daxGeometryEffectID = "DaxIcon"

    @Namespace var animationNamespace
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject private var model: OnboardingIntroViewModel

    @State private var showDaxDialogBox = false
    @State private var showIntroViewContent = true
    @State private var showIntroButton = false
    @State private var animateIntroText = false
    @State private var showComparisonButton = false
    @State private var animateComparisonText = false

    @State private var appIconPickerContentState = AppIconPickerContentState()
    @State private var addressBarPositionContentState = AddressBarPositionContentState()

    init(model: OnboardingIntroViewModel) {
        self.model = model
    }

    var body: some View {
        ZStack {
            OnboardingBackground()

            switch model.state {
            case .landing:
                landingView
            case let .onboarding(viewState):
                onboardingDialogView(state: viewState)
            }
        }
    }

    private func onboardingDialogView(state: ViewState.Intro) -> some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                DaxDialogView(
                    logoPosition: .top,
                    matchLogoAnimation: (Self.daxGeometryEffectID, animationNamespace),
                    showDialogBox: $showDaxDialogBox,
                    onTapGesture: {
                        withAnimation {
                            switch model.state.intro?.type {
                            case .startOnboardingDialog:
                                showIntroButton = true
                                animateIntroText = false
                            case .browsersComparisonDialog:
                                showComparisonButton = true
                                animateComparisonText = false
                            case .chooseAppIconDialog:
                                appIconPickerContentState.animateTitle = false
                                appIconPickerContentState.animateMessage = false
                                appIconPickerContentState.showContent = true
                            default: break
                            }
                        }
                    },
                    content: {
                        VStack {
                            switch state.type {
                            case .startOnboardingDialog:
                                introView
                            case .browsersComparisonDialog:
                                browsersComparisonView
                            case .addToDockPromoDialog:
                                addToDockPromoView
                            case .chooseAppIconDialog:
                                appIconPickerView
                            case .chooseAddressBarPositionDialog:
                                addressBarPreferenceSelectionView
                            }
                        }
                    }
                )
                .onboardingProgressIndicator(currentStep: state.step.currentStep, totalSteps: state.step.totalSteps)
            }
            .frame(width: geometry.size.width, alignment: .center)
            .offset(y: geometry.size.height * Metrics.dialogVerticalOffsetPercentage.build(v: verticalSizeClass, h: horizontalSizeClass))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.daxDialogVisibilityDelay) {
                    showDaxDialogBox = true
                    animateIntroText = true
                }
            }
        }
        .padding()
    }

    private var landingView: some View {
        return LandingView(animationNamespace: animationNamespace)
            .ignoresSafeArea(edges: .bottom)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.daxDialogDelay) {
                    withAnimation {
                        model.onAppear()
                    }
                }
            }
    }

    private var introView: some View {
        IntroDialogContent(
            title: model.copy.introTitle,
            animateText: $animateIntroText,
            showCTA: $showIntroButton
        ) {
            animateBrowserComparisonViewState()
        }
        .onboardingDaxDialogStyle()
        .visibility(showIntroViewContent ? .visible : .invisible)
    }

    private var browsersComparisonView: some View {
        BrowsersComparisonContent(
            title: model.copy.browserComparisonTitle,
            animateText: $animateComparisonText,
            showContent: $showComparisonButton,
            setAsDefaultBrowserAction: {
                model.setDefaultBrowserAction()
            }, cancelAction: {
                model.cancelSetDefaultBrowserAction()
            }
        )
        .onboardingDaxDialogStyle()
    }

    private var addToDockPromoView: some View {
        AddToDockPromoContent(
            showTutorialAction: {
                model.addtoDockShowTutorialAction()
            },
            dismissAction: { fromAddToDockTutorial in
                model.addToDockContinueAction(isShowingAddToDockTutorial: fromAddToDockTutorial)
            }
        )
    }

    private var appIconPickerView: some View {
        AppIconPickerContent(
            animateTitle: $appIconPickerContentState.animateTitle,
            animateMessage: $appIconPickerContentState.animateMessage,
            showContent: $appIconPickerContentState.showContent,
            action: model.appIconPickerContinueAction
        )
        .onboardingDaxDialogStyle()
    }

    private var addressBarPreferenceSelectionView: some View {
        AddressBarPositionContent(
            animateTitle: $addressBarPositionContentState.animateTitle,
            showContent: $addressBarPositionContentState.showContent,
            action: model.selectAddressBarPositionAction
        )
        .onboardingDaxDialogStyle()
    }

    private func animateBrowserComparisonViewState() {
        // Hide content of Intro dialog before animating
        showIntroViewContent = false

        // Animation with small delay for a better effect when intro content disappear
        let animationDuration = Metrics.comparisonChartAnimationDuration
        let animation = Animation
            .linear(duration: animationDuration)
            .delay(0.2)

        if #available(iOS 17, *) {
            withAnimation(animation) {
                model.startOnboardingAction()
            } completion: {
                animateComparisonText = true
            }
        } else {
            withAnimation(animation) {
                model.startOnboardingAction()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                animateComparisonText = true
            }
        }
    }
}

// MARK: - View State

extension OnboardingView {

    enum ViewState: Equatable {
        case landing
        case onboarding(Intro)

        var intro: Intro? {
            switch self {
            case .landing:
                return nil
            case let .onboarding(intro):
                return intro
            }
        }
    }
    
}

extension OnboardingView.ViewState {
    
    struct Intro: Equatable {
        let type: IntroType
        let step: StepInfo
    }

}

extension OnboardingView.ViewState.Intro {

    enum IntroType: Equatable {
        case startOnboardingDialog
        case browsersComparisonDialog
        case addToDockPromoDialog
        case chooseAppIconDialog
        case chooseAddressBarPositionDialog
    }

    struct StepInfo: Equatable {
        let currentStep: Int
        let totalSteps: Int

        static let hidden = StepInfo(currentStep: 0, totalSteps: 0)
    }

}

// MARK: - Metrics

private enum Metrics {
    static let daxDialogDelay: TimeInterval = 2.0
    static let daxDialogVisibilityDelay: TimeInterval = 0.5
    static let comparisonChartAnimationDuration = 0.25
    static let dialogVerticalOffsetPercentage = MetricBuilder<CGFloat>(value: 0.1).smallIphone(0.01)
    static let progressBarTrailingPadding: CGFloat = 16.0
    static let progressBarTopPadding: CGFloat = 12.0
}

// MARK: - Helpers

private extension View {

    func onboardingProgressIndicator(currentStep: Int, totalSteps: Int) -> some View {
        overlay(alignment: .topTrailing) {
            OnboardingProgressIndicator(stepInfo: .init(currentStep: currentStep, totalSteps: totalSteps))
                .padding(.trailing, Metrics.progressBarTrailingPadding)
                .padding(.top, Metrics.progressBarTopPadding)
                .transition(.identity)
                .visibility(totalSteps == 0 ? .invisible : .visible)
        }
    }

}

// MARK: - Preview

#Preview("Onboarding - Light") {
    OnboardingView(model: .init(pixelReporter: OnboardingPixelReporter()))
        .preferredColorScheme(.light)
}

#Preview("Onboarding - Dark") {
    OnboardingView(model: .init(pixelReporter: OnboardingPixelReporter()))
        .preferredColorScheme(.dark)
}
