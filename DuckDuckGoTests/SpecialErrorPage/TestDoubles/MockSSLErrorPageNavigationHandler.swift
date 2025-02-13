//
//  MockSSLErrorPageNavigationHandler.swift
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
import SpecialErrorPages
@testable import DuckDuckGo

final class MockSSLErrorPageNavigationHandler: SSLSpecialErrorPageNavigationHandling, SpecialErrorPageActionHandler {
    private(set) var didCallHandleServerTrustChallenge = false
    private(set) var capturedChallenge: URLAuthenticationChallenge?
    var handleServerTrustChallengeHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void = { _, _ in }

    private(set) var didCallMakeNewRequestURLAndSpecialErrorDataIfEnabled = false

    private(set) var didCallErrorPageVisited = false
    private(set) var capturedSpecialErrorType: SSLErrorType?

    private(set) var didCallLeaveSite = false
    private(set) var didCallVisitSite = false
    private(set) var didCalladvancedInfoPresented = false

    func handleServerTrustChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        didCallHandleServerTrustChallenge = true
        capturedChallenge = challenge
        handleServerTrustChallengeHandler(.performDefaultHandling, nil)
    }

    func makeNewRequestURLAndSpecialErrorDataIfEnabled(error: NSError) -> SSLSpecialError? {
        didCallMakeNewRequestURLAndSpecialErrorDataIfEnabled = true
        return SSLSpecialError(type: .expired, error: SpecialErrorModel(url: URL(string: "www.example.com")!, errorData: .ssl(type: .expired, domain: "", eTldPlus1: nil)))
    }

    func errorPageVisited(errorType: SSLErrorType) {
        didCallErrorPageVisited = true
        capturedSpecialErrorType = errorType
    }

    func visitSite() {
        didCallVisitSite = true
    }

    func leaveSite() {
        didCallLeaveSite = true
    }

    func advancedInfoPresented() {
        didCalladvancedInfoPresented = true
    }
}
