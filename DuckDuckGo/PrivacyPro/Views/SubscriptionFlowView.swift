//
//  SubscriptionFlowView.swift
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
import SwiftUI
import WebKit
import BrowserServicesKit

struct SubscriptionWebView: UIViewRepresentable {
    let userScript: WKUserScript
    // let context: String
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)

        userContentController.add(context.coordinator, name: SubscriptionPagesUserScript.context)

        let configuration = webView.configuration
        configuration.userContentController = userContentController

        webView.load(URLRequest(url: url))
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Implement if needed to handle updates
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle the script message
        }
    }
}

struct AsyncSubscriptionWebView: View {
    @State private var userScript: WKUserScript?

    let url: URL
    let script: SubscriptionPagesUserScript
    
    var body: some View {
        GeometryReader { geometry in
            if let script = userScript {
                SubscriptionWebView(userScript: script, url: url)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear(perform: loadUserScript)
    }
    
    private func loadUserScript() {
        Task {
            userScript = await script.makeWKUserScript().wkUserScript
        }
    }
}

struct SubscriptionFlowView: View {
    let userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript()
    
    var body: some View {
        // Assuming URL.purchaseSubscription is a valid URL for subscription
        AsyncSubscriptionWebView(url: URL(string: "https://example.com/subscription")!, script: userScript)
    }
}
