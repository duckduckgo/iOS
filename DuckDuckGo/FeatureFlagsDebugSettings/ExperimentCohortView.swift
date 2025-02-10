//
//  ExperimentCohortView.swift
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

struct ExperimentCohortView: View {
    @ObservedObject var viewModel: FeatureFlagsSettingViewModel
    let experiment: FeatureFlag

    var body: some View {
        List {
            Section(header: Text(verbatim: "Default cohort: \(viewModel.defaultExperimentCohort(for: experiment) ?? "None")")) {
                ForEach(viewModel.getCohorts(for: experiment), id: \.self) { cohort in
                    Button {
                        viewModel.setExperimentCohort(for: experiment, cohort: cohort)
                    } label: {
                        HStack {
                            Text(verbatim: cohort)
                            if viewModel.getCurrentCohort(for: experiment) == cohort {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section {
                Button(role: .destructive, action: {
                    viewModel.resetOverride(for: experiment)
                }, label: {
                    Text(verbatim: "Reset to Default Cohort")
                })
                .disabled(viewModel.getCurrentCohort(for: experiment) == viewModel.defaultExperimentCohort(for: experiment))


            }
        }
        .navigationTitle(Text(verbatim: "Cohort Selection"))
    }
}
