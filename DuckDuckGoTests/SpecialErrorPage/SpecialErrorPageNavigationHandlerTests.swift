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
    func whenHandleDecidePolicyForNavigationActionIsCalledThenAskMaliciousSiteProtectionNavigationHandlerToHandleTheDecision() throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))

        // WHEN
        sut.handleDecidePolicy(for: navigationAction, webView: webView)

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallHandleMaliciousSiteProtectionForNavigationAction)
        #expect(maliciousSiteProtectionNavigationHandler.capturedNavigationAction == navigationAction)
        #expect(maliciousSiteProtectionNavigationHandler.capturedWebView == webView)
    }

    @MainActor
    @Test("Decide Policy For Navigation Response forwards event to Malicious Site Protection Handler")
    func whenHandleDecidePolicyforNavigationResponseThenAskMaliciousSiteProtectionNavigationHandlerToHandleTheDecision() async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationResponse = MockNavigationResponse.with(url: url)

        // WHEN
        _ = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallHandleMaliciousSiteProtectionForNavigationResponse)
        #expect(maliciousSiteProtectionNavigationHandler.capturedNavigationResponse == navigationResponse)
        #expect(maliciousSiteProtectionNavigationHandler.capturedWebView == webView)
    }

    @MainActor
    @Test("Decide Policy For Navigation Response returns false when malicious site detection Task is not found")
    func whenHandleDecidePolicyForNavigationResponse_And_TaskIsNil_ThenReturnFalse() async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationResponse = MockNavigationResponse.with(url: url)
        maliciousSiteProtectionNavigationHandler.task = nil

        // WHEN
        let result = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

        // THEN
        #expect(result == false)
    }

    @MainActor
    @Test(
        "When Main Frame Threat Then Load Bundled Response And Return True",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenHandleDecidePolicyForNavigationResponse_AndMainFrameThreat_ThenLoadBundledReponseAndReturnTrue(threat: ThreatKind) async throws {
        // GIVEN
        sut.attachWebView(webView)
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        let navigationResponse = MockNavigationResponse.with(url: url)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        }
        var didCallLoadSimulatedRequest = false
        webView.loadRequestHandler = { _, _ in
            didCallLoadSimulatedRequest = true
        }

        // WHEN
        let result = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

        // THEN
        #expect(sut.isSpecialErrorPageRequest)
        #expect(sut.failedURL == url)
        #expect(sut.errorData == errorData)
        #expect(didCallLoadSimulatedRequest)
        #expect(result)
    }

    @MainActor
    @Test(
        "When iFrame Threat Then Load Bundled Response And Return True",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenHandleDecidePolicyForNavigationResponse_AndIFrameThreat_ThenLoadBundledReponseAndReturnTrue(threat: ThreatKind) async throws {
        // GIVEN
        sut.attachWebView(webView)
        let topFrameURL = try #require(URL(string: "https://www.example.com"))
        let iFrameURL = try  #require(URL(string: "https://www.iframe.example.com"))
        let navigationResponse = MockNavigationResponse.with(url: topFrameURL)
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: topFrameURL)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationHandled(.iFrame(maliciousURL: iFrameURL, error: errorData))
        }
        var didCallLoadSimulatedRequest = false
        webView.loadRequestHandler = { _, _ in
            didCallLoadSimulatedRequest = true
        }

        // WHEN
        let result = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

        // THEN
        #expect(sut.isSpecialErrorPageRequest)
        #expect(sut.failedURL == iFrameURL)
        #expect(sut.errorData == errorData)
        #expect(didCallLoadSimulatedRequest)
        #expect(result)
    }

    @MainActor
    @Test(
        "When No Threat Found Then Return False",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenHandleDecidePolicyForNavigationResponse_AndNoFrameThreat_ThenReturnFalse(threat: ThreatKind) async throws {
        // GIVEN
        sut.attachWebView(webView)
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationResponse = MockNavigationResponse.with(url: url)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationNotHandled
        }
        var didCallLoadSimulatedRequest = false
        webView.loadRequestHandler = { _, _ in
            didCallLoadSimulatedRequest = true
        }

        // WHEN
        let result = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

        // THEN
        #expect(sut.isSpecialErrorPageRequest == false)
        #expect(sut.isSpecialErrorPageVisible == false)
        #expect(sut.failedURL == nil)
        #expect(didCallLoadSimulatedRequest == false)
        #expect(result == false)
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
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        let navigationResponse = MockNavigationResponse.with(url: url)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        }
        _ = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

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
    @Test("Leave Site closes Tab when SSL Error")
    func whenLeaveSite_AndSSLError_AndWebViewCannotNavigateBack_ThenAskDelegateToCloseTab() {
        // GIVEN
        webView.setCanGoBack(false)
        let delegate = SpySpecialErrorPageNavigationDelegate()
        sut.delegate = delegate
        sut.attachWebView(webView)
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: .genericSSL)
        #expect(!delegate.didCallCloseSpecialErrorPageTab)
        #expect(!delegate.capturedShouldCreateNewEmptyTab)

        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(delegate.didCallCloseSpecialErrorPageTab)
        #expect(!delegate.capturedShouldCreateNewEmptyTab)
    }

    @MainActor
    @Test(
        "Lave Site closes Tab when Malicious Site Error",
        arguments: [
            ThreatKind.phishing,
            .malware
        ]
    )
    func whenLeaveSite_AndMaliciousSiteError_AndWebViewCanNavigateBack_ThenNavigateBack(threat: ThreatKind) async throws {
        // GIVEN
        webView.setCanGoBack(true)
        sut.attachWebView(webView)
        let url = try #require(URL(string: "https://example.com"))
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        let navigationResponse = MockNavigationResponse.with(url: url)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        }
        _ = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)
        let delegate = SpySpecialErrorPageNavigationDelegate()
        sut.delegate = delegate
        #expect(!delegate.didCallCloseSpecialErrorPageTab)
        #expect(!delegate.capturedShouldCreateNewEmptyTab)


        // WHEN
        sut.leaveSiteAction()

        // THEN
        #expect(delegate.didCallCloseSpecialErrorPageTab)
        #expect(delegate.capturedShouldCreateNewEmptyTab)
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
        let navigationResponse = MockNavigationResponse.with(url: url)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        }
        _ = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

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
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        let navigationResponse = MockNavigationResponse.with(url: url)
        maliciousSiteProtectionNavigationHandler.task = Task {
            .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)))
        }
        _ = await sut.handleDecidePolicy(for: navigationResponse, webView: webView)

        #expect(!maliciousSiteProtectionNavigationHandler.didCallAdvancedInfoPresented)

        // WHEN
        sut.advancedInfoPresented()

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallAdvancedInfoPresented)
    }

    @MainActor
    @Test(
        "Test Current Threat Kind asks Malicous forward event to Malicious Site Protection Navigation Handler",
        arguments: [
            ThreatKind.phishing,
            .malware,
            nil
        ]
    )
    func whenCurrentThreatKindIsCalledThenAskMaliciousSiteProtectionNavigationHandlerForThreatKind(threat: ThreatKind?) throws {
        // GIVEN
        #expect(!maliciousSiteProtectionNavigationHandler.didCallCurrentThreatKind)

        // WHEN
        _ = sut.currentThreatKind

        // THEN
        #expect(maliciousSiteProtectionNavigationHandler.didCallCurrentThreatKind)
    }

    @MainActor
    @Test("Web View is not strongly retained")
    func whenWebViewIsNilled_ThenWebViewIsDeallocated() {
        weak var weakWebView: MockWebView?

        autoreleasepool {
            // GIVEN
            var webView: MockWebView! = MockWebView()
            weakWebView = webView
            sut.attachWebView(webView)

            // WHEN
            webView = nil
        }
        // THEN
        RunLoop.current.run(until: Date().addingTimeInterval(0.2)) // Gives the run loop time to process deinit event
        #expect(weakWebView == nil)
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
