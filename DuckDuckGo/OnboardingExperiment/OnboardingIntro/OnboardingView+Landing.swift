//
//  OnboardingView+Landing.swift
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

extension OnboardingView {

    struct LandingView: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass

        let animationNamespace: Namespace.ID

        var body: some View {
            GeometryReader { proxy in
                if isIpadLandscape(v: verticalSizeClass, h: horizontalSizeClass) {
                    landingScreenIPadLandscape(proxy: proxy)
                } else {
                    landingScreenPortrait(proxy: proxy)
                }
            }
        }

        func landingScreenPortrait(proxy: GeometryProxy) -> some View {
            VStack {
                Spacer()

                welcomeView

                Spacer()

                Image(Metrics.hikerImage.build(v: verticalSizeClass, h: horizontalSizeClass))
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        }

        func landingScreenIPadLandscape(proxy: GeometryProxy) -> some View {
            HStack(spacing: 0) {
                // Divide screen in half with two containers:
                // 1. Hiker to be centered horizontally in the container and with a height of 90% of the screen size
                // 2. Welcome view horizontally centered in the container with min padding leading and trailing to wrap the text if needed.
                VStack(alignment: .center) {
                    Image(Metrics.hikerImage.build(v: verticalSizeClass, h: horizontalSizeClass))
                        .resizable()
                        .scaledToFit()
                        .frame(height: proxy.size.height * Metrics.Landscape.hikerHeightPercentage)
                }
                .frame(width: proxy.size.width / 2, height: proxy.size.height, alignment: .bottom)

                HStack {
                    Spacer(minLength: proxy.size.width / 2 * Metrics.Landscape.textMinSpacerPercentage)

                    welcomeView
                        .padding(.top, proxy.size.height * Metrics.Landscape.daxImagePositionPercentage)

                    Spacer(minLength: proxy.size.width / 2 * Metrics.Landscape.textMinSpacerPercentage)
                }
                .frame(width: proxy.size.width / 2, height: proxy.size.height, alignment: .top)
            }
        }

        private var welcomeView: some View {
            let iconSize = Metrics.iconSize.build(v: verticalSizeClass, h: horizontalSizeClass)

            return VStack(alignment: .center, spacing: Metrics.welcomeMessageStackSpacing.build(v: verticalSizeClass, h: horizontalSizeClass)) {
                Image(.daxIconExperiment)
                    .resizable()
                    .matchedGeometryEffect(id: OnboardingView.daxGeometryEffectID, in: animationNamespace)
                    .frame(width: iconSize.width, height: iconSize.height)

                Text(UserText.onboardingWelcomeHeader)
                    .onboardingTitleStyle(fontSize: Metrics.titleSize.build(v: verticalSizeClass, h: horizontalSizeClass))
                    .frame(width: Metrics.titleWidth.build(v: verticalSizeClass, h: horizontalSizeClass), alignment: .top)
            }
        }

    }
}

// MARK: - Metrics

private enum Metrics {
    static let iconSize = MetricBuilder<CGSize>(value: .init(width: 70, height: 70)).iPad(landscape: .init(width: 96, height: 96))
    static let welcomeMessageStackSpacing = MetricBuilder<CGFloat>(iPhone: 13, iPad: 32)
    static let titleSize = MetricBuilder<CGFloat>(iPhone: 28, iPad: 36).iPad(landscape: 48)
    static let titleWidth = MetricBuilder<CGFloat?>(iPhone: 252, iPad: nil)
    static let hikerImage = MetricBuilder<ImageResource>(value: .hiker).smallIphone(.hikerSmall)
    enum Landscape {
        static let textMinSpacerPercentage: CGFloat = 0.15
        static let daxImagePositionPercentage: CGFloat = 0.15
        static let hikerHeightPercentage: CGFloat = 0.9
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    OnboardingView.LandingView(animationNamespace: Namespace().wrappedValue)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OnboardingView.LandingView(animationNamespace: Namespace().wrappedValue)
        .preferredColorScheme(.dark)
}
