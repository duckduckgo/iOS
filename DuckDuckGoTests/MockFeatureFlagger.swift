//
//  MockFeatureFlagger.swift
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

import BrowserServicesKit
import Core

final class MockFeatureFlagger: FeatureFlagger {
    var internalUserDecider: InternalUserDecider = DefaultInternalUserDecider(store: MockInternalUserStoring())
    var localOverrides: FeatureFlagLocalOverriding?

    var mockActiveExperiments: [String: ExperimentData] = [:]

    var enabledFeatureFlags: [FeatureFlag] = []

    var cohortToReturn: (any FeatureFlagCohortDescribing)?

    init(enabledFeatureFlags: [FeatureFlag] = []) {
        self.enabledFeatureFlags = enabledFeatureFlags
    }

    func isFeatureOn<Flag: FeatureFlagDescribing>(for featureFlag: Flag, allowOverride: Bool) -> Bool {
        guard let flag = featureFlag as? FeatureFlag else {
            return false
        }
        guard enabledFeatureFlags.contains(flag) else {
            return false
        }
        return true
    }

    func getCohortIfEnabled(_ subfeature: any PrivacySubfeature) -> CohortID? {
        return nil
    }

    func resolveCohort<Flag>(for featureFlag: Flag, allowOverride: Bool) -> (any FeatureFlagCohortDescribing)? where Flag: FeatureFlagDescribing {
        return cohortToReturn
    }

    var allActiveExperiments: Experiments {
        mockActiveExperiments
    }
}
