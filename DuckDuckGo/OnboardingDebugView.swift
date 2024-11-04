//
//  OnboardingDebugView.swift
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

struct OnboardingDebugView: View {

    @StateObject private var viewModel = OnboardingDebugViewModel()

    private let newOnboardingIntroStartAction: () -> Void

    init(onNewOnboardingIntroStartAction: @escaping () -> Void) {
        newOnboardingIntroStartAction = onNewOnboardingIntroStartAction
    }

    var body: some View {
        List {
            Section {
                Toggle(
                    isOn: $viewModel.isOnboardingHighlightsLocalFlagEnabled,
                    label: {
                        Text(verbatim: "Onboarding Highlights local setting enabled")
                    }
                )
            } header: {
                Text(verbatim: "Onboarding Higlights settings")
            } footer: {
                Text(verbatim: "Requires internal user flag set to have an effect.")
            }

            Section {
                Picker(
                    selection: $viewModel.onboardingAddToDockLocalFlagState,
                    content: {
                        ForEach(OnboardingAddToDockState.allCases) { state in
                            Text(verbatim: state.description).tag(state)
                        }
                    },
                    label: {
                        Text(verbatim: "Onboarding Add to Dock local setting enabled")
                    }
                )
            } header: {
                Text(verbatim: "Onboarding Add to Dock settings")
            } footer: {
                Text(verbatim: "Requires internal user flag set to have an effect.")
            }

            Section {
                Button(action: newOnboardingIntroStartAction, label: {
                    let onboardingType = viewModel.isOnboardingHighlightsLocalFlagEnabled ? "Highlights" : ""
                    Text(verbatim: "Preview New Onboarding Intro \(onboardingType)")
                })
            }
        }
    }
}

final class OnboardingDebugViewModel: ObservableObject {
    @Published var isOnboardingHighlightsLocalFlagEnabled: Bool {
        didSet {
            manager.isOnboardingHighlightsLocalFlagEnabled = isOnboardingHighlightsLocalFlagEnabled
        }
    }

    @Published var onboardingAddToDockLocalFlagState: OnboardingAddToDockState {
        didSet {
            manager.addToDockLocalFlagState = onboardingAddToDockLocalFlagState
        }
    }

    private let manager: OnboardingHighlightsDebugging & OnboardingAddToDockDebugging

    init(manager: OnboardingHighlightsDebugging & OnboardingAddToDockDebugging = OnboardingManager()) {
        self.manager = manager
        isOnboardingHighlightsLocalFlagEnabled = manager.isOnboardingHighlightsLocalFlagEnabled
        onboardingAddToDockLocalFlagState = manager.addToDockLocalFlagState
    }

}

#Preview {
    OnboardingDebugView(onNewOnboardingIntroStartAction: {})
}

extension OnboardingAddToDockState: Identifiable {
    var id: OnboardingAddToDockState {
        self
    }
}
