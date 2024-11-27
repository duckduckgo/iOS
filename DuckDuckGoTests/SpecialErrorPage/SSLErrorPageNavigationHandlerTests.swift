//
//  SSLErrorPageNavigationHandlerTests.swift
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

final class SSLSpecialErrorPageTests: XCTestCase {

    private var sut: SSLErrorPageNavigationHandler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass]
        sut = SSLErrorPageNavigationHandler(urlCredentialCreator: MockCredentialCreator(), featureFlagger: featureFlagger)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        sut = nil
    }

    func testWhenCertificateExpiredThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLCertExpired,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://expired.badssl.com")!])

        // WHEN
        let sslError = try XCTUnwrap(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        XCTAssertEqual(sslError.url, URL(string: "https://expired.badssl.com")!)
        XCTAssertEqual(sslError.type, .expired)
        XCTAssertEqual(sslError.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "expired",
                                                       domain: "expired.badssl.com",
                                                       eTldPlus1: "badssl.com"))
    }

    func testWhenCertificateWrongHostThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLHostNameMismatch,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://wrong.host.badssl.com")!])

        // WHEN
        let sslError = try XCTUnwrap(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        XCTAssertEqual(sslError.url, URL(string: "https://wrong.host.badssl.com")!)
        XCTAssertEqual(sslError.type, .wrongHost)
        XCTAssertEqual(sslError.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "wrongHost",
                                                       domain: "wrong.host.badssl.com",
                                                       eTldPlus1: "badssl.com"))
    }

    func testWhenCertificateSelfSignedThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLXCertChainInvalid,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://self-signed.badssl.com")!])

        // WHEN
        let sslError = try XCTUnwrap(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        XCTAssertEqual(sslError.url, URL(string: "https://self-signed.badssl.com")!)
        XCTAssertEqual(sslError.type, .selfSigned)
        XCTAssertEqual(sslError.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "selfSigned",
                                                       domain: "self-signed.badssl.com",
                                                       eTldPlus1: "badssl.com"))
    }

    func testWhenOtherCertificateIssueThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: "test",
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://untrusted-root.badssl.com")!])

        // WHEN
        let sslError = try XCTUnwrap(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        XCTAssertEqual(sslError.url, URL(string: "https://untrusted-root.badssl.com")!)
        XCTAssertEqual(sslError.type, .invalid)
        XCTAssertEqual(sslError.errorData, SpecialErrorData(kind: .ssl,
                                                       errorType: "invalid",
                                                       domain: "untrusted-root.badssl.com",
                                                       eTldPlus1: "badssl.com"))
    }

    func testWhenDidReceiveChallengeIfChallengeForCertificateValidationAndNoBypassThenShouldNotReturnCredentials() {
        // GIVEN
        let protectionSpace = URLProtectionSpace(host: "", port: 4, protocol: nil, realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: ChallengeSender())
        var expectedCredential: URLCredential?

        // WHEN
        sut.handleServerTrustChallenge(challenge) { _, credential in
            expectedCredential = credential
        }

        // THEN
        XCTAssertNil(expectedCredential)
    }

    func testWhenDidReceiveChallengeIfChallengeForCertificateValidationAndUserRequestBypassThenReturnsCredentials() {
        // GIVEN
        let protectionSpace = URLProtectionSpace(host: "", port: 4, protocol: nil, realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: ChallengeSender())
        var expectedCredential: URLCredential?
        sut.visitSite()

        // WHEN
        sut.handleServerTrustChallenge(challenge) { _, credential in
            expectedCredential = credential
        }

        // THEN
        XCTAssertNotNil(expectedCredential)
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
