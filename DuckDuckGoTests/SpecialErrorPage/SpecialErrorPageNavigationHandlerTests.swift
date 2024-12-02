//
//  SpecialErrorPageNavigationHandlerTests.swift
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

import Testing
import WebKit
import SpecialErrorPages
@testable import DuckDuckGo

@Suite("Special Error Pages - SpecialErrorPageNavigationHandler Unit Tests", .serialized)
final class SpecialErrorPageNavigationHandlerTests {
    private var sut: SpecialErrorPageNavigationHandler!
    private var webView: MockSpecialErrorWebView!
    private var sslErrorPageNavigationHandler: MockSSLErrorPageNavigationHandler!

    @MainActor
    init() {
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass]
        webView = MockSpecialErrorWebView(frame: CGRect(), configuration: .nonPersistent())
        sslErrorPageNavigationHandler = MockSSLErrorPageNavigationHandler()
        sut = SpecialErrorPageNavigationHandler(
            sslErrorPageNavigationHandler: sslErrorPageNavigationHandler,
            maliciousSiteProtectionNavigationHandler: DummyMaliciousSiteProtectionNavigationHandler()
        )
    }

    deinit {
        sslErrorPageNavigationHandler = nil
        sut = nil
        webView = nil
    }

    @Test("Receive Challenge forward event to SSL Error Page Navigation Handler")
    func whenDidHandleWebViewReceiveChallengeIsCalledAskSSLErrorPageNavigationHandlerToHandleTheChallenge() {
        // GIVEN
        let protectionSpace = URLProtectionSpace(host: "", port: 4, protocol: nil, realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: ChallengeSender())
        #expect(sslErrorPageNavigationHandler.didCallHandleServerTrustChallenge == false)

        // WHEN
        sut.handleWebView(webView, didReceive: challenge) { _, _ in }

        // THEN
        #expect(sslErrorPageNavigationHandler.didCallHandleServerTrustChallenge)
    }

    @MainActor
    @Test("Leave Site forward event to SSL Error Page Navigation Handler")
    func whenLeaveSite_AndSSLError_ThenCallLeaveSiteOnSSLErrorPageNavigationHandler() {
        // GIVEN
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(!sslErrorPageNavigationHandler.didCallLeaveSite)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(sslErrorPageNavigationHandler.didCallLeaveSite)
    }

    @Test("Leave Site forward event to Malicious Site Protection Navigation Handler", .disabled("Will implement in upcoming PR"))
    func whenLeaveSite_AndPhishingError_ThenCallLeaveSiteOnMaliciousSiteProtectioneNavigationHandler() {

    }

    @MainActor
    @Test("Lave Site navigate Back")
    func whenLeaveSite_AndWebViewCanNavigateBack_ThenNavigateBack() {
        // GIVEN
        webView.setCanGoBack(true)
        sut.attachWebView(webView)
        #expect(!webView.didCallGoBack)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(webView.didCallGoBack)
    }

    @MainActor
    @Test("Lave Site close Tab")
    func whenLeaveSite_AndWebViewCannotNavigateBack_ThenAskDelegateToCloseTab() {
        // GIVEN
        webView.setCanGoBack(false)
        let delegate = SpySpecialErrorPageNavigationDelegate()
        sut.delegate = delegate
        sut.attachWebView(webView)
        #expect(!delegate.didCallCloseSpecialErrorPageTab)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(delegate.didCallCloseSpecialErrorPageTab)
    }

    @MainActor
    @Test("Visit Site forward event to SSL Error Page Navigation Handler")
    func whenVisitSite_AndSSLError_ThenCallVisitSiteOnSSLErrorPageNavigationHandler() throws {
        // GIVEN
        let url = try #require(URL(string: "https://example.com"))
        webView.setCurrentURL(url)
        sut.attachWebView(webView)
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(!sslErrorPageNavigationHandler.didCallVisitSite)

        // WHEN
        sut.visitSiteAction()

        // THEN
        #expect(sslErrorPageNavigationHandler.didCallVisitSite)
    }

    @Test("Visit Site forward event to Malicious Site Protection Navigation Handler", .disabled("Will implement in upcoming PR"))
    func whenVisitSite_AndPhishingError_ThenCallVisitSiteOnMaliciousSiteProtectioneNavigationHandler() {

    }

    @MainActor
    @Test("Visit Site reset isSpecialErrorPageVisible and reload page")
    func whenVisitSite_ThenSetIsSpecialErrorPageVisibleToFalseAndReloadPage() {
        // GIVEN
        sut.attachWebView(webView)
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(sut.isSpecialErrorPageVisible)
        #expect(!webView.didCallReload)

        // WHEN
        sut.visitSiteAction()

        // THEN
        #expect(!sut.isSpecialErrorPageVisible)
        #expect(webView.didCallReload)
    }

    @MainActor
    @Test("Advanced Info Presented forward event to SSL Error Page Navigation Handler")
    func whenAdvancedInfoPresented_AndSSLError_ThenCallAdvancedInfoPresentedOnSSLErrorPageNavigationHandler() {
        // GIVEN
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(!sslErrorPageNavigationHandler.didCalladvancedInfoPresented)

        // WHEN
        sut.advancedInfoPresented()

        // THEN
        #expect(sslErrorPageNavigationHandler.didCalladvancedInfoPresented)
    }

    @Test("Advanced Info Presented forward event to Malicious Site Protection Navigation Handler", .disabled("Will implement in upcoming PR"))
    func whenAdvancedInfoPresented_AndPhishingError_ThenCallAdvancedInfoPresentedOnMaliciousSiteProtectionNavigationHandler() {

    }
}

private extension NSError {

    static let genericSSL = NSError(
        domain: "test",
        code: NSURLErrorServerCertificateUntrusted,
        userInfo: [
            "_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
            NSURLErrorFailingURLErrorKey: URL(string: "https://untrusted-root.badssl.com")!
        ]
    )

}
