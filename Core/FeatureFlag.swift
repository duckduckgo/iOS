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
    case autofillFailureReporting
    case autofillOnForExistingUsers
    case autofillUnknownUsernameCategorization
    case autofillPartialFormSaves
    case incontextSignup
    case autoconsentOnByDefault
    case history
    case newTabPageSections
    case duckPlayer
    case duckPlayerOpenInNewTab
    case sslCertificatesBypass
    case syncPromotionBookmarks
    case syncPromotionPasswords
    case onboardingHighlights
    case onboardingAddToDock
    case autofillSurveys
    case autcompleteTabs
    case textZoom
    case adAttributionReporting
    case aiChat
    case aiChatDeepLink
    case tabManagerMultiSelection

    /// https://app.asana.com/0/72649045549333/1208231259093710/f
    case networkProtectionUserTips

    /// https://app.asana.com/0/72649045549333/1208617860225199/f
    case networkProtectionEnforceRoutes
    
    /// https://app.asana.com/0/1208592102886666/1208613627589762/f
    case crashReportOptInStatusResetting

    /// https://app.asana.com/0/0/1208767141940869/f
    case privacyProFreeTrialJan25

    /// https://app.asana.com/0/1206226850447395/1206307878076518
    case webViewStateRestoration

    /// https://app.asana.com/0/72649045549333/1208944782348823/f
    case syncSeamlessAccountSwitching

    /// https://app.asana.com/0/1204167627774280/1209205869217377
    case aiChatNewTabPage

    case testExperiment

    /// Feature flag to enable / disable phishing and malware protection
    /// https://app.asana.com/0/1206329551987282/1207149365636877/f
    case maliciousSiteProtection
}

extension FeatureFlag: FeatureFlagDescribing {
    public var cohortType: (any FeatureFlagCohortDescribing.Type)? {
        switch self {
        case .privacyProFreeTrialJan25:
            PrivacyProFreeTrialExperimentCohort.self
        case .testExperiment:
            TestExperimentCohort.self
        default:
            nil
        }
    }

    public static var localOverrideStoreName: String = "com.duckduckgo.app.featureFlag.localOverrides"

    public var supportsLocalOverriding: Bool {
        switch self {
        case .textZoom:
            return true
        case .testExperiment:
            return true
        default:
            return false
        }
    }

    public var source: FeatureFlagSource {
        switch self {
        case .debugMenu:
            return .internalOnly()
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
        case .autofillFailureReporting:
            return .remoteReleasable(.feature(.autofillBreakageReporter))
        case .autofillOnForExistingUsers:
            return .remoteReleasable(.subfeature(AutofillSubfeature.onForExistingUsers))
        case .autofillUnknownUsernameCategorization:
            return .remoteReleasable(.subfeature(AutofillSubfeature.unknownUsernameCategorization))
        case .autofillPartialFormSaves:
            return .remoteReleasable(.subfeature(AutofillSubfeature.partialFormSaves))
        case .incontextSignup:
            return .remoteReleasable(.feature(.incontextSignup))
        case .autoconsentOnByDefault:
            return .remoteReleasable(.subfeature(AutoconsentSubfeature.onByDefault))
        case .history:
            return .remoteReleasable(.feature(.history))
        case .newTabPageSections:
            return .remoteDevelopment(.feature(.newTabPageImprovements))
        case .duckPlayer:
            return .remoteReleasable(.subfeature(DuckPlayerSubfeature.enableDuckPlayer))
        case .duckPlayerOpenInNewTab:
            return .remoteReleasable(.subfeature(DuckPlayerSubfeature.openInNewTab))
        case .sslCertificatesBypass:
            return .remoteReleasable(.subfeature(SslCertificatesSubfeature.allowBypass))
        case .syncPromotionBookmarks:
            return .remoteReleasable(.subfeature(SyncPromotionSubfeature.bookmarks))
        case .syncPromotionPasswords:
            return .remoteReleasable(.subfeature(SyncPromotionSubfeature.passwords))
        case .onboardingHighlights:
            return .internalOnly()
        case .onboardingAddToDock:
            return .internalOnly()
        case .autofillSurveys:
            return .remoteReleasable(.feature(.autofillSurveys))
        case .autcompleteTabs:
            return .remoteReleasable(.feature(.autocompleteTabs))
        case .networkProtectionUserTips:
            return .remoteReleasable(.subfeature(NetworkProtectionSubfeature.userTips))
        case .textZoom:
            return .remoteReleasable(.feature(.textZoom))
        case .networkProtectionEnforceRoutes:
            return .remoteReleasable(.subfeature(NetworkProtectionSubfeature.enforceRoutes))
        case .adAttributionReporting:
            return .remoteReleasable(.feature(.adAttributionReporting))
        case .crashReportOptInStatusResetting:
            return .internalOnly()
        case .privacyProFreeTrialJan25:
            return .remoteReleasable(.subfeature(PrivacyProSubfeature.privacyProFreeTrialJan25))
        case .aiChat:
            return .remoteReleasable(.feature(.aiChat))
        case .aiChatDeepLink:
            return .remoteReleasable(.subfeature(AIChatSubfeature.deepLink))
        case .tabManagerMultiSelection:
            return .internalOnly()
        case .webViewStateRestoration:
            return .remoteReleasable(.feature(.webViewStateRestoration))
        case .syncSeamlessAccountSwitching:
            return .remoteReleasable(.subfeature(SyncSubfeature.seamlessAccountSwitching))
        case .aiChatNewTabPage:
            return .enabled
        case .testExperiment:
            return .remoteReleasable(.subfeature(ExperimentTestSubfeatures.experimentTestAA))
        case .maliciousSiteProtection:
            return .remoteReleasable(.subfeature(MaliciousSiteProtectionSubfeature.onByDefault))
        }
    }
}

extension FeatureFlagger {
    public func isFeatureOn(_ featureFlag: FeatureFlag) -> Bool {
        return isFeatureOn(for: featureFlag)
    }

}

public enum PrivacyProFreeTrialExperimentCohort: String, FeatureFlagCohortDescribing {
    /// Control cohort with no changes applied.
    case control
    /// Treatment cohort where the experiment modifications are applied.
    case treatment
}

public enum TestExperimentCohort: String, FeatureFlagCohortDescribing {
    case control
    case treatment
}
