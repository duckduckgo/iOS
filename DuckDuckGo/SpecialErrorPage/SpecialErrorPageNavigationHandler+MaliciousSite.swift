//
//  SpecialErrorPageNavigationHandler+MaliciousSite.swift
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
import Core
import SpecialErrorPages
import WebKit
import MaliciousSiteProtection

enum MaliciousSiteProtectionNavigationResult: Equatable {
    case navigationHandled(NavigationType)
    case navigationNotHandled

    enum NavigationType: Equatable {
        case mainFrame(SpecialErrorData)
        case iFrame(maliciousURL: URL, error: SpecialErrorData)
    }
}

protocol MaliciousSiteProtectionNavigationHandling: AnyObject {
    /// Decides whether to cancel navigation to prevent opening the YouTube app from the web view.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action to evaluate.
    ///   - webView: The web view where navigation is occurring.
    /// - Returns: `true` if the navigation should be canceled, `false` otherwise.
    func handleMaliciousSiteProtectionNavigation(for navigationAction: WKNavigationAction, webView: WKWebView) async -> MaliciousSiteProtectionNavigationResult
}

final class MaliciousSiteProtectionNavigationHandler {
    private let maliciousSiteProtectionManager: MaliciousSiteDetecting
    private let storageCache: StorageCache
    private(set) var maliciousURLExemptions: [URL: ThreatKind] = [:]
    private(set) var bypassedMaliciousSiteThreatKind: ThreatKind?

    init(
        maliciousSiteProtectionManager: MaliciousSiteDetecting = MaliciousSiteProtectionManager(),
        storageCache: StorageCache = AppDependencyProvider.shared.storageCache
    ) {
        self.maliciousSiteProtectionManager = maliciousSiteProtectionManager
        self.storageCache = storageCache
    }
}

// MARK: - MaliciousSiteProtectionNavigationHandling

extension MaliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandling {

    @MainActor
    func handleMaliciousSiteProtectionNavigation(for navigationAction: WKNavigationAction, webView: WKWebView) async -> MaliciousSiteProtectionNavigationResult {

        guard let url = navigationAction.request.url else {
            return .navigationNotHandled
        }

        if let aboutBlankURL = URL(string: "about:blank"), url == aboutBlankURL {
            return .navigationNotHandled
        }

        handleMaliciousExemptions(for: navigationAction.navigationType, url: url)

        guard !shouldBypassMaliciousSiteProtection(for: url) else {
            return .navigationNotHandled
        }

        guard let threatKind = await maliciousSiteProtectionManager.evaluate(url) else {
            return .navigationNotHandled
        }

        if navigationAction.isTargetingMainFrame {
            let errorData = SpecialErrorData.maliciousSite(kind: threatKind, url: url)
            return .navigationHandled(.mainFrame(errorData))
        } else {
            // Extract the URL of the source frame (the iframe) that initiated the navigation action
            let iFrameTopURL = navigationAction.sourceFrame.safeRequest?.url ?? url
            let errorData = SpecialErrorData.maliciousSite(kind: threatKind, url: iFrameTopURL)
            return .navigationHandled(.iFrame(maliciousURL: url, error: errorData))
        }
    }

}

// MARK: - SpecialErrorPageActionHandler

extension MaliciousSiteProtectionNavigationHandler: SpecialErrorPageActionHandler {

    func visitSite(url: URL, errorData: SpecialErrorData) {
        maliciousURLExemptions[url] = errorData.threatKind
        bypassedMaliciousSiteThreatKind = errorData.threatKind

        // Fire Pixel
    }

    func leaveSite() {
        // Fire Pixel
    }

    func advancedInfoPresented() {
        // Fire Pixel
    }

}

// MARK: - Private

private extension MaliciousSiteProtectionNavigationHandler {

    func handleMaliciousExemptions(for navigationType: WKNavigationType, url: URL) {
        if let threatKind = bypassedMaliciousSiteThreatKind, navigationType == .other {
            maliciousURLExemptions[url] = threatKind
        }
        bypassedMaliciousSiteThreatKind = maliciousURLExemptions[url]
    }

    func shouldBypassMaliciousSiteProtection(for url: URL) -> Bool {
        bypassedMaliciousSiteThreatKind != .none || url.isDuckDuckGo || url.isDuckURLScheme
    }

}
