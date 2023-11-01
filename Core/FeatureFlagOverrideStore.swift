//
//  FeatureFlagOverrideStore.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

public final class FeatureFlagOverrideStore: FeatureFlagOverrideStoring {
    static let keyPrefix = "com.duckduckgo.core.featureFlagOverrideStore"

    public init() {
    }

    public func setOverride(value: Bool?, for key: String) {
        UserDefaults.standard.set(value, forKey: "\(FeatureFlagOverrideStore.keyPrefix).\(key)")
    }
    
    public func overrideValue(for key: String) -> Bool? {
        guard let value = UserDefaults.standard.object(forKey: "\(FeatureFlagOverrideStore.keyPrefix).\(key)") as? Bool else {
            return nil
        }
        return value
    }
    

}
