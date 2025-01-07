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
import Testing
import WebKit

@testable import SpecialErrorPages
@testable import DuckDuckGo

@Suite("Special Error Pages - SSLSpecialErrorPageTests Unit Tests", .serialized)
final class SSLSpecialErrorPageTests {

    private var sut: SSLErrorPageNavigationHandler!

    init() {
        let featureFlagger = MockFeatureFlagger()
        featureFlagger.enabledFeatureFlags = [.sslCertificatesBypass]
        sut = SSLErrorPageNavigationHandler(urlCredentialCreator: MockCredentialCreator(), featureFlagger: featureFlagger)
    }

    deinit {
        sut = nil
    }

    @Test
    func whenCertificateExpiredThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLCertExpired,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://expired.badssl.com")!])

        // WHEN
        let sslError = try #require(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        #expect(sslError.error.url == URL(string: "https://expired.badssl.com")!)
        #expect(sslError.type == .expired)
        #expect(sslError.error.errorData == .ssl(type: .expired,
                                                 domain: "expired.badssl.com",
                                                 eTldPlus1: "badssl.com"))
    }

    @Test
    func whenCertificateWrongHostThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLHostNameMismatch,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://wrong.host.badssl.com")!])

        // WHEN
        let sslError = try #require(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        #expect(sslError.error.url == URL(string: "https://wrong.host.badssl.com")!)
        #expect(sslError.type == .wrongHost)
        #expect(sslError.error.errorData == .ssl(type: .wrongHost,
                                                 domain: "wrong.host.badssl.com",
                                                 eTldPlus1: "badssl.com"))
    }

    @Test
    func whenCertificateSelfSignedThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLXCertChainInvalid,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://self-signed.badssl.com")!])

        // WHEN
        let sslError = try #require(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        #expect(sslError.error.url == URL(string: "https://self-signed.badssl.com")!)
        #expect(sslError.type == .selfSigned)
        #expect(sslError.error.errorData == .ssl(type: .selfSigned,
                                                 domain: "self-signed.badssl.com",
                                                 eTldPlus1: "badssl.com"))
    }

    @Test
    func whenOtherCertificateIssueThenExpectedErrorPageIsShown() throws {
        // GIVEN
        let error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorServerCertificateUntrusted,
                            userInfo: ["_kCFStreamErrorCodeKey": errSSLUnknownRootCert,
                                       NSURLErrorFailingURLErrorKey: URL(string: "https://untrusted-root.badssl.com")!])

        // WHEN
        let sslError = try #require(sut.makeNewRequestURLAndSpecialErrorDataIfEnabled(error: error))

        // THEN
        #expect(sslError.error.url == URL(string: "https://untrusted-root.badssl.com")!)
        #expect(sslError.type == .invalid)
        #expect(sslError.error.errorData == .ssl(type: .invalid,
                                                 domain: "untrusted-root.badssl.com",
                                                 eTldPlus1: "badssl.com"))
    }

    @Test
    func whenDidReceiveChallengeIfChallengeForCertificateValidationAndNoBypassThenShouldNotReturnCredentials() {
        // GIVEN
        let protectionSpace = URLProtectionSpace(host: "", port: 4, protocol: nil, realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: ChallengeSender())
        var expectedCredential: URLCredential?

        // WHEN
        sut.handleServerTrustChallenge(challenge) { _, credential in
            expectedCredential = credential
        }

        // THEN
        #expect(expectedCredential == nil)
    }

    @MainActor
    @Test
    func whenDidReceiveChallengeIfChallengeForCertificateValidationAndUserRequestBypassThenReturnsCredentials() throws {
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
        #expect(expectedCredential != nil)
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
