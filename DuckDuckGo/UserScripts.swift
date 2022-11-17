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

final class UserScripts: UserScriptsProvider {

    let contentBlockerUserScript: ContentBlockerRulesUserScript
    let surrogatesScript: SurrogatesUserScript
    let autofillUserScript: AutofillUserScript
    let loginFormDetectionScript: LoginFormDetectionUserScript?
    let doNotSellScript: DoNotSellUserScript?

    private(set) var faviconScript = FaviconUserScript()
    private(set) var fingerprintScript = FingerprintUserScript()
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

        loginFormDetectionScript = sourceProvider.loginDetectionEnabled ? LoginFormDetectionUserScript() : nil
        doNotSellScript = sourceProvider.sendDoNotSell ? DoNotSellUserScript() : nil
    }

    lazy var userScripts: [UserScript] = [
        debugScript,
        textSizeUserScript,
        findInPageScript,
        navigatorPatchScript,
        surrogatesScript,
        contentBlockerUserScript,
        fingerprintScript,
        faviconScript,
        fullScreenVideoScript,
        autofillUserScript,
        printingUserScript,
        loginFormDetectionScript,
        doNotSellScript
    ].compactMap({ $0 })

    lazy var scripts = userScripts.map { $0.makeWKUserScript() }

}
