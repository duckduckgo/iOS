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

    init(model: OnboardingIntroViewModel) {
        self.model = model
    }

    var body: some View {
        Group {
            switch model.state {
            case .landing:
                backgroundWrapped(view: landingView)
            case let .onboarding(viewState):
                backgroundWrapped(view: mainView(state: viewState))
            case .chooseBrowser:
                chooseBrowserView
            }
        }
        .transition(.opacity)
    }

    private func backgroundWrapped(view: some View) -> some View {
        GeometryReader { proxy in
            ZStack {
                OnboardingBackground()
                    .frame(width: proxy.size.width, height: proxy.size.height)

                view
            }
        }
    }

    private func mainView(state: ViewState.Intro) -> some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                switch state {
                case .startOnboardingDialog:
                    introView
                        .frame(width: geometry.size.width)
                case .browsersComparisonDialog:
                    browsersComparisonView
                        .frame(width: geometry.size.width)
                }
            }
            .offset(y: geometry.size.height * Metrics.dialogVerticalOffsetPercentage.build(v: verticalSizeClass, h: horizontalSizeClass))
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.5))
        }
    }

    private var chooseBrowserView: some View {
        OnboardingDefaultBrowserView(
            setAsDefaultBrowserAction: {
                model.setDefaultBrowserAction()
            },
            cancelAction: {
                model.cancelSetDefaultBrowserAction()
            }
        )
    }

    private var landingView: some View {
        return LandingView()
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
        DaxDialogIntroView {
            withAnimation {
                model.startOnboardingAction()
            }
        }
        .onboardingDaxDialogStyle()
        .padding()
    }

    private var browsersComparisonView: some View {
        DaxDialogBrowsersComparisonView {
            withAnimation {
                model.chooseBrowserAction()
            }
        }
        .onboardingDaxDialogStyle()
        .padding()
    }
}

// MARK: - View State

extension OnboardingView {

    enum ViewState: Equatable {
        case landing
        case onboarding(Intro)
        case chooseBrowser
    }
    
}

extension OnboardingView.ViewState {

    enum Intro: Equatable {
        case startOnboardingDialog
        case browsersComparisonDialog
    }
    
}

// MARK: - Landing View

extension OnboardingView {
    
    struct LandingView: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass

        var body: some View {
            GeometryReader { proxy in
                VStack {
                    Spacer()

                    Image(.daxIcon)
                        .resizable()
                        .frame(width: Metrics.iconSize.width, height: Metrics.iconSize.height)

                    Text(UserText.onboardingWelcomeHeader)
                        .onboardingTitleStyle()
                        .frame(width: Metrics.titleWidth.build(v: verticalSizeClass, h: horizontalSizeClass), alignment: .top)

                    Spacer()

                    Image(Metrics.hikerImage.build(v: verticalSizeClass, h: horizontalSizeClass))
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let iconSize = CGSize(width: 70, height: 70)
    static let titleWidth = MetricBuilder<CGFloat?>(iPhone: 252, iPad: nil)
    static let hikerImage = MetricBuilder<ImageResource>(value: .hiker).smallIphone(.hikerSmall)
    static let daxDialogDelay: TimeInterval = 2.0
    static let dialogVerticalOffsetPercentage = MetricBuilder<CGFloat>(iPhone: 0.1, iPad: 0.2).smallIphone(0.05)
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
