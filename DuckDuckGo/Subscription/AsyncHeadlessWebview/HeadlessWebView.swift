//
//  HeadlessWebView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import SwiftUI
import WebKit
import UserScript
import BrowserServicesKit

struct HeadlessWebView: UIViewRepresentable {
    let userScript: UserScriptMessaging?
    let subFeature: Subfeature?
    let settings: AsyncHeadlessWebViewSettings
    var onScroll: ((CGPoint) -> Void)?
    var onURLChange: ((URL) -> Void)?
    var onCanGoBack: ((Bool) -> Void)?
    var onCanGoForward: ((Bool) -> Void)?
    var onContentType: ((String) -> Void)?
    var navigationCoordinator: HeadlessWebViewNavCoordinator
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = makeUserContentController()
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = settings.javascriptEnabled
        preferences.preferredContentMode = .mobile
         configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        webView.scrollView.bounces = settings.bounces
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = context.coordinator
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationCoordinator.webView = webView
        
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        context.coordinator.setupWebViewObservation(webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> HeadlessWebViewCoordinator {
        HeadlessWebViewCoordinator(self,
                    onScroll: onScroll,
                    onURLChange: onURLChange,
                    onCanGoBack: onCanGoBack,
                    onCanGoForward: onCanGoForward,
                    onContentType: onContentType,
                    settings: settings
        )
    }
    
    @MainActor
    private func makeUserContentController() -> WKUserContentController {
        let userContentController = WKUserContentController()
        
        // Enable content blocking rules
        if settings.contentBlocking {
            let sourceProvider = DefaultScriptSourceProvider()
            let contentBlockerUserScript = ContentBlockerRulesUserScript(configuration: sourceProvider.contentBlockerRulesConfig)
            let contentScopeUserScript = ContentScopeUserScript(sourceProvider.privacyConfigurationManager,
                                                                properties: sourceProvider.contentScopeProperties)
            userContentController.addUserScript(contentBlockerUserScript.makeWKUserScriptSync())
            userContentController.addUserScript(contentScopeUserScript.makeWKUserScriptSync())
        }
        
        if let userScript, let subFeature {
            userContentController.addUserScript(userScript.makeWKUserScriptSync())
            userContentController.addHandler(userScript)
            userScript.registerSubfeature(delegate: subFeature)
            
        }
        return userContentController
    }

}
