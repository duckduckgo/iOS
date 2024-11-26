//
//  SpecialErrorPageInterfaces.swift
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
import Common
import SpecialErrorPages

// MARK: - WebViewNavigationHandling

/// A protocol that defines methods for handling navigation events of `WKWebView`.
protocol WebViewNavigationHandling: AnyObject {
    /// Decides whether to cancel navigation to prevent opening a site and show a special error page based on the specified action information.
    ///
    /// - Parameters:
    ///   - navigationAction: Details about the action that triggered the navigation request.
    ///   - webView: The web view from which the navigation request began.
    /// - Returns: A Boolean value that indicates whether the navigation action was handled.
    func handleSpecialErrorNavigation(navigationAction: WKNavigationAction, webView: WKWebView) async -> Bool

    /// Handles authentication challenges received by the web view.
    /// 
    /// - Parameters:
    ///   - webView: The web view that receives the authentication challenge.
    ///   - challenge: The authentication challenge.
    ///   - completionHandler: A completion handler block to execute with the response.
    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Handles failures during provisional navigation.
    ///
    /// - Parameters:
    ///   - webView: The `WKWebView` instance that failed the navigation.
    ///   - navigation: The navigation object for the operation.
    ///   - error: The error that occurred.
    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WebViewNavigation, withError error: NSError)

    /// Handles the successful completion of a navigation in the web view.
    ///
    /// - Parameters:
    ///   - webView: The web view that loaded the content.
    ///   - navigation: The navigation object that finished.
    func handleWebView(_ webView: WKWebView, didFinish navigation: WebViewNavigation)
}

// MARK: - SpecialErrorPageActionHandler

/// A type that defines actions for handling special error pages.
///
/// This protocol is intended to be adopted by types that need to manage user interactions
/// with special error pages, such as navigating to a site, leaving a site, or presenting
/// advanced information related to the error.
protocol SpecialErrorPageActionHandler {
    /// Handles the action of navigating to the site associated with the error page
    func visitSite()

    /// Handles the action of leaving the site associated with the error page
    func leaveSite()

    /// Handles the action of requesting more detailed information about the error
    func advancedInfoPresented()
}

// MARK: - BaseSpecialErrorPageNavigationHandling

/// A type that defines the base functionality for handling navigation related to special error pages.
protocol BaseSpecialErrorPageNavigationHandling: AnyObject {
    /// The delegate that handles navigation actions for special error pages.
    var delegate: SpecialErrorPageNavigationDelegate? { get set }

    /// A Boolean value indicating whether the special error page is currently visible.
    var isSpecialErrorPageVisible: Bool { get }

    /// The URL that failed to load, if any.
    var failedURL: URL? { get }

    /// Attaches a web view to the special error page handling.
    func attachWebView(_ webView: WKWebView)

    /// Sets the user script for the special error page.
    func setUserScript(_ userScript: SpecialErrorPageUserScript?)
}

typealias SpecialErrorPageNavigationHandling = BaseSpecialErrorPageNavigationHandling & WebViewNavigationHandling & SpecialErrorPageUserScriptDelegate

// MARK: - SpecialErrorPageNavigationDelegate

/// A delegate for handling navigation actions related to special error pages.
protocol SpecialErrorPageNavigationDelegate: AnyObject {
    /// Asks the delegate to close the special error page tab when the web view can't navigate back.
    func closeSpecialErrorPageTab()
}

protocol WebViewNavigation {}

extension WKNavigation: WebViewNavigation {}
