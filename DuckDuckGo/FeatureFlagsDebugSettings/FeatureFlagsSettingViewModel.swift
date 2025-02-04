//
//  FeatureFlagsSettingViewModel.swift
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
import Combine
import BrowserServicesKit
import Core

class FeatureFlagsSettingViewModel: ObservableObject {
    private let featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger

    @Published var featureFlags: [FeatureFlag] = []
    @Published var experiments: [FeatureFlag] = []

    init() {
        self.featureFlags = FeatureFlag.allCases.filter { $0.supportsLocalOverriding && $0.cohortType == nil }
        self.experiments = FeatureFlag.allCases.filter { $0.supportsLocalOverriding && $0.cohortType != nil }
    }

    var isInternalUser: Bool {
        return featureFlagger.internalUserDecider.isInternalUser
    }

    func isFeatureEnabled(_ flag: FeatureFlag) -> Bool {
        return featureFlagger.isFeatureOn(for: flag)
    }

    func toggleFeatureFlag(_ flag: FeatureFlag, enabled: Bool) {
        featureFlagger.localOverrides?.toggleOverride(for: flag)
        objectWillChange.send()
    }

    func getCohorts(for experiment: FeatureFlag) -> [String] {
        return experiment.cohortType?.cohorts.map { $0.rawValue } ?? []
    }

    func setExperimentCohort(for experiment: FeatureFlag, cohort: String) {
        featureFlagger.localOverrides?.setExperimentCohortOverride(for: experiment, cohort: cohort)
        objectWillChange.send()
    }

    func getCurrentCohort(for experiment: FeatureFlag) -> String? {
        return featureFlagger.localOverrides?.experimentOverride(for: experiment) ?? defaultExperimentCohort(for: experiment)
    }

    func resetOverride(for flag: FeatureFlag) {
        featureFlagger.localOverrides?.clearOverride(for: flag)
        objectWillChange.send()
    }

    func resetAllOverrides() {
        featureFlagger.localOverrides?.clearAllOverrides(for: FeatureFlag.self)
        objectWillChange.send()
    }

    func defaultValue(for flag: FeatureFlag) -> Bool {
        return featureFlagger.isFeatureOn(for: flag, allowOverride: false)
    }

    func defaultExperimentCohort(for flag: FeatureFlag) -> CohortID? {
        return featureFlagger.localOverrides?.currentExperimentCohort(for: flag)?.rawValue
    }
}
