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

struct HeadlessWebView: UIViewRepresentable {
    let userScript: UserScriptMessaging
    let subFeature: Subfeature
    @Binding var url: URL
    @Binding var shouldReload: Bool
    let ignoreTopSafeAreaInsets: Bool
    let onScroll: ((CGPoint) -> Void)?
    let bounces: Bool

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = makeUserContentController()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        DefaultUserAgentManager.shared.update(webView: webView, isDesktop: false, url: url)
        
        // Just add time if you need to hook the WebView inspector
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            webView.load(URLRequest(url: url))
        }
        
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        webView.scrollView.bounces = bounces
        
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Adjust content insets
        if ignoreTopSafeAreaInsets {
            let insets = UIEdgeInsets(top: -uiView.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
            uiView.scrollView.contentInset = insets
            uiView.scrollView.scrollIndicatorInsets = insets
        }
        
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
          Coordinator(self)
    }
    
    @MainActor
    private func makeUserContentController() -> WKUserContentController {
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript.makeWKUserScriptSync())
        userContentController.addHandler(userScript)
        userScript.registerSubfeature(delegate: subFeature)
        return userContentController
    }
    
    class Coordinator: NSObject, WKUIDelegate, UIScrollViewDelegate {
        var parent: HeadlessWebView
        var webView: WKWebView?
        
        init(_ parent: HeadlessWebView) {
            self.parent = parent
        }
        
        private func topMostViewController() -> UIViewController? {
            var topController: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }
                .first?
                .rootViewController
            while let presentedViewController = topController?.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }

        // MARK: WKUIDelegate
        
        // Enables presenting Javascript alerts via the native layer (window.confirm())
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
        
        // MARK: UIScrollViewDelegate
                
        // Detect scroll events and call onScroll function with the current scroll position
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let onScroll = parent.onScroll else { return }
            onScroll(scrollView.contentOffset)
        }
    }
}

struct AsyncHeadlessWebView: View {
    @Binding var url: URL
    let userScript: UserScriptMessaging
    let subFeature: Subfeature
    @Binding var shouldReload: Bool
    var ignoreTopSafeAreaInsets: Bool
    let onScroll: ((CGPoint) -> Void)?
    let bounces: Bool
    
    init(url: Binding<URL>,
         userScript: UserScriptMessaging,
         subFeature: Subfeature,
         shouldReload: Binding<Bool>,
         ignoreTopSafeAreaInsets: Bool = false,
         onScroll: ((CGPoint) -> Void)? = nil,
         bounces: Bool = false) {
           self._url = url
           self.userScript = userScript
           self.subFeature = subFeature
           self._shouldReload = shouldReload
           self.ignoreTopSafeAreaInsets = ignoreTopSafeAreaInsets
           self.onScroll = onScroll
            self.bounces = bounces
       }
    
    var body: some View {
        GeometryReader { geometry in
            HeadlessWebView(userScript: userScript,
                            subFeature: subFeature,
                            url: $url,
                            shouldReload: $shouldReload,
                            ignoreTopSafeAreaInsets: ignoreTopSafeAreaInsets,
                            onScroll: onScroll,
                            bounces: bounces)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .edgesIgnoringSafeArea(.all)
        }.edgesIgnoringSafeArea(.all)
    }
}
