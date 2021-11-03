//
//  FingerprintUserScript.swift
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

public class FingerprintUserScript: NSObject, UserScript {
    public var source: String {
        let featureSettings =
        """
        {
            fingerprintingTemporaryStorage: \(PrivacyConfigurationManager.shared.privacyConfig
                .isEnabled(featureKey: .fingerprintingTemporaryStorage) ? "true" : "false"),
            fingerprintingBattery: \(PrivacyConfigurationManager.shared.privacyConfig
                                        .isEnabled(featureKey: .fingerprintingBattery) ? "true" : "false"),
            fingerprintingScreenSize: \(PrivacyConfigurationManager.shared.privacyConfig
                                            .isEnabled(featureKey: .fingerprintingScreenSize) ? "true" : "false"),
        }
        """
        
        let tempStorageExceptions = PrivacyConfigurationManager.shared.privacyConfig
            .exceptionsList(forFeature: .fingerprintingTemporaryStorage).joined(separator: "\n")
        let batteryExceptions = PrivacyConfigurationManager.shared.privacyConfig
            .exceptionsList(forFeature: .fingerprintingBattery).joined(separator: "\n")
        let screenSizeExceptions = PrivacyConfigurationManager.shared.privacyConfig
            .exceptionsList(forFeature: .fingerprintingScreenSize).joined(separator: "\n")
        
        return Self.loadJS("fingerprint", from: Bundle.core, withReplacements: [
            "$FEATURE_SETTINGS$": featureSettings,
            "$TEMP_STORAGE_EXCEPTIONS$": tempStorageExceptions,
            "$BATTERY_EXCEPTIONS$": batteryExceptions,
            "$SCREEN_SIZE_EXCEPTIONS$": screenSizeExceptions
        ])
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = []
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}
