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
import MaliciousSiteProtection
@testable import DuckDuckGo

@Suite("Special Error Pages - SpecialErrorPageNavigationHandler Unit Tests", .serialized)
final class SpecialErrorPageNavigationHandlerTests {
    private var sut: SpecialErrorPageNavigationHandler!
    private var webView: MockSpecialErrorWebView!
    private var sslErrorPageNavigationHandler: MockSSLErrorPageNavigationHandler!
    private var maliciousSiteProtectionNavigationHandler: MockMaliciousSiteProtectionNavigationHandler!

    @MainActor
    init() {
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass]
        webView = MockSpecialErrorWebView(frame: CGRect(), configuration: .nonPersistent())
        sslErrorPageNavigationHandler = MockSSLErrorPageNavigationHandler()
        maliciousSiteProtectionNavigationHandler = MockMaliciousSiteProtectionNavigationHandler()
        sut = SpecialErrorPageNavigationHandler(
            sslErrorPageNavigationHandler: sslErrorPageNavigationHandler,
            maliciousSiteProtectionNavigationHandler: maliciousSiteProtectionNavigationHandler
        )
    }

    deinit {
        sslErrorPageNavigationHandler = nil
        sut = nil
        webView = nil
    }

    @MainActor
    @Test("Decide Policy For Navigation Action forwards event to Malicious Site Protection Handler")
    func whenHandleDecidePolicyForNavigationActionIsCalledThenAskMaliciousSiteProtectionNavigationHandlerToHandleNavigationAction() throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url))

        // WHEN
        sut.handleDecidePolicyFor(navigationAction: navigationAction, webView: webView)

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallHandleWebViewNavigationAction)
        #expect(maliciousSiteProtectionNavigationHandler.capturedNavigationAction == navigationAction)
    }

    @MainActor
    @Test("Provisional Navigation forwards event to Malicious Site Protection Handler")
    func whenHandleProvisionalNavigationThenAskMaliciousSiteProtectionNavigationHandlerToHandleTheDecision() async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        webView.setCurrentURL(url)

        // WHEN
        _ = await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallHandleMaliciousSiteProtectionNavigation)
        #expect(maliciousSiteProtectionNavigationHandler.capturedWebView == webView)
    }

