//
//  SpecialErrorPageNavigationHandler+SSL.swift
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
import Common
import BrowserServicesKit
import SpecialErrorPages
import Core

protocol SSLSpecialErrorPageNavigationHandling {
    func handleServerTrustChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    func makeNewRequestURLAndSpecialErrorDataIfEnabled(error: NSError) -> SSLSpecialError?
    func errorPageVisited(errorType: SSLErrorType)
}

final class SSLErrorPageNavigationHandler {
    private var shouldBypassSSLError = false

    private let urlCredentialCreator: URLCredentialCreating
    private let storageCache: StorageCache
    private let featureFlagger: FeatureFlagger

    init(
        urlCredentialCreator: URLCredentialCreating = URLCredentialCreator(),
        storageCache: StorageCache = AppDependencyProvider.shared.storageCache,
        featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger
    ) {
        self.urlCredentialCreator = urlCredentialCreator
        self.storageCache = storageCache
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

    func makeNewRequestURLAndSpecialErrorDataIfEnabled(error: NSError) -> SSLSpecialError? {
        guard featureFlagger.isFeatureOn(.sslCertificatesBypass),
              error.isServerCertificateUntrusted,
              let errorType = error.sslErrorType,
              let failedURL = error.failedUrl,
              let host = failedURL.host
        else {
            return nil
        }

        let errorData = SpecialErrorData.ssl(
            type: errorType,
            domain: host,
            eTldPlus1: storageCache.tld.eTLDplus1(host)
        )

        return SSLSpecialError(type: errorType, error: SpecialErrorModel(url: failedURL, errorData: errorData))
    }

    func errorPageVisited(errorType: SSLErrorType) {
        Pixel.fire(pixel: .certificateWarningDisplayed(errorType.pixelParameter))
    }

}

// MARK: - SSLErrorPageNavigationHandler

extension SSLErrorPageNavigationHandler: SpecialErrorPageActionHandler {

    func leaveSite() {
        Pixel.fire(pixel: .certificateWarningLeaveClicked)
    }

    func visitSite() {
        shouldBypassSSLError = true
    }

    func advancedInfoPresented() {
        Pixel.fire(pixel: .certificateWarningAdvancedClicked)
    }
    
}
