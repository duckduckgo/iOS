//
//  AMPCanonicalExtractor.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import WebKit

public class AMPCanonicalExtractor: NSObject {
    
    public static let shared = AMPCanonicalExtractor()
    
    struct Constants {
        static let sendCanonical = "sendCanonical"
        static let canonicalKey = "canonical"
        static let ruleListIdentifier = "blockImageRules"
    }
    
    private var webView: WKWebView?
    private var completion: ((URL?) -> Void)?
    
    private var imageBlockingRules: WKContentRuleList?
    
    override init() {
        super.init()
        
        let ruleSource = """
[
    {
        "trigger": {
            "url-filter": ".*",
            "resource-type": ["image"]
        },
        "action": {
            "type": "block"
        }
    },
    {
        "trigger": {
            "url-filter": ".*",
            "resource-type": ["style-sheet"]
        },
        "action": {
            "type": "block"
        }
    },
]
"""
        
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: Constants.ruleListIdentifier,
                                                                encodedContentRuleList: ruleSource) { [weak self] ruleList, error  in
            guard error != nil else {
                print(error?.localizedDescription ?? "AMPCanonicalExtractor - Error compiling image blocking rules")
                return
            }
            
            self?.imageBlockingRules = ruleList
        }
    }
    
    public func urlContainsAmpKeyword(_ url: URL?,
                                      config: PrivacyConfiguration = PrivacyConfigurationManager.shared.privacyConfig) -> Bool {
        LinkCleaner.shared.resetLastAmpUrl()
        guard let url = url, !LinkCleaner.shared.isURLExcluded(url: url, config: config) else { return false }
        let urlStr = url.absoluteString
        
        let ampKeywords = TrackingLinkSettings(fromConfig: config).ampKeywords
        
        for keyword in ampKeywords {
            if urlStr.contains(keyword) {
                return true
            }
        }
        
        return false
    }
    
    private func buildUserScript() -> WKUserScript {
        let source = """
(function() {
    document.addEventListener('DOMContentLoaded', (event) => {
        const canonicalLinks = document.querySelectorAll('[rel="canonical"]')
        window.webkit.messageHandlers.\(Constants.sendCanonical).postMessage({
            \(Constants.canonicalKey): canonicalLinks.length > 0 ? canonicalLinks[0].href : undefined
        })
    })
})()
"""
        
        return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    }
    
    public func getCanonicalUrl(initiator: URL?, url: URL?,
                                config: PrivacyConfiguration = PrivacyConfigurationManager.shared.privacyConfig,
                                completion: @escaping ((URL?) -> Void)) {
        guard let url = url, !LinkCleaner.shared.isURLExcluded(url: url, config: config) else {
            completion(nil)
            return
        }
        
        if let initiator = initiator, LinkCleaner.shared.isURLExcluded(url: initiator, config: config) {
            completion(nil)
            return
        }
        
        self.completion = completion
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.add(self, name: Constants.sendCanonical)
        configuration.userContentController.addUserScript(buildUserScript())
        if let rulesList = ContentBlockerRulesManager.shared.currentRules?.rulesList {
            configuration.userContentController.add(rulesList)
        }
        if let imageBlockingRules = imageBlockingRules {
            configuration.userContentController.add(imageBlockingRules)
        }
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.load(URLRequest(url: url))
    }
    
}

extension AMPCanonicalExtractor: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Constants.sendCanonical else { return }
        
        webView = nil
        
        if let dict = message.body as? [String: AnyObject],
           let canonical = dict[Constants.canonicalKey] as? String {
            if let canonicalUrl = URL(string: canonical),
               !LinkCleaner.shared.isURLExcluded(url: canonicalUrl,
                                                 config: PrivacyConfigurationManager.shared.privacyConfig) {
                LinkCleaner.shared.setLastAmpUrl(canonicalUrl.absoluteString)
                completion?(canonicalUrl)
            } else {
                completion?(nil)
            }
        } else {
            completion?(nil)
        }
    }
}
