//
//  WKWebViewConfigurationExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import WebKit

extension WKWebViewConfiguration {
        
    public static func persistent() -> WKWebViewConfiguration {
        return configuration(persistsData: true)
    }

    public static func nonPersistent() -> WKWebViewConfiguration {
        return configuration(persistsData: false)
    }
    
    private static func configuration(persistsData: Bool) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        if !persistsData {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        configuration.dataDetectorTypes = [.phoneNumber]

        configuration.installContentBlockingRules()

        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.ignoresViewportScaleLimits = true

        return configuration
    }
    
    private func installContentBlockingRules() {
        func addRulesToController(rules: WKContentRuleList) {
            self.userContentController.add(rules)
        }
        
        if let rules = ContentBlockerRulesManager.shared.currentRules,
           PrivacyConfigurationManager.shared.privacyConfig.isEnabled(featureKey: .contentBlocking) {
            addRulesToController(rules: rules.rulesList)
        }
    }
    
    public func installContentRules(trackerProtection: Bool) {
        if trackerProtection {
            self.installContentBlockingRules()
        }
    }
    
    public func storeWebViewDataStore(containerName: String) {
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else { return }
        
        do {
            let archiver = try NSKeyedArchiver.archivedData(withRootObject: self.websiteDataStore, requiringSecureCoding: true)
            try archiver.write(to: docsDir.appendingPathComponent("\(containerName).tab"))
        } catch {
            Swift.print(">>>ERROR: \(error)")
        }
    }
    
    public static func loadContainerConfiguration(containerName: String) -> WKWebViewConfiguration {
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return WKWebViewConfiguration.nonPersistent()
        }
        
        let defaultConfig = WKWebViewConfiguration.nonPersistent()
        
        do {
            let dataStore = try NSKeyedUnarchiver
                                    .unarchivedObject(ofClass: WKWebsiteDataStore.self,
                                                      from: Data(contentsOf: docsDir.appendingPathComponent("\(containerName).tab")))
            if let dataStore = dataStore {
                defaultConfig.websiteDataStore = dataStore
            }
        } catch {
            Swift.print(">>>ERROR: \(error)")
        }
        
        return defaultConfig
    }
}
