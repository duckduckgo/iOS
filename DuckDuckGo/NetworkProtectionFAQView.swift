//
//  NetworkProtectionFAQView.swift
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
import WebKit
import SwiftUI
import Core

@MainActor
struct NetworkProtectionFAQView: View {

    enum Constants {
        static let frequentlyAskedQuestionsURL = URL(string: "https://duckduckgo.com/duckduckgo-help-pages/privacy-pro/vpn/")!
    }

    private var webView: NetworkProtectionWebView

    init() {
        self.webView = NetworkProtectionWebView(configuration: .nonPersistent())
        self.webView.load(url: Constants.frequentlyAskedQuestionsURL)
    }

    var body: some View {
        VStack {
            webView
                .ignoresSafeArea()
        }
        .navigationTitle(UserText.netPFrequentlyAskedQuestionsTitle)
    }

}

// MARK: - Private

private struct NetworkProtectionWebView: UIViewRepresentable {

    typealias View = WKWebView

    let wkWebView: View

    public init(configuration: WKWebViewConfiguration) {
        self.wkWebView = View(frame: .zero, configuration: configuration)
        self.wkWebView.allowsBackForwardNavigationGestures = true
    }

    func updateView(_ view: View) {
        wkWebView.reload()
    }

    public func load(url: URL) {
        let req = URLRequest(url: url)
        load(req)
    }

    public func load(_ urlRequest: URLRequest) {
        wkWebView.load(urlRequest)
    }

    func goBack() {
        wkWebView.goBack()
    }

    func goForward() {
        wkWebView.goForward()
    }

    func reload() {
        wkWebView.reload()
    }

    public func makeUIView(context: Context) -> View {
        return wkWebView
    }

    public func updateUIView(_ uiView: View, context: Context) {
        updateView(uiView)
    }

}
