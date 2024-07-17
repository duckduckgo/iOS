//
//  OnboardingDefaultBrowserView.swift
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

struct OnboardingDefaultBrowserView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let setAsDefaultBrowserAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        ZStack {
            Color(designSystemColor: .surface)
                .ignoresSafeArea()

            VStack(spacing: Metrics.verticalSpacing) {
                Text(UserText.onboardingDefaultBrowserTitle)
                    .onboardingTitleStyle(fontSize: 28)
                    .padding([.top, .horizontal])

                Text(UserText.DaxOnboardingExperiment.DefaultBrowser.message)
                    .font(.system(size: 16.0))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Image(.ddgDefaultBrowser)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 48)

                Spacer()
                    .frame(height: Metrics.spacerHeight.build(v: verticalSizeClass, h: horizontalSizeClass))

                OnboardingActions(
                    viewModel: .init(
                        primaryButtonTitle: UserText.onboardingSetAsDefaultBrowser,
                        secondaryButtonTitle: UserText.onboardingDefaultBrowserMaybeLater
                    ),
                    primaryAction: setAsDefaultBrowserAction,
                    secondaryAction: cancelAction
                )

            }
            .padding(.top)
            .frame(maxWidth: Metrics.viewWidth, maxHeight: .infinity, alignment: .center)
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let verticalSpacing: CGFloat = 16.0
    static let spacerHeight = MetricBuilder<CGFloat>(iPhone: 142, iPad: 142).smallIphone(10)
    static let viewWidth: CGFloat = 325.0
}

// MARK: - Preview

#Preview {
    OnboardingDefaultBrowserView(setAsDefaultBrowserAction: {}, cancelAction: {})
}
