//
//  SpecialErrorPageTests.swift
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
import XCTest
import WebKit

@testable import SpecialErrorPages
@testable import DuckDuckGo

class MockSpecialErrorWebView: WKWebView {

    var loadRequestHandler: ((URLRequest, String) -> Void)?
    var currentURL: URL?

    override func loadSimulatedRequest(_ request: URLRequest, responseHTML string: String) -> WKNavigation {
        loadRequestHandler?(request, string)
        return super.loadSimulatedRequest(request, responseHTML: string)
    }

    override var url: URL? {
        return currentURL
    }

    func setCurrentURL(_ url: URL) {
        self.currentURL = url
    }

}

final class SpecialErrorPageTests: XCTestCase {
    
    var webView: MockSpecialErrorWebView!
    var sut: TabViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass]
        sut = .fake(customWebView: { [weak self] configuration in
            guard let self else { fatalError("It has to exist") }
            self.webView = MockSpecialErrorWebView(frame: CGRect(), configuration: configuration)
            return self.webView
        }, featureFlagger: featureFlagger)
        WKNavigation.swizzleDealloc()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        WKNavigation.restoreDealloc()
    }

    func testWhenCertificateExpiredThenExpectedErrorPageIsShown() {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLCertExpired,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://expired.badssl.com")!])
        let expectation = self.expectation(description: "Special error page should be loaded")
        var didFulfill = false
        webView.loadRequestHandler = { request, html in
            if !didFulfill {
                XCTAssertTrue(html.contains("Warning: This site may be insecure"))
                XCTAssertTrue(html.contains("is expired"))
                XCTAssertEqual(request.url!.host, URL(string: "https://expired.badssl.com")!.host)
                expectation.fulfill()
                didFulfill = true
            }
        }

        // WHEN
        sut.webView(webView, didFailProvisionalNavigation: WKNavigation(), withError: error)

        // THEN
        XCTAssertEqual(sut.failedURL, URL(string: "https://expired.badssl.com")!)
        XCTAssertEqual(sut.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "expired",
                                                       domain: "expired.badssl.com",
                                                       eTldPlus1: "badssl.com"))
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Expectation was not fulfilled in time")
        }
    }

    func testWhenCertificateWrongHostThenExpectedErrorPageIsShown() {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLHostNameMismatch,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://wrong.host.badssl.com")!])
        let expectation = self.expectation(description: "Special error page should be loaded")
        var didFulfill = false
        webView.loadRequestHandler = { request, html in
            if !didFulfill {
                XCTAssertTrue(html.contains("Warning: This site may be insecure"))
                XCTAssertTrue(html.contains("does not match"))
                XCTAssertEqual(request.url!.host, URL(string: "https://wrong.host.badssl.com")!.host)
                expectation.fulfill()
                didFulfill = true
            }
        }

        // WHEN
        sut.webView(webView, didFailProvisionalNavigation: WKNavigation(), withError: error)

        // THEN
        XCTAssertEqual(sut.failedURL, URL(string: "https://wrong.host.badssl.com")!)
        XCTAssertEqual(sut.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "wrongHost",
                                                       domain: "wrong.host.badssl.com",
                                                       eTldPlus1: "badssl.com"))
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Expectation was not fulfilled in time")
        }
    }

    func testWhenCertificateSelfSignedThenExpectedErrorPageIsShown() {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLXCertChainInvalid,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://self-signed.badssl.com")!])
        let expectation = self.expectation(description: "Special error page should be loaded")
        var didFulfill = false
        webView.loadRequestHandler = { request, html in
            if !didFulfill {
                XCTAssertTrue(html.contains("Warning: This site may be insecure"))
                XCTAssertTrue(html.contains("is not trusted"))
                XCTAssertEqual(request.url!.host, URL(string: "https://self-signed.badssl.com")!.host)
                expectation.fulfill()
                didFulfill = true
            }
        }

        // WHEN
        sut.webView(webView, didFailProvisionalNavigation: WKNavigation(), withError: error)

        // THEN
        XCTAssertEqual(sut.failedURL, URL(string: "https://self-signed.badssl.com")!)
        XCTAssertEqual(sut.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "selfSigned",
                                                       domain: "self-signed.badssl.com",
                                                       eTldPlus1: "badssl.com"))
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Expectation was not fulfilled in time")
        }
    }

    func testWhenOtherCertificateIssueThenExpectedErrorPageIsShown() {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://untrusted-root.badssl.com")!])
        let expectation = self.expectation(description: "Special error page should be loaded")
        var didFulfill = false
        webView.loadRequestHandler = { request, html in
            if !didFulfill {
                XCTAssertTrue(html.contains("Warning: This site may be insecure"))
                XCTAssertTrue(html.contains("is not trusted"))
                XCTAssertEqual(request.url!.host, URL(string: "https://untrusted-root.badssl.com")!.host)
                expectation.fulfill()
                didFulfill = true
            }
        }

        // WHEN
        sut.webView(webView, didFailProvisionalNavigation: WKNavigation(), withError: error)

        // THEN
        XCTAssertEqual(sut.failedURL, URL(string: "https://untrusted-root.badssl.com")!)
        XCTAssertEqual(sut.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "invalid",
                                                       domain: "untrusted-root.badssl.com",
                                                       eTldPlus1: "badssl.com"))
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Expectation was not fulfilled in time")
        }
    }

    @MainActor
    func testWhenNavigationEndedIfNoSSLFailureSSLUserScriptIsNotEnabled() {
        // GIVEN
        webView.setCurrentURL(URL(string: "https://self-signed.badssl.com")!)
        sut.storedSpecialErrorPageUserScript = SpecialErrorPageUserScript(localeStrings: "", languageCode: "")

        // WHEN
        sut.webView(webView, didFinish: WKNavigation())

        // THEN
        XCTAssertFalse(sut.specialErrorPageUserScript?.isEnabled ?? true)
    }

    @MainActor
    func testWhenNavigationEndedIfSSLFailureButURLIsDifferentFromNavigationURLThenSSLUserScriptIsNotEnabled() {
        // GIVEN
        webView.setCurrentURL(URL(string: "https://self-signed.badssl.com")!)
        sut.failedURL = URL(string: "https://different.url.com")!
        sut.storedSpecialErrorPageUserScript = SpecialErrorPageUserScript(localeStrings: "", languageCode: "")

        // WHEN
        sut.webView(webView, didFinish: WKNavigation())

        // THEN
        XCTAssertFalse(sut.specialErrorPageUserScript?.isEnabled ?? true)
    }

    @MainActor
    func testWhenNavigationEndedIfSSLFailureAndNavigationURLIsTheSameAsFailingURLThenSSLUserScriptIsEnabled() {
        // GIVEN
        webView.setCurrentURL(URL(string: "https://self-signed.badssl.com")!)
        sut.failedURL = URL(string: "https://self-signed.badssl.com")!
        sut.storedSpecialErrorPageUserScript = SpecialErrorPageUserScript(localeStrings: "", languageCode: "")

        // WHEN
        sut.webView(webView, didFinish: WKNavigation())

        // THEN
        XCTAssertTrue(sut.specialErrorPageUserScript?.isEnabled ?? false)
    }

    func testWhenDidReceiveChallengeIfChallengeForCertificateValidationAndNoBypassThenShouldNotReturnCredentials() async {
        let protectionSpace = URLProtectionSpace(host: "", port: 4, protocol: nil, realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: ChallengeSender())
        await sut.webView(webView, didReceive: challenge) { _, credential in
            XCTAssertNil(credential)
        }
    }

    func testWhenDidReceiveChallengeIfChallengeForCertificateValidationAndUserRequestBypassThenReturnsCredentials() async {
        let protectionSpace = URLProtectionSpace(host: "", port: 4, protocol: nil, realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: ChallengeSender())
        await sut.visitSite()
        await sut.webView(webView, didReceive: challenge) { _, credential in
            XCTAssertNotNil(credential)
        }
    }

}

final class ChallengeSender: URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
    func isEqual(_ object: Any?) -> Bool {
        return false
    }
    var hash: Int = 0
    var superclass: AnyClass?
    func `self`() -> Self {
        self
    }
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    func isProxy() -> Bool {
        return false
    }
    func isKind(of aClass: AnyClass) -> Bool {
        return false
    }
    func isMember(of aClass: AnyClass) -> Bool {
        return false
    }
    func conforms(to aProtocol: Protocol) -> Bool {
        return false
    }
    func responds(to aSelector: Selector!) -> Bool {
        return false
    }
    var description: String = ""
}

final class MockCredentialCreator: URLCredentialCreating {

    func urlCredentialFrom(trust: SecTrust?) -> URLCredential? {
        return URLCredential(user: "", password: "", persistence: .forSession)
    }

}
