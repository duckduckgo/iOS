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
import BrowserServicesKit

public class AMPCanonicalExtractor: NSObject {

    class CompletionHandler {

        private var completion: ((URL?) -> Void)?

        func setCompletionHandler(completion: ((URL?) -> Void)?) {
            completeWithURL(nil)
            self.completion = completion
        }

        func completeWithURL(_ url: URL?) {
            // Make a copy of completion and set it to nil
            // This will prevent other callers before the completion has completed completing
            let compBlock = completion
            completion = nil
            compBlock?(url)
            
        }

    }

    struct Constants {
        static let sendCanonical = "sendCanonical"
        static let canonicalKey = "canonical"
        static let ruleListIdentifier = "blockImageRules"
    }

    private let completionHandler = CompletionHandler()

    private var webView: WKWebView?

    private var imageBlockingRules: WKContentRuleList?
    
    private var linkCleaner: LinkCleaner
    
    public init(linkCleaner: LinkCleaner) {
        self.linkCleaner = linkCleaner
        super.init()
        
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: Constants.ruleListIdentifier) { [weak self] ruleList, _ in
            if let ruleList = ruleList {
                self?.imageBlockingRules = ruleList
            } else {
                self?.compileImageRules()
            }
        }
    }
    
    private func compileImageRules() {
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
                Pixel.fire(pixel: .ampBlockingRulesCompilationFailed)
                return
            }
            
            self?.imageBlockingRules = ruleList
        }
    }
    
    public func urlContainsAmpKeyword(_ url: URL?,
                                      config: PrivacyConfiguration = ContentBlocking.privacyConfigurationManager.privacyConfig) -> Bool {
        linkCleaner.lastAmpUrl = nil
        guard config.isEnabled(featureKey: .ampLinks) else { return false }
        guard let url = url, !linkCleaner.isURLExcluded(url: url, config: config) else { return false }
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
    
    public func cancelOngoingExtraction() {
        webView?.stopLoading()
        webView = nil
        completionHandler.completeWithURL(nil)
    }

    public func getCanonicalUrl(initiator: URL?, url: URL?,
                                config: PrivacyConfiguration = ContentBlocking.privacyConfigurationManager.privacyConfig,
                                completion: @escaping ((URL?) -> Void)) {
        cancelOngoingExtraction()
        guard config.isEnabled(featureKey: .ampLinks) else {
            completion(nil)
            return
        }
        guard let url = url, !linkCleaner.isURLExcluded(url: url, config: config) else {
            completion(nil)
            return
        }
        
        if let initiator = initiator, linkCleaner.isURLExcluded(url: initiator, config: config) {
            completion(nil)
            return
        }
        
        self.completionHandler.setCompletionHandler(completion: completion)
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.add(self, name: Constants.sendCanonical)
        configuration.userContentController.addUserScript(buildUserScript())
        if let rulesList = ContentBlocking.contentBlockingManager.currentTDSRules?.rulesList {
            configuration.userContentController.add(rulesList)
        }
        if let imageBlockingRules = imageBlockingRules {
            configuration.userContentController.add(imageBlockingRules)
        }
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.navigationDelegate = self
        webView?.load(URLRequest(url: url))
    }

    deinit {
        completionHandler.completeWithURL(nil)
    }

}

extension AMPCanonicalExtractor: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Constants.sendCanonical else { return }
        
        webView = nil
        
        if let dict = message.body as? [String: AnyObject],
           let canonical = dict[Constants.canonicalKey] as? String {
            if let canonicalUrl = URL(string: canonical),
               !linkCleaner.isURLExcluded(url: canonicalUrl,
                                          config: ContentBlocking.privacyConfigurationManager.privacyConfig) {
                linkCleaner.lastAmpUrl = canonicalUrl.absoluteString
                completionHandler.completeWithURL(canonicalUrl)
            } else {
                completionHandler.completeWithURL(nil)
            }
        } else {
            completionHandler.completeWithURL(nil)
        }
    }
}

extension AMPCanonicalExtractor: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        completionHandler.completeWithURL(nil)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completionHandler.completeWithURL(nil)
    }
}
