//
//  ScriptSourceProviding.swift
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
import Core
import Combine
import BrowserServicesKit

protocol ScriptSourceProviding {

    var loginDetectionEnabled: Bool { get }
    var sendDoNotSell: Bool { get }
    var contentBlockerRulesConfig: ContentBlockerUserScriptConfig { get }
    var surrogatesConfig: SurrogatesUserScriptConfig { get }
    var privacyConfigurationManager: PrivacyConfigurationManaging { get }
    var autofillSourceProvider: AutofillUserScriptSourceProvider { get }
    var sessionKey: String { get }

}

struct DefaultScriptSourceProvider: ScriptSourceProviding {

    var loginDetectionEnabled: Bool { PreserveLogins.shared.loginDetectionEnabled }
    let sendDoNotSell: Bool
    
    let contentBlockerRulesConfig: ContentBlockerUserScriptConfig
    let surrogatesConfig: SurrogatesUserScriptConfig
    let autofillSourceProvider: AutofillUserScriptSourceProvider
    let sessionKey: String

    let privacyConfigurationManager: PrivacyConfigurationManaging
    let contentBlockingManager: ContentBlockerRulesManagerProtocol

    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         contentBlockingManager: ContentBlockerRulesManagerProtocol = ContentBlocking.shared.contentBlockingManager) {

        self.sendDoNotSell = appSettings.sendDoNotSell

        self.privacyConfigurationManager = privacyConfigurationManager
        self.contentBlockingManager = contentBlockingManager

        self.contentBlockerRulesConfig = Self.buildContentBlockerRulesConfig(contentBlockingManager: contentBlockingManager,
                                                                             privacyConfigurationManager: privacyConfigurationManager)
        self.surrogatesConfig = Self.buildSurrogatesConfig(contentBlockingManager: contentBlockingManager,
                                                           privacyConfigurationManager: privacyConfigurationManager)
        self.sessionKey = Self.generateSessionKey()
        self.autofillSourceProvider = Self.buildAutofillSource(gpcEnabled: self.sendDoNotSell,
                                                               sessionKey: self.sessionKey,
                                                               privacyConfigurationManager: privacyConfigurationManager)
    }

    private static func generateSessionKey() -> String {
        return UUID().uuidString
    }

    public static func buildAutofillSource(gpcEnabled: Bool,
                                           sessionKey: String,
                                           privacyConfigurationManager: PrivacyConfigurationManaging) -> AutofillUserScriptSourceProvider {
        let prefs = ContentScopeProperties(gpcEnabled: gpcEnabled,
                                           sessionKey: sessionKey,
                                           featureToggles: ContentScopeFeatureToggles.supportedFeaturesOniOS)

        return DefaultAutofillSourceProvider(privacyConfigurationManager: privacyConfigurationManager, properties: prefs)
    }

    private static func buildContentBlockerRulesConfig(contentBlockingManager: ContentBlockerRulesManagerProtocol,
                                                       privacyConfigurationManager: PrivacyConfigurationManaging) -> ContentBlockerUserScriptConfig {

        let currentMainRules = contentBlockingManager.currentMainRules
        let privacyConfig = privacyConfigurationManager.privacyConfig

        return DefaultContentBlockerUserScriptConfig(privacyConfiguration: privacyConfig,
                                                     trackerData: currentMainRules?.trackerData,
                                                     ctlTrackerData: nil,
                                                     tld: AppDependencyProvider.shared.storageCache.current.tld,
                                                     trackerDataManager: ContentBlocking.shared.trackerDataManager)
    }

    private static func buildSurrogatesConfig(contentBlockingManager: ContentBlockerRulesManagerProtocol,
                                              privacyConfigurationManager: PrivacyConfigurationManaging) -> SurrogatesUserScriptConfig {

        let surrogates = FileStore().loadAsString(forConfiguration: .surrogates) ?? ""
        let currentMainRules = contentBlockingManager.currentMainRules

        let surrogatesConfig = DefaultSurrogatesUserScriptConfig(privacyConfig: privacyConfigurationManager.privacyConfig,
                                                                 surrogates: surrogates,
                                                                 trackerData: currentMainRules?.trackerData,
                                                                 encodedSurrogateTrackerData: currentMainRules?.encodedTrackerData,
                                                                 trackerDataManager: ContentBlocking.shared.trackerDataManager,
                                                                 tld: AppDependencyProvider.shared.storageCache.current.tld,
                                                                 isDebugBuild: isDebugBuild)

        return surrogatesConfig
    }

}
