//
//  ProgressBarView.swift
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

struct OnboardingProgressIndicator: View {
    
    struct StepInfo {
        let currentStep: Int
        let totalSteps: Int

        fileprivate var percentage: Double {
            guard totalSteps > 0 else { return 0 }
            return Double(currentStep) / Double(totalSteps) * 100
        }
    }

    let stepInfo: StepInfo

    var body: some View {
        VStack(spacing: OnboardingProgressMetrics.verticalSpacing) {
            HStack {
                Spacer()
                Text(verbatim: "\(stepInfo.currentStep) / \(stepInfo.totalSteps)")
                    .onboardingProgressTitleStyle()
                    .padding(.trailing, OnboardingProgressMetrics.textPadding)
            }
            ProgressBarView(progress: stepInfo.percentage)
                .frame(width: OnboardingProgressMetrics.progressBarSize.width, height: OnboardingProgressMetrics.progressBarSize.height)
        }
        .fixedSize()
    }
}

private enum OnboardingProgressMetrics {
    static let verticalSpacing: CGFloat = 8
    static let textPadding: CGFloat = 4
    static let progressBarSize = CGSize(width: 64, height: 4)
}

struct ProgressBarView: View {
    @Environment(\.colorScheme) private var colorScheme

    let progress: Double

    var body: some View {
        Capsule()
            .foregroundStyle(backgroundColor)
            .overlay(
                GeometryReader { proxy in
                    ProgressBarGradient()
                        .clipShape(Capsule().inset(by: ProgressBarMetrics.strokeWidth / 2))
                        .frame(width: progress * proxy.size.width / 100)
                        .animation(.easeInOut, value: progress)
                }
            )
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: ProgressBarMetrics.strokeWidth)
            )
    }

    private var backgroundColor: Color {
        colorScheme == .light ? ProgressBarMetrics.backgroundLight : ProgressBarMetrics.backgroundDark
    }

    private var borderColor: Color {
        colorScheme == .light ? ProgressBarMetrics.borderLight : ProgressBarMetrics.borderDark
    }

}

private enum ProgressBarMetrics {
    static let backgroundLight: Color = .black.opacity(0.06)
    static let borderLight: Color = .black.opacity(0.18)
    static let backgroundDark: Color = .white.opacity(0.09)
    static let borderDark: Color = .white.opacity(0.18)
    static let strokeWidth: CGFloat = 1
}

struct ProgressBarGradient: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors: [Color]
        switch colorScheme {
        case .light:
            colors = lightGradientColors
        case .dark:
            colors = darkGradientColors
        @unknown default:
            colors = lightGradientColors
        }

        return LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var lightGradientColors: [Color] {
        [
            .init(0x3969EF, alpha: 1.0),
            .init(0x6B4EBA, alpha: 1.0),
            .init(0xDE5833, alpha: 1.0),
        ]
    }

    private var darkGradientColors: [Color] {
        [
            .init(0x3969EF, alpha: 1.0),
            .init(0x6B4EBA, alpha: 1.0),
            .init(0xDE5833, alpha: 1.0),
        ]
    }
}

#Preview("Onboarding Progress Indicator") {
    struct PreviewWrapper: View {
        @State var stepInfo = OnboardingProgressIndicator.StepInfo(currentStep: 1, totalSteps: 3)

        var body: some View {
            VStack(spacing: 100) {
                OnboardingProgressIndicator(stepInfo: stepInfo)

                Button(action: {
                    let nextStep = stepInfo.currentStep < stepInfo.totalSteps ? stepInfo.currentStep + 1 : 1
                    stepInfo = OnboardingProgressIndicator.StepInfo(currentStep: nextStep, totalSteps: stepInfo.totalSteps)
                }, label: {
                    Text(verbatim: "Update Progress")
                })
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Progress Bar") {
    ProgressBarView(progress: 80)
        .frame(width: 200, height: 8)
}
