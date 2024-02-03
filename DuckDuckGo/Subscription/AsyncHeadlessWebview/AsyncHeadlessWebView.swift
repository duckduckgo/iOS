//
//  AsyncHeadlessWebView.swift
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

struct AsyncHeadlessWebViewSettings {
    let bounces: Bool
    
    init(bounces: Bool = false) {
        self.bounces = bounces
    }
}

class NavigationCoordinator {
    weak var webView: WKWebView?

    init(webView: WKWebView?) {
        self.webView = webView
    }

    func reload() async {
        await MainActor.run {
            self.webView?.reload()
        }
    }
    
    func navigateTo(url: URL) {
        guard let webView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            DefaultUserAgentManager.shared.update(webView: webView, isDesktop: false, url: url)
            webView.load(URLRequest(url: url))
        }
    }

    func goBack() async {
        guard await webView?.canGoBack == true else { return }
        await MainActor.run {
            self.webView?.goBack()
        }
    }

    func goForward() async {
        guard await webView?.canGoForward == true else { return }
        await MainActor.run {
            self.webView?.goForward()
        }
    }
}

struct HeadlessWebView: UIViewRepresentable {
    let userScript: UserScriptMessaging?
    let subFeature: Subfeature?
    let settings: AsyncHeadlessWebViewSettings
    var onScroll: ((CGPoint) -> Void)?
    var onURLChange: ((URL) -> Void)?
    var onCanGoBack: ((Bool) -> Void)?
    var navigationCoordinator: NavigationCoordinator
    

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = makeUserContentController()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        navigationCoordinator.webView = webView
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        webView.scrollView.bounces = settings.bounces
        webView.navigationDelegate = context.coordinator
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onScroll: onScroll, onURLChange: onURLChange, onCanGoBack: onCanGoBack)
    }
    
    @MainActor
    private func makeUserContentController() -> WKUserContentController {
        let userContentController = WKUserContentController()
        if let userScript, let subFeature {
            userContentController.addUserScript(userScript.makeWKUserScriptSync())
            userContentController.addHandler(userScript)
            userScript.registerSubfeature(delegate: subFeature)
        }
        return userContentController
    }

    class Coordinator: NSObject, WKUIDelegate, UIScrollViewDelegate, WKNavigationDelegate {
        var parent: HeadlessWebView
        var onScroll: ((CGPoint) -> Void)?
        var onURLChange: ((URL) -> Void)?
        var onCanGoBack: ((Bool) -> Void)?

        init(_ parent: HeadlessWebView,
             onScroll: ((CGPoint) -> Void)?,
             onURLChange: ((URL) -> Void)?,
             onCanGoBack: ((Bool) -> Void)?) {
            self.parent = parent
            self.onScroll = onScroll
            self.onURLChange = onURLChange
            self.onCanGoBack = onCanGoBack
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let contentOffset = scrollView.contentOffset
            onScroll?(contentOffset)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let onURLChange {
                onURLChange(url)
            }
            if let onCanGoBack {
                onCanGoBack(webView.canGoBack)
            }
            decisionHandler(.allow)
        }
    }
}

struct AsyncHeadlessWebView: View {
    @StateObject var viewModel: AsyncHeadlessWebViewViewModel

    var body: some View {
        GeometryReader { geometry in
            HeadlessWebView(
                userScript: viewModel.userScript,
                subFeature: viewModel.subFeature,
                settings: viewModel.settings,
                onScroll: { newPosition in
                    viewModel.scrollPosition = newPosition
                },
                onURLChange: { newURL in
                    viewModel.url = newURL
                },
                onCanGoBack: { value in
                    viewModel.canGoBack = value
                },
                navigationCoordinator: viewModel.navigationCoordinator
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
