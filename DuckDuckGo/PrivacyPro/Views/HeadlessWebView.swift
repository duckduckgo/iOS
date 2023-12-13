//
//  HeadlessWebView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import UserScript
import SwiftUI
import DesignResourcesKit
import Core

struct HeadlessWebview: UIViewRepresentable {
    let userScript: UserScriptMessaging
    let subFeature: Subfeature
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript.makeWKUserScriptSync())
        userContentController.addHandler(userScript)
        userScript.registerSubfeature(delegate: subFeature)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // We're using the macOS agent as the config for iOS has not been deployed in test env
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        // DefaultUserAgentManager.shared.update(webView: webView, isDesktop: false, url: url)

        webView.load(URLRequest(url: url))
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct AsyncHeadlessWebView: View {
    let url: URL
    let userScript: UserScriptMessaging
    let subFeature: Subfeature

    var body: some View {
        GeometryReader { geometry in
            HeadlessWebview(userScript: userScript,
                            subFeature: subFeature,
                            url: url)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
