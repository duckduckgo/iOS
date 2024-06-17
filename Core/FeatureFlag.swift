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
    case autofillCredentialInjecting
    case autofillCredentialsSaving
    case autofillInlineIconCredentials
    case autofillAccessCredentialManagement
    case autofillPasswordGeneration
    case autofillOnByDefault
    case incontextSignup
    case autoconsentOnByDefault
    case history
    case historyRollout
    case homeTabImprovements
}

extension FeatureFlag: FeatureFlagSourceProviding {
    public var source: FeatureFlagSource {
        switch self {
        case .debugMenu:
            return .internalOnly
        case .sync:
            return .remoteReleasable(.subfeature(SyncSubfeature.level0ShowSync))
        case .autofillCredentialInjecting:
            return .remoteReleasable(.subfeature(AutofillSubfeature.credentialsAutofill))
        case .autofillCredentialsSaving:
            return .remoteReleasable(.subfeature(AutofillSubfeature.credentialsSaving))
        case .autofillInlineIconCredentials:
            return .remoteReleasable(.subfeature(AutofillSubfeature.inlineIconCredentials))
        case .autofillAccessCredentialManagement:
            return .remoteReleasable(.subfeature(AutofillSubfeature.accessCredentialManagement))
        case .autofillPasswordGeneration:
            return .remoteReleasable(.subfeature(AutofillSubfeature.autofillPasswordGeneration))
        case .autofillOnByDefault:
            return .remoteReleasable(.subfeature(AutofillSubfeature.onByDefault))
        case .incontextSignup:
            return .remoteReleasable(.feature(.incontextSignup))
        case .autoconsentOnByDefault:
            return .remoteReleasable(.subfeature(AutoconsentSubfeature.onByDefault))
        case .history:
            return .remoteReleasable(.feature(.history))
        case .historyRollout:
            return .remoteReleasable(.subfeature(HistorySubFeature.onByDefault))
        case .homeTabImprovements:
            return .internalOnly
        }
    }
}

extension FeatureFlagger {
    public func isFeatureOn(_ featureFlag: FeatureFlag) -> Bool {
        return isFeatureOn(forProvider: featureFlag)
    }
}
