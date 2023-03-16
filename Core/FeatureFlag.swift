//
//  FeatureFlag.swift
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

public enum FeatureFlag: String {
    case debugMenu
    case sync
    case autofillCredentials
    case emailProtection
}

extension FeatureFlag: FeatureFlagSourceProviding {
    public var source: FeatureFlagSource {
        switch self {
        case .debugMenu, .sync:
            return .internalOnly
        case .autofillCredentials:
            return .remoteDevelopment { privacyConfig in
                privacyConfig.isSubfeatureEnabled(for: AutofillFeature.self, .credentialsAutofill)
            }
        case .emailProtection:
            return .remoteReleasable { privacyConfig in
                privacyConfig.isSubfeatureEnabled(for: AutofillFeature.self, .emailProtection)
            }
        }
    }
}

extension FeatureFlagger {
    public func isAppFeatureOn(_ feature: FeatureFlag) -> Bool {
        isFeatureOn(feature)
    }
}
