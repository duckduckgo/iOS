//
//  WebViewNavigationHandling.swift
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
import MaliciousSiteProtection

// MARK: - WebViewNavigation

/// For testing purposes.
protocol WebViewNavigation {}

// Used in tests. WKNavigation() crashes on deinit when initialising it manually.
// As workaround we used to Swizzle the implementation of deinit in tests.
// The problem with that approach is that when running different test suites it is possible that unrelated tests re-set the original implementation of deinit while other tests are running.
// This cause the app to crash as the original implementation is executed.
// Defining a protocol for WKNavigation and using mocks such as DummyWKNavigation in tests resolves the problem.
extension WKNavigation: WebViewNavigation {}

// MARK: - WebViewNavigationHandling

/// A protocol that defines methods for handling navigation events of `WKWebView`.
protocol WebViewNavigationHandling: AnyObject {
    /// Decides whether to cancel navigation to prevent opening a site and show a special error page based on the specified action information.
    ///
    /// - Parameters:
    ///   - navigationAction: Details about the action that triggered the navigation request.
    ///   - webView: The web view from which the navigation request began.
    @MainActor
    func handleDecidePolicy(for navigationAction: WKNavigationAction, webView: WKWebView)

    /// Decides whether to to navigate to new content after the response to the navigation request is known or cancel the navigation and show a special error page based on the specified action information.
    /// - Parameters:
    ///   - navigationResponse: Descriptive information about the navigation response.
    ///   - webView: The web view from which the navigation request began.
    /// - Returns: A Boolean value that indicates whether to cancel or allow the navigation.
    @MainActor
    func handleDecidePolicy(for navigationResponse: WKNavigationResponse, webView: WKWebView) async -> Bool

    /// Handles authentication challenges received by the web view.
    ///
    /// - Parameters:
    ///   - webView: The web view that receives the authentication challenge.
    ///   - challenge: The authentication challenge.
    ///   - completionHandler: A completion handler block to execute with the response.
    @MainActor
    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Handles failures during provisional navigation.
    ///
    /// - Parameters:
    ///   - webView: The `WKWebView` instance that failed the navigation.
    ///   - navigation: The navigation object for the operation.
    ///   - error: The error that occurred.
    @MainActor
    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WebViewNavigation, withError error: NSError)

    /// Handles the successful completion of a navigation in the web view.
    ///
    /// - Parameters:
    ///   - webView: The web view that loaded the content.
    ///   - navigation: The navigation object that finished.
    @MainActor
    func handleWebView(_ webView: WKWebView, didFinish navigation: WebViewNavigation)
}
