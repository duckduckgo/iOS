//
//  ThreatProtectionNavigationHandler.swift
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
import BrowserServicesKit
import SpecialErrorPages
import WebKit

enum ThreatProtectionNavigationResult: Equatable {
    case handled(ThreatProtectionNavigationHandledModel)
    case notHandled
}

struct ThreatProtectionNavigationHandledModel: Equatable {
    let error: SpecialErrorData
    let url: URL
}

protocol ThreatProtectionNavigationHandling: AnyObject {
    /// Decides whether to cancel navigation to prevent opening the YouTube app from the web view.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action to evaluate.
    ///   - webView: The web view where navigation is occurring.
    /// - Returns: `true` if the navigation should be canceled, `false` otherwise.
    func handleThreatProtectionNavigation(for navigationAction: WKNavigationAction, webView: WKWebView) async -> ThreatProtectionNavigationResult
}

final class ThreatProtectionNavigationHandler {
    private let threatProtectionManager: ThreatDetecting

    init(threatProtectionManager: ThreatDetecting = ThreatProtectionManager()) {
        self.threatProtectionManager = threatProtectionManager
    }
}

// MARK: - ThreatProtectionNavigationHandling

extension ThreatProtectionNavigationHandler: ThreatProtectionNavigationHandling {

    @MainActor
    func handleThreatProtectionNavigation(for navigationAction: WKNavigationAction, webView: WKWebView) async -> ThreatProtectionNavigationResult {
        guard let url = navigationAction.request.url else {
            return .notHandled
        }

        guard url != URL(string: "about:blank")! else {
            return .notHandled
        }

        if shouldAllowNavigation(for: url) {
            return .notHandled
        }

        let threatKind = await threatProtectionManager.checkIsUrlMalicious(url: url)

        if navigationAction.isTargetingMainFrame() {
            switch threatKind {
            case .none:
                return .notHandled
            case .phishing:
                let error = SpecialErrorData(kind: .phishing, domain: url.host, eTldPlus1: AppDependencyProvider.shared.storageCache.tld.eTLDplus1(url.host))
                return .handled(.init(error: error, url: url))
            case .malware:
                let error = SpecialErrorData(kind: .phishing, domain: url.host, eTldPlus1: AppDependencyProvider.shared.storageCache.tld.eTLDplus1(url.host))
                return .handled(.init(error: error, url: url))
            }
        } else {
            return .notHandled
        }
    }

}

// MARK: - Private

private extension ThreatProtectionNavigationHandler {

    func shouldAllowNavigation(for url: URL) -> Bool {
        return url.isDuckDuckGo || url.isDuckURLScheme
    }

}
