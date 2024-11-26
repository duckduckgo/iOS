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

final class SpecialErrorPageNavigationHandler: BaseSpecialErrorPageNavigationHandling {
    private var webView: WKWebView?
    private(set) var errorData: SpecialErrorData?
    private var errorPageType: SpecialErrorKind?
    private(set) var isSpecialErrorPageVisible = false
    private(set) var failedURL: URL?
    private weak var userScript: SpecialErrorPageUserScript?
    weak var delegate: SpecialErrorPageNavigationDelegate?

    private let sslErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling & SpecialErrorPageActionHandler
    private let maliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandling & SpecialErrorPageActionHandler

    init(
        sslErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling & SpecialErrorPageActionHandler = SSLErrorPageNavigationHandler(),
        maliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandling & SpecialErrorPageActionHandler = MaliciousSiteProtectionNavigationHandler()
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

    func handleSpecialErrorNavigation(navigationAction: WKNavigationAction, webView: WKWebView) async -> Bool {
        let result = await maliciousSiteProtectionNavigationHandler.handleMaliciousSiteProtectionNavigation(for: navigationAction, webView: webView)

        return await MainActor.run {
            switch result {
            case let .navigationHandled(model):
                var request = navigationAction.request
                request.url = model.url
                failedURL = model.url
                errorData = model.error
                errorPageType = .phishing
                loadSpecialErrorPage(request: request)
                return true
            case .navigationNotHandled:
                return false
            }
        }
    }
    
    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else { return }

        sslErrorPageNavigationHandler.handleServerTrustChallenge(challenge, completionHandler: completionHandler)
    }
    
    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WebViewNavigation, withError error: NSError) {
        guard let (url, sslErrorType, specialErrorData) = sslErrorPageNavigationHandler.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error) else { return }
        failedURL = url
        sslErrorPageNavigationHandler.errorPageVisited(errorType: sslErrorType)
        errorData = specialErrorData
        errorPageType = .ssl
        loadSpecialErrorPage(url: url)
    }
    
    func handleWebView(_ webView: WKWebView, didFinish navigation: WebViewNavigation) {
        userScript?.isEnabled = webView.url == failedURL
        if webView.url != failedURL {
            isSpecialErrorPageVisible = false
        }
    }

}

// MARK: - SpecialErrorPageUserScriptDelegate

extension SpecialErrorPageNavigationHandler: SpecialErrorPageUserScriptDelegate {

    func leaveSite() {
        switch errorPageType {
        case .ssl:
            sslErrorPageNavigationHandler.leaveSite()
        case .phishing:
            maliciousSiteProtectionNavigationHandler.leaveSite()
        default:
            break
        }

        if webView?.canGoBack == true {
            _ = webView?.goBack()
        } else {
            delegate?.closeSpecialErrorPageTab()
        }
    }

    func visitSite() {
        switch errorPageType {
        case .ssl:
            sslErrorPageNavigationHandler.visitSite()
        case .phishing:
            maliciousSiteProtectionNavigationHandler.visitSite()
        default:
            break
        }

        isSpecialErrorPageVisible = false
        _ = webView?.reload()
    }

    func advancedInfoPresented() {
        switch errorPageType {
        case .ssl:
            sslErrorPageNavigationHandler.advancedInfoPresented()
        case .phishing:
            maliciousSiteProtectionNavigationHandler.advancedInfoPresented()
        default:
            break
        }
    }
}

// MARK: Private

private extension SpecialErrorPageNavigationHandler {

    func loadSpecialErrorPage(url: URL) {
        loadSpecialErrorPage(request: URLRequest(url: url))
    }

    func loadSpecialErrorPage(request: URLRequest) {
        let html = SpecialErrorPageHTMLTemplate.htmlFromTemplate
        webView?.loadSimulatedRequest(request, responseHTML: html)
        isSpecialErrorPageVisible = true
    }

}
