//
//  UserScripts.swift
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
import BrowserServicesKit
import TrackerRadarKit
import UserScript
import WebKit

final class UserScripts: UserScriptsProvider {

    let contentBlockerUserScript: ContentBlockerRulesUserScript
    let surrogatesScript: SurrogatesUserScript
    let autofillUserScript: AutofillUserScript
    let loginFormDetectionScript: LoginFormDetectionUserScript?
    let contentScopeUserScript: ContentScopeUserScript
    let autoconsentUserScript: AutoconsentUserScript

    private(set) var faviconScript = FaviconUserScript()
    private(set) var navigatorPatchScript = NavigatorSharePatchUserScript()
    private(set) var findInPageScript = FindInPageUserScript()
    private(set) var fullScreenVideoScript = FullScreenVideoUserScript()
    private(set) var printingUserScript = PrintingUserScript()
    private(set) var textSizeUserScript = TextSizeUserScript(textSizeAdjustmentInPercents: AppDependencyProvider.shared.appSettings.textSize)
    private(set) var debugScript = DebugUserScript()

    init(with sourceProvider: ScriptSourceProviding) {
        contentBlockerUserScript = ContentBlockerRulesUserScript(configuration: sourceProvider.contentBlockerRulesConfig)
        surrogatesScript = SurrogatesUserScript(configuration: sourceProvider.surrogatesConfig)
        autofillUserScript = AutofillUserScript(scriptSourceProvider: sourceProvider.autofillSourceProvider)
        autofillUserScript.sessionKey = sourceProvider.contentScopeProperties.sessionKey

        loginFormDetectionScript = sourceProvider.loginDetectionEnabled ? LoginFormDetectionUserScript() : nil
        contentScopeUserScript = ContentScopeUserScript(sourceProvider.privacyConfigurationManager,
                                                        properties: sourceProvider.contentScopeProperties)
        autoconsentUserScript = AutoconsentUserScript(config: sourceProvider.privacyConfigurationManager.privacyConfig)
    }

    lazy var userScripts: [UserScript] = [
        debugScript,
        textSizeUserScript,
        autoconsentUserScript,
        findInPageScript,
        navigatorPatchScript,
        surrogatesScript,
        contentBlockerUserScript,
        faviconScript,
        fullScreenVideoScript,
        autofillUserScript,
        printingUserScript,
        loginFormDetectionScript,
        contentScopeUserScript
    ].compactMap({ $0 })

    @MainActor
    func loadWKUserScripts() async -> [WKUserScript] {
        return await withTaskGroup(of: WKUserScriptBox.self) { @MainActor group in
            var wkUserScripts = [WKUserScript]()
            userScripts.forEach { userScript in
                group.addTask { @MainActor in
                    await userScript.makeWKUserScript()
                }
            }
            for await result in group {
                wkUserScripts.append(result.wkUserScript)
            }

            return wkUserScripts
        }
    }

}
