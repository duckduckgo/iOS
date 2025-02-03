//
//  FeatureFlagsMenuView.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import Foundation
import SwiftUI
import Core

struct FeatureFlagsMenuView: View {
    @ObservedObject var viewModel: FeatureFlagsSettingViewModel = FeatureFlagsSettingViewModel()

    var body: some View {
        if viewModel.isInternalUser {
            List {
                featureFlagsSection()
                experimentsSection()
                resetAllOverridesSection()
            }
            .navigationTitle(Text(verbatim: "Feature Flags"))
        } else {
            internalUserMessage()
        }
    }

    // MARK: - Internal User Message Section
    private func internalUserMessage() -> some View {
        VStack {
            Text(verbatim: "Set internal user state first")
                .foregroundColor(.red)
            Spacer()
        }
    }

    // MARK: - Feature Flags Section
    private func featureFlagsSection() -> some View {
        Section(header: Text(verbatim: "Feature Flags")) {
            ForEach(viewModel.featureFlags, id: \.self) { flag in
                featureFlagRow(flag: flag)
            }
        }
    }

    private func featureFlagRow(flag: FeatureFlag) -> some View {
        HStack {
            Toggle(
                isOn: Binding(
                    get: { viewModel.isFeatureEnabled(flag) },
                    set: { newValue in viewModel.toggleFeatureFlag(flag, enabled: newValue) }
                )
            ) {
                VStack(alignment: .leading) {
                    Text(verbatim: flag.rawValue)
                        .font(.headline)
                    Text(verbatim: "Default: \(viewModel.defaultValue(for: flag))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Button(action: {
                viewModel.resetOverride(for: flag)
            }, label: {
                Text(verbatim: "Reset")
                    .padding()
            })
            .foregroundColor(.blue)
        }
    }

    // MARK: - Experiments Section
    private func experimentsSection() -> some View {
        Section(header: Text(verbatim: "Experiments")) {
            ForEach(viewModel.experiments, id: \.self) { flag in
                experimentRow(flag: flag)
            }
        }
    }

    private func experimentRow(flag: FeatureFlag) -> some View {
        NavigationLink(destination: ExperimentCohortView(viewModel: viewModel, experiment: flag)) {
            VStack(alignment: .leading) {
                Text(verbatim: flag.rawValue)
                    .font(.headline)
                Text(verbatim: "Current cohort: \(viewModel.getCurrentCohort(for: flag) ?? "None")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Reset All Overrides Section
    private func resetAllOverridesSection() -> some View {
        Section {
            Button(action: {
                viewModel.resetAllOverrides()
            }, label: {
                Text(verbatim: "Reset All Overrides")
            })
            .foregroundColor(.red)
        }
    }
}
