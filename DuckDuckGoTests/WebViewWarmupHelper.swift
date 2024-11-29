//
//  WebViewWarmupHelper.swift
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
import XCTest
import WebKit

public class WebViewWarmupHelper {

    private let delegate = WarmupNavigationDelegate()

    private var webView: WKWebView?

    public func warmupWebView(expectation: XCTestExpectation) {
        XCTAssertNil(webView)

        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = delegate
        self.webView = webView

        delegate.completion = { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        let request = URLRequest(url: URL(string: "about:blank")!)
        webView.load(request)
    }
}

private class WarmupNavigationDelegate: NSObject, WKNavigationDelegate {

    enum MockNavigationError: Error {
        case didTerminate
    }

    var completion: (Error?) -> Void = { _ in }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        return .allow
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        completion(nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        completion(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        completion(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        completion(MockNavigationError.didTerminate)
    }
}
