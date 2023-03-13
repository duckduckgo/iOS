//
//  AutofillContentScopeFeatureToggles.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import LocalAuthentication
import BrowserServicesKit

final class AutofillFeatureConfiguration {
    private let privacyConfig: PrivacyConfiguration
    private let appSettings: AppSettings

    init(appSettings: AppSettings, privacyConfig: PrivacyConfiguration) {
        self.appSettings = appSettings
        self.privacyConfig = privacyConfig
    }

    var isCredentialsAutofillFeatureFlagEnabled: Bool {
        privacyConfig.isEnabled(subfeature: AutofillFeature.credentialsAutofill.rawValue, for: .autofill)
    }
    
    var isCredentialsAutofillEnabled: Bool {
        let context = LAContext()
        var error: NSError?
        let canAuthenticate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return isCredentialsAutofillFeatureFlagEnabled && appSettings.autofillCredentialsEnabled && canAuthenticate
    }
    
    var supportedFeaturesOniOS: ContentScopeFeatureToggles {
        ContentScopeFeatureToggles(emailProtection: privacyConfig.isEnabled(subfeature: AutofillFeature.emailProtection.rawValue, for: .autofill),
                                   credentialsAutofill: isCredentialsAutofillEnabled,
                                   identitiesAutofill: false,
                                   creditCardsAutofill: false,
                                   credentialsSaving: isCredentialsAutofillEnabled,
                                   passwordGeneration: false,
                                   inlineIconCredentials: isCredentialsAutofillEnabled,
                                   thirdPartyCredentialsProvider: false)
    }
}

private enum AutofillFeature: String {
    case emailProtection
    case credentialsAutofill
    case credentialsSaving
}
