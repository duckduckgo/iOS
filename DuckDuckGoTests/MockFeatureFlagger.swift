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
    var enabledFeatureFlags: [FeatureFlag] = []
    var enabledFeatureFlag: FeatureFlag?

    func isFeatureOn<F>(forProvider provider: F) -> Bool where F: BrowserServicesKit.FeatureFlagSourceProviding {
        guard let flag = provider as? FeatureFlag else {
            return false
        }
        guard enabledFeatureFlags.contains(flag) else {
            return false
        }
        return true
    }
}
