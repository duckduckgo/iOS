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

    public static var ddgNameForUserAgent: String {
        return "DuckDuckGo/\(AppVersion.shared.majorVersionNumber)"
    }
    
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
        if #available(iOSApplicationExtension 10.0, *) {
            configuration.dataDetectorTypes = [.link, .phoneNumber]
        }

        if #available(iOS 11, *) {
            configuration.installHideAtbModals()
        }

        let defaultNameForUserAgent = configuration.applicationNameForUserAgent ?? ""
        configuration.applicationNameForUserAgent = "\(defaultNameForUserAgent) \(WKWebViewConfiguration.ddgNameForUserAgent)"
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.ignoresViewportScaleLimits = true

        return configuration
    }

    @available(iOS 11, *)
    private func installHideAtbModals() {
        guard let store = WKContentRuleListStore.default() else { return }
        let rules = """
        [
          {
            "trigger": {
              "url-filter": ".*",
              "if-domain": ["*duckduckgo.com"]
            },
            "action": {
              "type": "css-display-none",
              "selector": ".ddg-extension-hide"
            }
          }
        ]
        """
        store.compileContentRuleList(forIdentifier: "hide-extension-css", encodedContentRuleList: rules) { rulesList, _ in
            guard let rulesList = rulesList else { return }
            self.userContentController.add(rulesList)
        }
    }
}
