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
import BrowserServicesKit
import Core
import Common
import SpecialErrorPages
import WebKit

protocol SpecialErrorPageNavigationDelegate: AnyObject {
    func closeTabUponLeavingSpecialErrorPage()
}

protocol WebViewNavigationHandling: AnyObject {
    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError)

    func handleWebView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
}

protocol ThreatProtectionSpecialErrorPageNavigationHandling: AnyObject {
    func handleThreatProtectionNavigation(for navigationAction: WKNavigationAction, webView: WKWebView) async -> Bool
}

protocol GenericSpecialErrorPageNavigationHandling: AnyObject {
    var delegate: SpecialErrorPageNavigationDelegate? { get set }

    var isSpecialErrorPageVisible: Bool { get }

    var failedURL: URL? { get }

    func attachWebView(_ webView: WKWebView)
    func shouldEnableSpecialErrorPage() -> Bool
}

typealias SpecialErrorPageNavigationHandling = GenericSpecialErrorPageNavigationHandling & WebViewNavigationHandling & ThreatProtectionSpecialErrorPageNavigationHandling & SpecialErrorPageUserScriptDelegate

final class SpecialErrorPageNavigationHandler: GenericSpecialErrorPageNavigationHandling {
    private var webView: WKWebView?
    private(set) var errorData: SpecialErrorData?
    private(set) var isSpecialErrorPageVisible = false
    private(set) var failedURL: URL?
    weak var delegate: SpecialErrorPageNavigationDelegate?

    private let sslErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling & SpecialErrorPageActionHandler
    private let threatProtectionNavigationHandler: ThreatProtectionNavigationHandling & SpecialErrorPageActionHandler
    private let storageCache: StorageCache
    private let featureFlagger: FeatureFlagger

    init(
        sslErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling & SpecialErrorPageActionHandler = SSLErrorPageNavigationHandler(),
        threatProtectionNavigationHandler: ThreatProtectionNavigationHandling & SpecialErrorPageActionHandler = ThreatProtectionNavigationHandler(),
        storageCache: StorageCache = AppDependencyProvider.shared.storageCache,
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger
    ) {
        self.sslErrorPageNavigationHandler = sslErrorPageNavigationHandler
        self.threatProtectionNavigationHandler = threatProtectionNavigationHandler
        self.storageCache = storageCache
        self.featureFlagger = featureFlagger
    }

    func attachWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    func shouldEnableSpecialErrorPage() -> Bool {
        webView?.url == failedURL
    }
}

// MARK: Private

private extension SpecialErrorPageNavigationHandler {

    func loadSpecialErrorPage(url: URL) {
        let html = SpecialErrorPageHTMLTemplate.htmlFromTemplate
        webView?.loadSimulatedRequest(URLRequest(url: url), responseHTML: html)
        isSpecialErrorPageVisible = true
    }

}

// MARK: - SSLSpecialErrorPageNavigationHandling

extension SpecialErrorPageNavigationHandler: WebViewNavigationHandling {

    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        sslErrorPageNavigationHandler.handleServerTrustChallenge(challenge, completionHandler: completionHandler)
    }

    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        guard let (url, specialErrorData) = sslErrorPageNavigationHandler.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error, tld: storageCache.tld) else { return }
        failedURL = url
        sslErrorPageNavigationHandler.reportSSLErrorPageVisited()
        errorData = specialErrorData
        loadSpecialErrorPage(url: url)
    }

    func handleWebView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url != failedURL {
            isSpecialErrorPageVisible = false
        }
    }

}

// MARK: - ThreatProtectionSpecialErrorPageNavigationHandling

extension SpecialErrorPageNavigationHandler: ThreatProtectionSpecialErrorPageNavigationHandling {

