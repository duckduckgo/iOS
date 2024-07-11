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
            HStack(alignment: .top) {

                VStack {
                    Image(Metrics.hikerImage.build(v: verticalSizeClass, h: horizontalSizeClass))
                        .resizable()
                        .scaledToFit()
                        .frame(height: proxy.size.height * 0.90)
                }
                .frame(width: proxy.size.width / 2, height: proxy.size.height, alignment: .bottomLeading)

                welcomeView
                    .padding(.top, proxy.size.height * 0.15)
                    .frame(width: proxy.size.width / 2, alignment: .top)


            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }

        private var welcomeView: some View {
            VStack(alignment: .center, spacing: Metrics.welcomeMessageStackSpacing.build(v: verticalSizeClass, h: horizontalSizeClass)) {
                Image(.daxIcon)
                    .resizable()
                    .matchedGeometryEffect(id: OnboardingView.daxGeometryEffectID, in: animationNamespace)
                    .frame(width: Metrics.iconSize.width, height: Metrics.iconSize.height)

                Text(UserText.onboardingWelcomeHeader)
                    .onboardingTitleStyle(fontSize: Metrics.titleSize.build(v: verticalSizeClass, h: horizontalSizeClass))
                    .frame(width: Metrics.titleWidth.build(v: verticalSizeClass, h: horizontalSizeClass), alignment: .top)
            }
        }

    }
}

// MARK: - Metrics

private enum Metrics {
    static let iconSize = CGSize(width: 70, height: 70)
    static let welcomeMessageStackSpacing = MetricBuilder<CGFloat>(iPhone: 13, iPad: 32)
    static let titleSize = MetricBuilder<CGFloat>(iPhone: 28, iPad: 36)
    static let titleWidth = MetricBuilder<CGFloat?>(iPhone: 252, iPad: nil)
    static let hikerImage = MetricBuilder<ImageResource>(value: .hiker).smallIphone(.hikerSmall)
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
