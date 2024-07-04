//
//  MockUserAgent.swift
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

import BrowserServicesKit
import Foundation
import WebKit

class MockUserAgentManager: UserAgentManager {

    private var userAgent = UserAgent()
    private var privacyConfig: PrivacyConfiguration
    
    init(privacyConfig: PrivacyConfiguration) {
        self.privacyConfig = privacyConfig
        prepareUserAgent()
    }
    
    private func prepareUserAgent() {
        let webview = WKWebView()
        webview.load(URLRequest.developerInitiated(URL(string: "about:blank")!))
        
        getDefaultAgent(webView: webview) { [weak self] agent in
            // Reference webview instance to keep it in scope and allow UA to be returned
            _ = webview
            
            guard let defaultAgent = agent else { return }
            self?.userAgent = UserAgent(defaultAgent: defaultAgent)
        }
    }
    
    public func userAgent(isDesktop: Bool) -> String {
        return userAgent.agent(forUrl: nil, isDesktop: isDesktop, privacyConfig: privacyConfig)
    }

    func userAgent(isDesktop: Bool, url: URL?) -> String {
        return userAgent.agent(forUrl: url, isDesktop: isDesktop)
    }

    public func update(request: inout URLRequest, isDesktop: Bool) {
        request.addValue(userAgent.agent(forUrl: nil, isDesktop: isDesktop, privacyConfig: privacyConfig), forHTTPHeaderField: "User-Agent")
    }

    public func update(webView: WKWebView, isDesktop: Bool, url: URL?) {
        let agent = userAgent.agent(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        webView.customUserAgent = agent
    }
    
    private func getDefaultAgent(webView: WKWebView, completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("navigator.userAgent") { (result, _) in
            let agent = result as? String
            completion(agent)
        }
    }
}
