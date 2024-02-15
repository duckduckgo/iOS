//
//  DataStoreReadiness.swift
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
import WebKit

public class DataStoreReadiness {

    public static let shared = DataStoreReadiness()

    private var blockingDelegate: BlockingNavigationDelegate? = BlockingNavigationDelegate()

    public func onClearData() {
        blockingDelegate = BlockingNavigationDelegate()
    }

    @MainActor
    public func ensureReady() async {
        print("***", #function, "IN")
        await blockingDelegate?.loadInBackgroundWebView(url: URL(string: "about:blank")!)
        blockingDelegate = nil
        print("***", #function, "OUT")
    }

}

private class BlockingNavigationDelegate: NSObject, WKNavigationDelegate {

    let finished = PassthroughSubject<Void, Never>()

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        print("***", #function, navigationAction.request.url?.absoluteString ?? "nil url")
        return .allow
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("***", #function)
        finished.send()
    }

    var cancellable: AnyCancellable?
    func waitForLoad() async {
        print("***", #function, "waiting")
        await withCheckedContinuation { continuation in
            cancellable = finished.sink { _ in
                print("***", #function, "resuming")
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
        print("***", #function, "waiting")
        await waitForLoad()
        print("***", #function, "resuming")
    }

    deinit {
        print("***", #function)
    }

}
