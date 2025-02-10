//
//  SpecialErrorPageNavigationHandler.swift
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
import SpecialErrorPages
import Core
import MaliciousSiteProtection

typealias SpecialErrorPageManaging = SpecialErrorPageContextHandling & WebViewNavigationHandling & SpecialErrorPageUserScriptDelegate

final class SpecialErrorPageNavigationHandler: SpecialErrorPageContextHandling {
    private weak var webView: WKWebView?
    private weak var userScript: SpecialErrorPageUserScript?
    weak var delegate: SpecialErrorPageNavigationDelegate?

    @MainActor private(set) var errorData: SpecialErrorData?
    @MainActor private(set) var isSpecialErrorPageVisible = false
    @MainActor private(set) var failedURL: URL?
    @MainActor private(set) var isSpecialErrorPageRequest = false

    private let sslErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling & SpecialErrorPageActionHandler
    private let maliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandling & SpecialErrorPageActionHandler

    var currentThreatKind: ThreatKind? {
        maliciousSiteProtectionNavigationHandler.currentThreatKind
    }

    init(
        sslErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling & SpecialErrorPageActionHandler = SSLErrorPageNavigationHandler(),
        maliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandling & SpecialErrorPageActionHandler
    ) {
        self.sslErrorPageNavigationHandler = sslErrorPageNavigationHandler
        self.maliciousSiteProtectionNavigationHandler = maliciousSiteProtectionNavigationHandler
    }

    func attachWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    func setUserScript(_ userScript: SpecialErrorPageUserScript?) {
        self.userScript = userScript
        userScript?.delegate = self
    }
}

// MARK: - WebViewNavigationHandling

extension SpecialErrorPageNavigationHandler: WebViewNavigationHandling {

    @MainActor
    func handleDecidePolicy(for navigationAction: WKNavigationAction, webView: WKWebView) {
        guard navigationAction.isTargetingMainFrame() else { return }
        maliciousSiteProtectionNavigationHandler.makeMaliciousSiteDetectionTask(for: navigationAction, webView: webView)
    }

    @MainActor
    func handleDecidePolicy(for navigationResponse: WKNavigationResponse, webView: WKWebView) async -> Bool {
        guard let task = maliciousSiteProtectionNavigationHandler.getMaliciousSiteDectionTask(for: navigationResponse, webView: webView) else {
            return false
        }

        let result = await task.value

        switch result {
        case let .navigationHandled(.mainFrame(response)):
            // Re-use the same request to avoid that the new sideload request is intercepted and cancelled
            // due to parameters added to the header.
            var request = response.navigationAction.request
            request.url = response.errorData.url
            isSpecialErrorPageRequest = true
            failedURL = response.errorData.url
            errorData = response.errorData
            loadSpecialErrorPage(request: request)
            return true
        case let .navigationHandled(.iFrame(maliciousURL, error)):
            isSpecialErrorPageRequest = true
            failedURL = maliciousURL
            errorData = error
            loadSpecialErrorPage(url: maliciousURL)
            return true
        case .navigationNotHandled:
            isSpecialErrorPageRequest = false
            isSpecialErrorPageVisible = false
            return false
        }
    }

    @MainActor
    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else { return }

        sslErrorPageNavigationHandler.handleServerTrustChallenge(challenge, completionHandler: completionHandler)
    }

    @MainActor
    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WebViewNavigation, withError error: NSError) {
        guard let sslSpecialError = sslErrorPageNavigationHandler.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error) else { return }
        failedURL = sslSpecialError.error.url
        sslErrorPageNavigationHandler.errorPageVisited(errorType: sslSpecialError.type)
        errorData = sslSpecialError.error.errorData
        loadSpecialErrorPage(url: sslSpecialError.error.url)
    }

    @MainActor
    func handleWebView(_ webView: WKWebView, didFinish navigation: WebViewNavigation) {
        isSpecialErrorPageRequest = false
        userScript?.isEnabled = webView.url == failedURL
        if webView.url != failedURL {
            isSpecialErrorPageVisible = false
        }
    }

}

// MARK: - SpecialErrorPageUserScriptDelegate

extension SpecialErrorPageNavigationHandler: SpecialErrorPageUserScriptDelegate {

    @MainActor
    func leaveSiteAction() {

        func navigateBackIfPossible() {
            if webView?.canGoBack == true {
                _ = webView?.goBack()
            } else {
                closeTab(shouldCreateNewTab: false)
            }
        }

        func closeTab(shouldCreateNewTab: Bool) {
            delegate?.closeSpecialErrorPageTab(shouldCreateNewEmptyTab: shouldCreateNewTab)
        }

        guard let errorData else { return }

        switch errorData {
        case .ssl:
            sslErrorPageNavigationHandler.leaveSite()
            navigateBackIfPossible()
        case .maliciousSite:
            maliciousSiteProtectionNavigationHandler.leaveSite()
            closeTab(shouldCreateNewTab: true)
        }
    }

    @MainActor
    func visitSiteAction() {
        defer {
            isSpecialErrorPageVisible = false
            _ = webView?.reload()
        }

        guard let errorData, let url = webView?.url else { return }

        switch errorData {
        case .ssl:
            sslErrorPageNavigationHandler.visitSite()
        case .maliciousSite:
            maliciousSiteProtectionNavigationHandler.visitSite(url: url, errorData: errorData)
        }
    }

    @MainActor
    func advancedInfoPresented() {
        guard let errorData else { return }

        switch errorData {
        case .ssl:
            sslErrorPageNavigationHandler.advancedInfoPresented()
        case .maliciousSite:
            maliciousSiteProtectionNavigationHandler.advancedInfoPresented()
        }
    }
}

// MARK: Private

private extension SpecialErrorPageNavigationHandler {

    @MainActor
    func loadSpecialErrorPage(url: URL) {
        loadSpecialErrorPage(request: URLRequest(url: url))
    }

    @MainActor
    func loadSpecialErrorPage(request: URLRequest) {
        let html = SpecialErrorPageHTMLTemplate.htmlFromTemplate
        webView?.loadSimulatedRequest(request, responseHTML: html)
        isSpecialErrorPageVisible = true
    }

}

// MARK: - Helpers

private extension SpecialErrorData {

    var url: URL? {
        switch self {
        case .ssl:
            return nil
        case let .maliciousSite(_, url):
            return url
        }
    }

}
