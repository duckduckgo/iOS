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
            Double(currentStep) / Double(totalSteps) * 100
        }
    }

    let stepInfo: StepInfo

    var body: some View {
        VStack(spacing: 16.0) {
            HStack {
                Spacer()
                Text("\(stepInfo.currentStep) / \(stepInfo.totalSteps)")
                    .padding(.trailing, 4)
            }
            ProgressBarView(progress: stepInfo.percentage)
                .frame(width: 200, height: 8)
        }
        .fixedSize()
    }
}

struct ProgressBarView: View {

    let progress: Double

    var body: some View {
        Capsule()
            .foregroundColor(.black.opacity(0.06))
            .background(
                GeometryReader { proxy in
                    ProgressBarGradient()
                        .clipShape(Capsule().inset(by: 0.6))
                        .frame(width: progress * proxy.size.width / 100)
                }
            )
            .overlay(
                Capsule()
                    .stroke(.black.opacity(0.18), lineWidth: 1)
            )
    }
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

    @State var stepInfo = OnboardingProgressIndicator.StepInfo(currentStep: 1, totalSteps: 3)

    return VStack(spacing: 100) {
        OnboardingProgressIndicator(stepInfo: stepInfo)

        Button(action: {
            let nextStep = stepInfo.currentStep < stepInfo.totalSteps ? stepInfo.currentStep + 1 : 1
            stepInfo = OnboardingProgressIndicator.StepInfo(currentStep: nextStep, totalSteps: stepInfo.totalSteps)
        }, label: {
            Text("Update Progress")
        })
    }
}

#Preview("Progress Bar") {
    ProgressBarView(progress: 80)
        .frame(width: 200, height: 8)
}
