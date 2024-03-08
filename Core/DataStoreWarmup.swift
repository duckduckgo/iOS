//
//  DataStoreWarmup.swift
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

import Combine
import Macros
import WebKit

/// WKWebsiteDataStore is basically non-functional until a web view has been instanciated and a page is successfully loaded.
public class DataStoreWarmup {

    public init() { }

    @MainActor
    public func ensureReady() async {
        await BlockingNavigationDelegate().loadInBackgroundWebView(url: #URL("about:blank"))
    }

}

private class BlockingNavigationDelegate: NSObject, WKNavigationDelegate {

    let finished = PassthroughSubject<Void, Never>()

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        return .allow
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finished.send()
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Pixel.fire(pixel: .webKitDidTerminateDuringWarmup)
        // We won't get a `didFinish` if the webview crashes
        finished.send()
    }

    var cancellable: AnyCancellable?
    func waitForLoad() async {
        await withCheckedContinuation { continuation in
            cancellable = finished.sink { _ in
                continuation.resume()
            }
        }
    }

    @MainActor
    func loadInBackgroundWebView(url: URL) async {
        let config = WKWebViewConfiguration.persistent()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        let request = URLRequest(url: url)
        webView.load(request)
        await waitForLoad()
    }

}
