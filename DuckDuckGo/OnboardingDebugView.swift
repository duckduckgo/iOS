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
    @State private var isShowingRestDaxDialogsAlert = false

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
                Button(action: {
                    viewModel.resetDaxDialogs()
                    isShowingRestDaxDialogsAlert = true
                }, label: {
                    Text(verbatim: "Reset Dax Dialogs State")
                })
                .alert(isPresented: $isShowingRestDaxDialogsAlert, content: {
                    Alert(title: Text(verbatim: "Dax Dialogs reset"), dismissButton: .cancel())
                })
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
    private var settings: DaxDialogsSettings

    init(manager: OnboardingHighlightsDebugging & OnboardingAddToDockDebugging = OnboardingManager(), settings: DaxDialogsSettings = DefaultDaxDialogsSettings()) {
        self.manager = manager
        self.settings = settings
        isOnboardingHighlightsLocalFlagEnabled = manager.isOnboardingHighlightsLocalFlagEnabled
        onboardingAddToDockLocalFlagState = manager.addToDockLocalFlagState
    }

    func resetDaxDialogs() {
        settings.isDismissed = false
        settings.homeScreenMessagesSeen = 0
        settings.browsingAfterSearchShown = false
        settings.browsingWithTrackersShown = false
        settings.browsingWithoutTrackersShown = false
        settings.browsingMajorTrackingSiteShown = false
        settings.fireMessageExperimentShown = false
        settings.fireButtonPulseDateShown = nil
        settings.privacyButtonPulseShown = false
        settings.browsingFinalDialogShown = false
        settings.lastVisitedOnboardingWebsiteURLPath = nil
        settings.lastShownContextualOnboardingDialogType = nil
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
