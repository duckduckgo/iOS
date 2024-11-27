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
import WebKit

/// WKWebsiteDataStore is basically non-functional until a web view has been instanciated and a page is successfully loaded.
public class DataStoreWarmup {

    public enum ApplicationState: String {
        case active
        case inactive
        case background
        case handlingShortcut
        case unknown
    }

    public init() { }

    @MainActor
    public func ensureReady(applicationState: ApplicationState) async {
        Pixel.fire(pixel: .webkitWarmupStart(appState: applicationState.rawValue))
        await BlockingNavigationDelegate().loadInBackgroundWebView(url: URL(string: "about:blank")!)
        Pixel.fire(pixel: .webkitWarmupFinished(appState: applicationState.rawValue))
    }

}

public class BlockingNavigationDelegate: NSObject, WKNavigationDelegate {

    var finished: PassthroughSubject? = PassthroughSubject<Void, Never>()

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        return .allow
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let finished {
            finished.send()
            self.finished = nil
        } else {
            Pixel.fire(pixel: .webKitWarmupUnexpectedDidFinish, includedParameters: [.appVersion])
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Pixel.fire(pixel: .webKitDidTerminateDuringWarmup)

        if let finished {
            finished.send()
            self.finished = nil
        } else {
            Pixel.fire(pixel: .webKitWarmupUnexpectedDidTerminate, includedParameters: [.appVersion])
        }
    }

    var cancellable: AnyCancellable?
    public func waitForLoad() async {
        await withCheckedContinuation { continuation in
            cancellable = finished?.sink { _ in
                continuation.resume()
            }
        }
    }

    @MainActor
    public func prepareWebView() -> WKWebView {
        let config = WKWebViewConfiguration.persistent()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        return webView
    }

    @MainActor
    public func loadInBackgroundWebView(url: URL) async {
        let webView = prepareWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        await waitForLoad()
    }

}