//    @MainActor
//    @Test("Provisional Navigation returns not handled when navigation action is not found")
//    func whenHandleDecidePolicyForNavigationResponse_And_TaskIsNil_ThenReturnFalse() async throws {
//        // GIVEN
//        let url = try #require(URL(string: "https://www.example.com"))
//        webView.setCurrentURL(url)
//
//        // WHEN
//        let result = await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)
//
//        // THEN
//        #expect(result == .navigationNotHandled)
//    }

    @MainActor
    @Test(
        "When Main Frame Threat Then Load Bundled Response",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenHandleProvisionalNavigation_AndMainFrameThreat_ThenLoadBundledReponse(threat: ThreatKind) async throws {
        // GIVEN
        sut.attachWebView(webView)
        let url = try #require(URL(string: "https://www.example.com"))
        webView.setCurrentURL(url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        maliciousSiteProtectionNavigationHandler.result = .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        var didCallLoadSimulatedRequest = false
        webView.loadRequestHandler = { _, _ in
            didCallLoadSimulatedRequest = true
        }

        // WHEN
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        // THEN
        #expect(sut.isSpecialErrorPageRequest)
        #expect(sut.failedURL == url)
        #expect(sut.errorData == errorData)
        #expect(didCallLoadSimulatedRequest)
    }

    @MainActor
    @Test(
        "When iFrame Threat Then Load Bundled Response",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenHandleProvisionalNavigation_AndIFrameThreat_ThenLoadBundledReponse(threat: ThreatKind) async throws {
        // GIVEN
        sut.attachWebView(webView)
        let topFrameURL = try #require(URL(string: "https://www.example.com"))
        let iFrameURL = try  #require(URL(string: "https://www.iframe.example.com"))
        webView.setCurrentURL(iFrameURL)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: topFrameURL)
        maliciousSiteProtectionNavigationHandler.result = .navigationHandled(.iFrame(maliciousURL: iFrameURL, error: errorData))

        var didCallLoadSimulatedRequest = false
        webView.loadRequestHandler = { _, _ in
            didCallLoadSimulatedRequest = true
        }

        // WHEN
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        // THEN
        #expect(sut.isSpecialErrorPageRequest)
        #expect(sut.failedURL == iFrameURL)
        #expect(sut.errorData == errorData)
        #expect(didCallLoadSimulatedRequest)
    }

    @MainActor
    @Test(
        "When No Threat Found Set Special Error Page Request To False",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenHandleProvisionalNavigation_AndNoThreat_ThenSetSpecialRequestToFalse(threat: ThreatKind) async throws {
        // GIVEN
        sut.attachWebView(webView)
        let url = try #require(URL(string: "https://www.example.com"))
        webView.setCurrentURL(url)
        maliciousSiteProtectionNavigationHandler.result = .navigationNotHandled

        var didCallLoadSimulatedRequest = false
        webView.loadRequestHandler = { _, _ in
            didCallLoadSimulatedRequest = true
        }

        // WHEN
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        // THEN
        #expect(sut.isSpecialErrorPageRequest == false)
        #expect(sut.failedURL == nil)
        #expect(didCallLoadSimulatedRequest == false)
    }

    @MainActor
    @Test("Receive Challenge forwards event to SSL Error Page Navigation Handler")
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

    @MainActor
    @Test(
        "Leave Site forward event to Malicious Site Protection Navigation Handler",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenLeaveSite_AndMaliciousSiteError_ThenCallLeaveSiteOnMaliciousSiteProtectioneNavigationHandler(threat: ThreatKind) async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        webView.setCurrentURL(url)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicyFor(navigationAction: navigationAction, webView: webView)
        maliciousSiteProtectionNavigationHandler.result = .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        #expect(!maliciousSiteProtectionNavigationHandler.didCallLeaveSite)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallLeaveSite)
    }

    @MainActor
    @Test("Lave Site navigates Back when SSL Error")
    func whenLeaveSite_AndSSLError_AndWebViewCanNavigateBack_ThenNavigateBack() {
        // GIVEN
        webView.setCanGoBack(true)
        sut.attachWebView(webView)
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(!webView.didCallGoBack)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(webView.didCallGoBack)
    }

    @MainActor
    @Test("Lave Site closes Tab when SSL Error")
    func whenLeaveSite_AndSSLError_AndWebViewCannotNavigateBack_ThenAskDelegateToCloseTab() {
        // GIVEN
        webView.setCanGoBack(false)
        let delegate = SpySpecialErrorPageNavigationDelegate()
        sut.delegate = delegate
        sut.attachWebView(webView)
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(!delegate.didCallCloseSpecialErrorPageTab)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(delegate.didCallCloseSpecialErrorPageTab)
    }

    @MainActor
    @Test(
        "Lave Site closes Tab when Malicious Site Error",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenLeaveSite_AndMaliciousSiteError_AndWebViewCanNavigateBack_ThenCloseTab(threat: ThreatKind) async throws {
        // GIVEN
        webView.setCanGoBack(true)
        sut.attachWebView(webView)
        let url = try #require(URL(string: "https://example.com"))
        webView.setCurrentURL(url)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicyFor(navigationAction: navigationAction, webView: webView)
        maliciousSiteProtectionNavigationHandler.result = .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)
        let delegate = SpySpecialErrorPageNavigationDelegate()
        sut.delegate = delegate
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

    @MainActor
    @Test(
        "Visit Site forward event to Malicious Site Protection Navigation Handler",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenVisitSite_AndPhishingError_ThenCallVisitSiteOnMaliciousSiteProtectioneNavigationHandler(threat: ThreatKind) async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        webView.setCurrentURL(url)
        sut.attachWebView(webView)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicyFor(navigationAction: navigationAction, webView: webView)
        maliciousSiteProtectionNavigationHandler.result = .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        #expect(!maliciousSiteProtectionNavigationHandler.didCallVisitSite)

        // WHEN
        sut.visitSiteAction()

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallVisitSite)
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

    @MainActor
    @Test(
        "Advanced Info Presented forward event to Malicious Site Protection Navigation Handler",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenAdvancedInfoPresented_AndPhishingError_ThenCallAdvancedInfoPresentedOnMaliciousSiteProtectionNavigationHandler(threat: ThreatKind) async throws {
        let url = try #require(URL(string: "https://www.example.com"))
        webView.setCurrentURL(url)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicyFor(navigationAction: navigationAction, webView: webView)
        maliciousSiteProtectionNavigationHandler.result = .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        await sut.handleDidStart(provisionalNavigation: DummyWKNavigation(), webView: webView)

        #expect(!maliciousSiteProtectionNavigationHandler.didCallAdvancedInfoPresented)

        // WHEN
        sut.advancedInfoPresented()

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallAdvancedInfoPresented)
    }
}

private extension NSError {

    static let genericSSL = NSError(
        domain: NSURLErrorDomain,
        code: NSURLErrorServerCertificateUntrusted,
        userInfo: [
            "_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
            NSURLErrorFailingURLErrorKey: URL(string: "https://untrusted-root.badssl.com")!
        ]
    )

}
