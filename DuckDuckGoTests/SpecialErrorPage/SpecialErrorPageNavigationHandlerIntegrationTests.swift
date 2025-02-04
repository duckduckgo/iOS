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
    private var maliciousSiteProtectionManager: MaliciousSiteProtectionManager!
    private var maliciousSiteProtectionFeatureFlags: MockMaliciousSiteProtectionFeatureFlags!
    private var maliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandler!

    @MainActor
    init() {
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass, .maliciousSiteProtection]
        webView = MockSpecialErrorWebView(frame: CGRect(), configuration: .nonPersistent())
        sslErrorPageNavigationHandler = SSLErrorPageNavigationHandler(featureFlagger: featureFlagger)
        let preferencesManager = MockMaliciousSiteProtectionPreferencesManager()
        preferencesManager.isMaliciousSiteProtectionOn = true
        maliciousSiteProtectionFeatureFlags = MockMaliciousSiteProtectionFeatureFlags()
        maliciousSiteProtectionFeatureFlags.isMaliciousSiteProtectionEnabled = true
        maliciousSiteProtectionFeatureFlags.shouldDetectMaliciousThreatForDomainResult = true
        maliciousSiteProtectionManager = MaliciousSiteProtectionManager(
            dataFetcher: MockMaliciousSiteProtectionDataFetcher(),
            api: MaliciousSiteProtectionAPI(),
            dataManager: MaliciousSiteProtection.DataManager(
                fileStore: MaliciousSiteProtection.FileStore(
                    dataStoreURL: FileManager.default.urls(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask
                    )
                    .first!
                ),
                embeddedDataProvider: nil,
                fileNameProvider: MaliciousSiteProtectionManager.fileName(for:)
            ),
            detector: MockMaliciousSiteDetector(),
            preferencesManager: preferencesManager,
            maliciousSiteProtectionFeatureFlagger: maliciousSiteProtectionFeatureFlags
        )
        maliciousSiteProtectionNavigationHandler = MaliciousSiteProtectionNavigationHandler(maliciousSiteProtectionManager: maliciousSiteProtectionManager)
        
        sut = SpecialErrorPageNavigationHandler(
            sslErrorPageNavigationHandler: sslErrorPageNavigationHandler,
            maliciousSiteProtectionNavigationHandler: maliciousSiteProtectionNavigationHandler
        )
    }

    // MARK: - SSL

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

    // MARK: - Malicious Site Protection

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
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: navigationAction, webView: webView)
        let response = MockNavigationResponse.with(url: url)
        _ = await sut.handleDecidePolicy(for: response, webView: webView)
        sut.visitSiteAction()

        // WHEN
        let result = sut.currentThreatKind

        // THEN
        #expect(result == threatInfo.threat)
    }

    @MainActor
    @Test
    func whenNoMaliciousThreatIsDetectedThenSpecialErrorPageIsNotLoaded() async throws {
        // GIVEN
        let url = try #require(URL(string: "http://privacy-test-pages.site/"))
        webView.setCurrentURL(url)
        sut.attachWebView(webView)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: navigationAction, webView: webView)
        let response = MockNavigationResponse.with(url: url)

        await confirmation(expectedCount: 0) { receivedHTML in
            webView.loadRequestHandler = { _, _ in
                receivedHTML()
            }

            // WHEN
            let result = await sut.handleDecidePolicy(for: response, webView: webView)

            // THEN
            #expect(!result)
        }
    }

    @MainActor
    @Test
    func whenPhishingThreatIsDetectedThenSpecialErrorPageIsLoaded() async throws {
        // GIVEN
        let url = try #require(URL(string: "http://privacy-test-pages.site/security/badware/phishing.html"))
        webView.setCurrentURL(url)
        sut.attachWebView(webView)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: navigationAction, webView: webView)
        let response = MockNavigationResponse.with(url: url)

        var expectedHTML: String?

        try await confirmation { receivedHTML in
            webView.loadRequestHandler = { _, html in
                expectedHTML = html
                receivedHTML()
            }

            // WHEN
            let result = await sut.handleDecidePolicy(for: response, webView: webView)

            // THEN
            #expect(result)
            #expect(sut.failedURL == url)
            #expect(sut.errorData == .maliciousSite(kind: .phishing, url: url))
            #expect(sut.isSpecialErrorPageRequest)
            #expect(sut.isSpecialErrorPageVisible)
            let html = try #require(expectedHTML)
            #expect(html.contains("Warning: This site may be a{newline}security risk"))
            #expect(html.contains("This website may be impersonating a legitimate site in order to trick you into providing personal information, such as passwords or credit card numbers."))
        }
    }

    @MainActor
    @Test
    func wheanMaliciousSiteProtectionDisabledThenSpecialErrorPageIsNotLoaded() async throws {
        // GIVEN
        maliciousSiteProtectionFeatureFlags.shouldDetectMaliciousThreatForDomainResult = false
        let url = try #require(URL(string: "http://privacy-test-pages.site/security/badware/phishing.html"))
        webView.setCurrentURL(url)
        sut.attachWebView(webView)
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: navigationAction, webView: webView)
        let response = MockNavigationResponse.with(url: url)

        await confirmation(expectedCount: 0) { receivedHTML in
            webView.loadRequestHandler = { _, _ in
                receivedHTML()
            }

            // WHEN
            let result = await sut.handleDecidePolicy(for: response, webView: webView)

            // THEN
            #expect(!result)
        }
    }

    @MainActor
    @Test
    func whenLoadingASafeWebsiteAfterDetectingAThreat_ThenSpecialErrorPageIsNotLoaded() async throws {
        // LOAD MALICIOUS WEBSITE

        // GIVEN
        sut.attachWebView(webView)
        let maliciousURL = try #require(URL(string: "http://privacy-test-pages.site/security/badware/phishing.html"))
        webView.setCurrentURL(maliciousURL)
        let maliciousSiteNavigationAction = MockNavigationAction(request: URLRequest(url: maliciousURL), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: maliciousSiteNavigationAction, webView: webView)
        let maliciousSiteResponse = MockNavigationResponse.with(url: maliciousURL)

        await confirmation { receivedHTML in
            webView.loadRequestHandler = { _, _ in
                receivedHTML()
            }

            // WHEN
            let maliciousResult = await sut.handleDecidePolicy(for: maliciousSiteResponse, webView: webView)

            // THEN
            #expect(maliciousResult)
            #expect(sut.failedURL == maliciousURL)
            #expect(sut.errorData == .maliciousSite(kind: .phishing, url: maliciousURL))
            #expect(sut.isSpecialErrorPageRequest)
            #expect(sut.isSpecialErrorPageVisible)
        }

        // LOAD SAFE WEBSITE

        // GIVEN
        let safeURL = try #require(URL(string: "http://broken.third-party.site/"))
        webView.setCurrentURL(safeURL)
        let safeSiteNavigationAction = MockNavigationAction(request: URLRequest(url: safeURL), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: safeSiteNavigationAction, webView: webView)
        let safeSiteResponse = MockNavigationResponse.with(url: safeURL)

        await confirmation(expectedCount: 0) { receivedHTML in
            webView.loadRequestHandler = { _, _ in
                receivedHTML()
            }

            // WHEN
            let result = await sut.handleDecidePolicy(for: safeSiteResponse, webView: webView)

            // THEN
            #expect(!result)
        }
    }

    @MainActor
    @Test
    func whenLoadingDDGWebsiteAfterDetectingAThreat_ThenSpecialErrorPageIsNotLoaded() async throws {
        // LOAD MALICIOUS WEBSITE

        // GIVEN
        sut.attachWebView(webView)
        let maliciousURL = try #require(URL(string: "http://privacy-test-pages.site/security/badware/phishing.html"))
        webView.setCurrentURL(maliciousURL)
        let maliciousSiteNavigationAction = MockNavigationAction(request: URLRequest(url: maliciousURL), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: maliciousSiteNavigationAction, webView: webView)
        let maliciousSiteResponse = MockNavigationResponse.with(url: maliciousURL)

        await confirmation { receivedHTML in
            webView.loadRequestHandler = { _, _ in
                receivedHTML()
            }

            // WHEN
            let maliciousResult = await sut.handleDecidePolicy(for: maliciousSiteResponse, webView: webView)

            // THEN
            #expect(maliciousResult)
            #expect(sut.failedURL == maliciousURL)
            #expect(sut.errorData == .maliciousSite(kind: .phishing, url: maliciousURL))
            #expect(sut.isSpecialErrorPageRequest)
            #expect(sut.isSpecialErrorPageVisible)
        }

        // LOAD DDG WEBSITE

        // GIVEN
        let safeURL = try #require(URL(string: "http://duckduckgo.com/"))
        webView.setCurrentURL(safeURL)
        let safeSiteNavigationAction = MockNavigationAction(request: URLRequest(url: safeURL), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.handleDecidePolicy(for: safeSiteNavigationAction, webView: webView)
        let safeSiteResponse = MockNavigationResponse.with(url: safeURL)

        await confirmation(expectedCount: 0) { receivedHTML in
            webView.loadRequestHandler = { _, _ in
                receivedHTML()
            }

            // WHEN
            let result = await sut.handleDecidePolicy(for: safeSiteResponse, webView: webView)

            // THEN
            #expect(!result)
        }
    }

}
