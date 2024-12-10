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
    /// Handles the decision policy for navigation actions in a `WKWebView`.
    ///
    /// - Parameters:
    ///   - navigationAction: Details about the action that triggered the navigation request.
    ///   - webView: The web view from which the navigation request began.
    /// - Note: This method does not return a value or a decision policy parameter.
    ///   Any necessary actions based on the navigation action should be performed
    ///   within this method.
    @MainActor
    func handleDecidePolicyFor(navigationAction: WKNavigationAction, webView: WKWebView)

    /// Handles the event when a provisional navigation starts in a `WKWebView`.
    ///
    /// - Parameters:
    ///   - provisionalNavigation: The navigation object associated with the load request.
    ///   - webView: The web view that is loading the content.
    @MainActor
    func handleDidStart(provisionalNavigation: WebViewNavigation, webView: WKWebView) async

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
