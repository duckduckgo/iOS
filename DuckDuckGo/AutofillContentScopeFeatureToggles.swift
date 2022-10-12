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

extension ContentScopeFeatureToggles {
    
    static let featureFlagger = AppDependencyProvider.shared.featureFlagger
    static let appSettings = AppDependencyProvider.shared.appSettings
    
    static var isCredentialsAutofillEnabled: Bool {
        let context = LAContext()
        var error: NSError?
        let canAuthenticate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return featureFlagger.isFeatureOn(.autofill) && appSettings.autofillCredentialsEnabled && canAuthenticate
    }
    
    static var supportedFeaturesOniOS: ContentScopeFeatureToggles {
        ContentScopeFeatureToggles(emailProtection: true,
                                   credentialsAutofill: isCredentialsAutofillEnabled,
                                   identitiesAutofill: false,
                                   creditCardsAutofill: false,
                                   credentialsSaving: isCredentialsAutofillEnabled,
                                   passwordGeneration: false,
                                   inlineIconCredentials: isCredentialsAutofillEnabled)
    }
}
