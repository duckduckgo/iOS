//
//  HeadlessWebViewNavCoordinator.swift
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
import Core

final class HeadlessWebViewNavCoordinator {
    weak var webView: WKWebView?

    init(webView: WKWebView?) {
        self.webView = webView
    }

    func reload() async {
        _ = await MainActor.run {
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
        _ = await MainActor.run {
            self.webView?.goBack()
        }
    }

    func goForward() async {
        guard await webView?.canGoForward == true else { return }
        _ = await MainActor.run {
            self.webView?.goForward()
        }
    }
}
