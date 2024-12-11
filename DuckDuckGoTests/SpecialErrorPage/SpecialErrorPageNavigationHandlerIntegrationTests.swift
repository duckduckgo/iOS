//
//  SpecialErrorPageNavigationHandlerIntegrationTests.swift
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

@Suite("Special Error Pages - Integration Tests", .serialized)
final class SpecialErrorPageNavigationHandlerIntegrationTests {
    private var sut: SpecialErrorPageNavigationHandler!
    private var webView: MockSpecialErrorWebView!
    private var sslErrorPageNavigationHandler: SSLErrorPageNavigationHandler!
    private var maliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandler!

    @MainActor
    init() {
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass]
        webView = MockSpecialErrorWebView(frame: CGRect(), configuration: .nonPersistent())
        sslErrorPageNavigationHandler = SSLErrorPageNavigationHandler(featureFlagger: featureFlagger)
        maliciousSiteProtectionNavigationHandler = MaliciousSiteProtectionNavigationHandler()
        sut = SpecialErrorPageNavigationHandler(
            sslErrorPageNavigationHandler: sslErrorPageNavigationHandler,
            maliciousSiteProtectionNavigationHandler: maliciousSiteProtectionNavigationHandler
        )
    }

    deinit {
        sslErrorPageNavigationHandler = nil
        maliciousSiteProtectionNavigationHandler = nil
        sut = nil
        webView = nil
    }

    @MainActor
    @Test
    func whenCertificateExpiredThenExpectedErrorPageIsShown() async throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLCertExpired,
                                       NSURLErrorFailingURLErrorKey: try #require(URL(string: "https://expired.badssl.com"))])
        sut.attachWebView(webView)
        var expectedRequest: URLRequest?
        var expectedHTML: String?

        try await confirmation { receivedHTML in
            webView.loadRequestHandler = { request, html in
                expectedRequest = request
                expectedHTML = html
                receivedHTML()
            }

            // WHEN
            sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: error)

            // THEN
            let html = try #require(expectedHTML)
            let url = try #require(expectedRequest?.url)
            let expectedHost = try #require(URL(string: "https://expired.badssl.com")?.host)
            #expect(html.contains("Warning: This site may be insecure"))
            #expect(html.contains("is expired"))
            #expect(url.host == expectedHost)
            #expect(sut.failedURL == url)
            #expect(sut.errorData == .ssl(type: .expired, domain: "expired.badssl.com", eTldPlus1: "badssl.com"))
        }
    }

    @MainActor
    @Test
    func whenCertificateWrongHostThenExpectedErrorPageIsShown() async throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLHostNameMismatch,
                                       NSURLErrorFailingURLErrorKey: try #require(URL(string: "https://wrong.host.badssl.com"))])
        sut.attachWebView(webView)
        var expectedRequest: URLRequest?
        var expectedHTML: String?

        try await confirmation { receivedHTML in
            webView.loadRequestHandler = { request, html in
                expectedRequest = request
                expectedHTML = html
                receivedHTML()
            }

            // WHEN
            sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: error)

            // THEN
            let html = try #require(expectedHTML)
            let url = try #require(expectedRequest?.url)
            let expectedHost = try #require(URL(string: "https://wrong.host.badssl.com")?.host)
            #expect(html.contains("Warning: This site may be insecure"))
            #expect(html.contains("does not match"))
            #expect(url.host == expectedHost)
            #expect(sut.failedURL == url)
            #expect(sut.errorData == .ssl(type: .wrongHost, domain: "wrong.host.badssl.com", eTldPlus1: "badssl.com"))
        }
    }

    @MainActor
    @Test
    func whenCertificateSelfSignedThenExpectedErrorPageIsShown() async throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLXCertChainInvalid,
                                       NSURLErrorFailingURLErrorKey: try #require(URL(string: "https://self-signed.badssl.com"))])
        sut.attachWebView(webView)
        var expectedRequest: URLRequest?
        var expectedHTML: String?

        try await confirmation { receivedHTML in
            webView.loadRequestHandler = { request, html in
                expectedRequest = request
                expectedHTML = html
                receivedHTML()
            }

            // WHEN
            sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: error)

            // THEN
            let html = try #require(expectedHTML)
            let url = try #require(expectedRequest?.url)
            let expectedHost = try #require(URL(string: "https://self-signed.badssl.com")?.host)
            #expect(html.contains("Warning: This site may be insecure"))
            #expect(html.contains("is not trusted"))
            #expect(url.host == expectedHost)
            #expect(sut.failedURL == url)
            #expect(sut.errorData == .ssl(type: .selfSigned, domain: "self-signed.badssl.com", eTldPlus1: "badssl.com"))
        }
    }

    @MainActor
    @Test
    func whenOtherCertificateIssueThenExpectedErrorPageIsShown() async throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
                                       NSURLErrorFailingURLErrorKey: try #require(URL(string: "https://untrusted-root.badssl.com"))])
        sut.attachWebView(webView)
        var expectedRequest: URLRequest?
        var expectedHTML: String?

        try await confirmation { receivedHTML in
            webView.loadRequestHandler = { request, html in
                expectedRequest = request
                expectedHTML = html
                receivedHTML()
            }

            // WHEN
            sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: error)

            // THEN
            let html = try #require(expectedHTML)
            let url = try #require(expectedRequest?.url)
            let expectedHost = try #require(URL(string: "https://untrusted-root.badssl.com")?.host)
            #expect(html.contains("Warning: This site may be insecure"))
            #expect(html.contains("is not trusted"))
            #expect(url.host == expectedHost)
            #expect(sut.failedURL == url)
            #expect(sut.errorData == .ssl(type: .invalid, domain: "untrusted-root.badssl.com", eTldPlus1: "badssl.com"))
        }
    }

    @MainActor
    @Test
    func whenNavigationEndedIfNoSSLFailureSSLUserScriptIsNotEnabled() throws {
        // GIVEN
        webView.setCurrentURL(try #require(URL(string: "https://self-signed.badssl.com")))
        let script = SpecialErrorPageUserScript(localeStrings: "", languageCode: "")
        sut.setUserScript(script)
        sut.attachWebView(webView)
        #expect(script.isEnabled == false)

        // WHEN
        sut.handleWebView(webView, didFinish: DummyWKNavigation())

        // THEN
        #expect(script.isEnabled == false)
    }

    @MainActor
    @Test
    func whenNavigationEndedIfSSLFailureButURLIsDifferentFromNavigationURLThenSSLUserScriptIsNotEnabled() throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
                                       NSURLErrorFailingURLErrorKey: try #require(URL(string: "https://untrusted-root.badssl.com"))])

        webView.setCurrentURL(try #require(URL(string: "https://self-signed.badssl.com")))
        let script = SpecialErrorPageUserScript(localeStrings: "", languageCode: "")
        sut.setUserScript(script)
        sut.attachWebView(webView)
        // Fail the request with a different URL.
        sut.handleWebView(webView, didFailProvisionalNavigation: DummyWKNavigation(), withError: error)
        #expect(script.isEnabled == false)

        // WHEN
        sut.handleWebView(webView, didFinish: DummyWKNavigation())

        // THEN
        #expect(script.isEnabled == false)
    }

    @MainActor
    @Test
    func testWhenNavigationEndedIfSSLFailureAndNavigationURLIsTheSameAsFailingURLThenSSLUserScriptIsEnabled() throws {
        // GIVEN
        let url = try #require(URL(string: "https://self-signed.badssl.com"))
        webView.setCurrentURL(url)
        let script = SpecialErrorPageUserScript(localeStrings: "", languageCode: "")
        sut.setUserScript(script)
        sut.attachWebView(webView)
        let navigation = DummyWKNavigation()
        let error = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorServerCertificateUntrusted,
            userInfo: [
                "_kCFStreamErrorCodeKey": errSSLCertExpired,
                NSURLErrorFailingURLErrorKey: url]
        )
        sut.handleWebView(webView, didFailProvisionalNavigation: navigation, withError: error)
        #expect(script.isEnabled == false)

        // WHEN
        sut.handleWebView(webView, didFinish: navigation)

        // THEN
        #expect(script.isEnabled)
    }

    @MainActor
    @Test(
        "Test Current Threat Kind Returns Threat Kind",
        arguments: [
            ("www.example.com", nil),
            ("http://privacy-test-pages.site/security/badware/phishing.html", ThreatKind.phishing),
            ("http://privacy-test-pages.site/security/badware/malware.html", .malware),
        ]
    )
    func whenCurrentThreatKindIsCalledThenAskMaliciousSiteProtectionNavigationHandlerForThreatKind(threatInfo: (path: String, threat: ThreatKind?)) async throws {
        // GIVEN
        let url = try #require(URL(string: threatInfo.path))
        webView.setCurrentURL(url)
        sut.attachWebView(webView)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url))
        sut.handleDecidePolicyFor(navigationAction: navigationAction, webView: webView)
        let response = MockNavigationResponse.with(url: url)
        _ = await sut.handleDecidePolicyfor(navigationResponse: response, webView: webView)
        sut.visitSiteAction()

        // WHEN
        let result = sut.currentThreatKind

        // THEN
        #expect(result == threatInfo.threat)
    }
}