    func handleThreatProtectionNavigation(for navigationAction: WKNavigationAction, webView: WKWebView) async -> Bool {
        let result = await threatProtectionNavigationHandler.handleThreatProtectionNavigation(for: navigationAction, webView: webView)

        return await MainActor.run {
            switch result {
            case let .handled(model):
                failedURL = model.url
                errorData = model.error
                loadSpecialErrorPage(url: model.url)
                return true
            case .notHandled:
                return false
            }
        }
    }

}

// MARK: - SpecialErrorPageUserScriptDelegate

extension SpecialErrorPageNavigationHandler: SpecialErrorPageUserScriptDelegate {

    func leaveSite() {
        sslErrorPageNavigationHandler.leaveSite()
        guard webView?.canGoBack == true else {
            delegate?.closeTabUponLeavingSpecialErrorPage()
            return
        }
        _ = webView?.goBack()
    }

    func visitSite() {
        sslErrorPageNavigationHandler.visitSite()
        isSpecialErrorPageVisible = false
        _ = webView?.reload()
    }

    func advancedInfoPresented() {
        sslErrorPageNavigationHandler.advancedInfoPresented()
    }
}


protocol SpecialErrorPageActionHandler {
    func visitSite()
    func leaveSite()
    func advancedInfoPresented()
}

protocol SSLSpecialErrorPageNavigationHandling {
    var failedURL: URL? { get }

    func handleServerTrustChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    func makeNewRequestURLAndSpecialErrorDataIfEnabled(error: NSError, tld: TLD) -> (url: URL, specialErrorData: SpecialErrorData)?

    func reportSSLErrorPageVisited()
}

final class SSLErrorPageNavigationHandler {
    private var shouldBypassSSLError = false

    private(set) var failedURL: URL?

    private let certificateTrustEvaluator: CertificateTrustEvaluating
    private let urlCredentialCreator: URLCredentialCreating
    private let featureFlagger: FeatureFlagger

    init(
        certificateTrustEvaluator: CertificateTrustEvaluating = CertificateTrustEvaluator(),
        urlCredentialCreator: URLCredentialCreating = URLCredentialCreator(),
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger
    ) {
        self.certificateTrustEvaluator = certificateTrustEvaluator
        self.urlCredentialCreator = URLCredentialCreator()
        self.featureFlagger = featureFlagger
    }
}

// MARK: - SSLSpecialErrorPageNavigationHandling

extension SSLErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling {

    func handleServerTrustChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard shouldBypassSSLError,
              let credential = urlCredentialCreator.urlCredentialFrom(trust: challenge.protectionSpace.serverTrust) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        shouldBypassSSLError = false
        completionHandler(.useCredential, credential)
    }

    func makeNewRequestURLAndSpecialErrorDataIfEnabled(error: NSError, tld: TLD) -> (url: URL, specialErrorData: SpecialErrorData)? {
        guard featureFlagger.isFeatureOn(.sslCertificatesBypass),
              error.code == NSURLErrorServerCertificateUntrusted,
              let errorCode = error.userInfo["_kCFStreamErrorCodeKey"] as? Int32,
              let failedURL = error.failedUrl else {
            return nil
        }

        let tld = tld
        let errorType = SSLErrorType.forErrorCode(Int(errorCode))
        self.failedURL = failedURL
        let errorData = SpecialErrorData(kind: .ssl,
                                         errorType: errorType.rawValue,
                                         domain: failedURL.host,
                                         eTldPlus1: tld.eTLDplus1(failedURL.host))

        return (failedURL, errorData)
    }

    func reportSSLErrorPageVisited() {
        //Pixel.fire(pixel: .certificateWarningDisplayed(errorType.rawParameter))
    }

}

// MARK: - SSLErrorPageNavigationHandler

extension SSLErrorPageNavigationHandler: SpecialErrorPageActionHandler {

    func leaveSite() {
        //Pixel.fire(pixel: .certificateWarningLeaveClicked)
    }

    func visitSite() {
        shouldBypassSSLError = true
    }

    func advancedInfoPresented() {
        //Pixel.fire(pixel: .certificateWarningAdvancedClicked)
    }
}
