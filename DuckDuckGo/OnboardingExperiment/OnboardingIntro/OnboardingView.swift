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

// MARK: - OnboardingView

struct OnboardingView: View {

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject private var model: OnboardingIntroViewModel

    @State private var showIntroViewContent = true
    @State private var showIntroButton = false
    @State private var animateIntroText = true
    @State private var showComparisonButton = false
    @State private var animateComparisonText = false

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
                    onTapGesture: {
                        withAnimation {
                            switch model.state {
                            case .onboarding(.startOnboardingDialog):
                                showIntroButton = true
                                animateIntroText = false
                            case .onboarding(.browsersComparisonDialog):
                                showComparisonButton = true
                                animateComparisonText = false
                            default: break
                            }
                        }
                    },
                    content: {
                        VStack {
                            switch state {
                            case .startOnboardingDialog:
                                introView
                            case .browsersComparisonDialog:
                                browsersComparisonView
                            }
                        }
                    }
                )
            }
            .frame(width: geometry.size.width, alignment: .center)
            .offset(y: geometry.size.height * Metrics.dialogVerticalOffsetPercentage.build(v: verticalSizeClass, h: horizontalSizeClass))
        }
        .padding()
    }

    private var landingView: some View {
        return LandingView()
            .ignoresSafeArea(edges: .bottom)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.daxDialogDelay) {
                    model.onAppear()
                }
            }
    }

    private var introView: some View {
        IntroDialogContent(animateText: $animateIntroText, showCTA: $showIntroButton) {
            animateBrowserComparisonViewState()
        }
        .onboardingDaxDialogStyle()
        .visibility(showIntroViewContent ? .visible : .invisible)
    }

    private var browsersComparisonView: some View {
        BrowsersComparisonContent(
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
    }
    
}

extension OnboardingView.ViewState {

    enum Intro: Equatable {
        case startOnboardingDialog
        case browsersComparisonDialog
    }
    
}

// MARK: - Metrics

private enum Metrics {
    static let daxDialogDelay: TimeInterval = 2.0
    static let comparisonChartAnimationDuration = 0.25
    static let dialogVerticalOffsetPercentage = MetricBuilder<CGFloat>(iPhone: 0.1, iPad: 0.2).smallIphone(0.01)
}

// MARK: - Preview

#Preview("Onboarding - Light") {
    OnboardingView(model: .init())
        .preferredColorScheme(.light)
}

#Preview("Onboarding - Dark") {
    OnboardingView(model: .init())
        .preferredColorScheme(.dark)
}
