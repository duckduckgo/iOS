//
//  DoNotSellUserScript.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import UIKit
import WebKit
import BrowserServicesKit
import UserScript

public class DoNotSellUserScript: NSObject, UserScript {
    public var source: String {
        
        let privacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig

        let remoteUnprotectedDomains = (privacyConfiguration.tempUnprotectedDomains.joined(separator: "\n"))
            + "\n"
            + (privacyConfiguration.exceptionsList(forFeature: .gpc).joined(separator: "\n"))
        
        return Self.loadJS("donotsell", from: Bundle.core, withReplacements: [
            "$GPC_ENABLED$": ContentBlocking.shared.privacyConfigurationManager.privacyConfig
                .isEnabled(featureKey: .gpc) ? "true" : "false",
            "$TEMP_UNPROTECTED_DOMAINS$": remoteUnprotectedDomains,
            "$USER_UNPROTECTED_DOMAINS$": privacyConfiguration.userUnprotectedDomains.joined(separator: "\n")
        ])
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = []
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}
