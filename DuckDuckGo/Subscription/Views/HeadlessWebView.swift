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
    @Binding var url: URL
    @Binding var shouldReload: Bool

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = makeUserContentController()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // We're using the macOS agent as the config for iOS has not been deployed in test env
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        // DefaultUserAgentManager.shared.update(webView: webView, isDesktop: false, url: url)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            webView.load(URLRequest(url: url))
        }
        
        webView.uiDelegate = context.coordinator
        
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if shouldReload {
            reloadView(uiView: uiView)
        }
    }
    
    @MainActor
    func reloadView(uiView: WKWebView) {
        uiView.reload()
        DispatchQueue.main.async {
            shouldReload = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @MainActor
    private func makeUserContentController() -> WKUserContentController {
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript.makeWKUserScriptSync())
        userContentController.addHandler(userScript)
        userScript.registerSubfeature(delegate: subFeature)
        return userContentController
    }
    
    class Coordinator: NSObject, WKUIDelegate {
        var webView: WKWebView?
        
        private func topMostViewController() -> UIViewController? {
            var topController: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }
                .first?
                .rootViewController
            while let presentedViewController = topController?.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel, handler: { _ in completionHandler(false) }))
            alertController.addAction(UIAlertAction(title: UserText.actionOK, style: .default, handler: { _ in completionHandler(true) }))

            if let topController = topMostViewController() {
                topController.present(alertController, animated: true, completion: nil)
            } else {
                completionHandler(false)
            }
        }
    }
}

struct AsyncHeadlessWebView: View {
    @Binding var url: URL
    let userScript: UserScriptMessaging
    let subFeature: Subfeature
    @Binding var shouldReload: Bool

    var body: some View {
        GeometryReader { geometry in
            HeadlessWebview(userScript: userScript,
                            subFeature: subFeature,
                            url: $url,
                            shouldReload: $shouldReload)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

}
