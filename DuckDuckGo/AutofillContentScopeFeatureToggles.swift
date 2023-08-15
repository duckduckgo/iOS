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

    static var supportedFeaturesOniOS: ContentScopeFeatureToggles {
        let isAutofillEnabledInSettings = AutofillSettingStatus.isAutofillEnabledInSettings
        return ContentScopeFeatureToggles(emailProtection: true,
                                   emailProtectionIncontextSignup: featureFlagger.isFeatureOn(.incontextSignup) && Locale.current.isEnglishLanguage,
                                   credentialsAutofill: featureFlagger.isFeatureOn(.autofillCredentialInjecting) && isAutofillEnabledInSettings,
                                   identitiesAutofill: false,
                                   creditCardsAutofill: false,
                                   credentialsSaving: featureFlagger.isFeatureOn(.autofillCredentialsSaving) && isAutofillEnabledInSettings,
                                   passwordGeneration: featureFlagger.isFeatureOn(.autofillPasswordGeneration) && isAutofillEnabledInSettings,
                                   inlineIconCredentials: featureFlagger.isFeatureOn(.autofillInlineIconCredentials) && isAutofillEnabledInSettings,
                                   thirdPartyCredentialsProvider: false)
    }
}
