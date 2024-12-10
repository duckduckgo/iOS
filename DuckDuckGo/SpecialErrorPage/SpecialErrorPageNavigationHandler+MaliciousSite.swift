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
        case mainFrame(MaliciousSiteDetectionNavigationResponse)
        case iFrame(maliciousURL: URL, error: SpecialErrorData)
    }
}

protocol MaliciousSiteProtectionNavigationHandling: AnyObject {
    /// Handles navigation actions in a `WKWebView` by saving them for later use.
    ///
    /// This method is called when a navigation action occurs, and it stores the
    /// navigation action in a dictionary. The saved action can be referenced later
    /// when the provisional navigation starts.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action that is being handled.
    @MainActor
    func handleWebView(navigationAction: WKNavigationAction)

    /// Checks the navigation action associated with the `WKWebView` URL to determine
    /// if it is malicious or not.
    ///
    /// This method evaluates the current URL of the web view and detects whether
    /// it should show a special error page or not
    ///
    /// - Parameters:
    ///   - webView: The `WKWebView` instance whose URL is being checked.
    ///
    /// - Returns: A `MaliciousSiteProtectionNavigationResult` indicating whether
    ///   the navigation should be handled or not
    @MainActor
    func handleMaliciousSiteProtectionNavigation(webView: WKWebView) async -> MaliciousSiteProtectionNavigationResult
}

final class MaliciousSiteProtectionNavigationHandler {
    private let maliciousSiteProtectionManager: MaliciousSiteDetecting
    private let storageCache: StorageCache

    @MainActor private(set) var maliciousURLExemptions: [URL: ThreatKind] = [:]
    @MainActor private(set) var bypassedMaliciousSiteThreatKind: ThreatKind?
    @MainActor private(set) var currentNavigationActions: [URL: WKNavigationAction] = [:]

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
    func handleWebView(navigationAction: WKNavigationAction) {
        guard let url = navigationAction.request.url else { return }
        currentNavigationActions[url] = navigationAction
    }

    @MainActor
    func handleMaliciousSiteProtectionNavigation(webView: WKWebView) async -> MaliciousSiteProtectionNavigationResult {

        guard
            let url = webView.url,
            let navigationAction = currentNavigationActions.removeValue(forKey: url)
        else {
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
            let response = MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)
            return .navigationHandled(.mainFrame(response))
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

    @MainActor
    func handleMaliciousExemptions(for navigationType: WKNavigationType, url: URL) {
        // TODO: check storing redirects
        // Re-set the flag every time we load a web page
        bypassedMaliciousSiteThreatKind = maliciousURLExemptions[url]
    }

    @MainActor
    func shouldBypassMaliciousSiteProtection(for url: URL) -> Bool {
        bypassedMaliciousSiteThreatKind != .none || url.isDuckDuckGo || url.isDuckURLScheme
    }

}

// MARK: - Helpers

private extension SpecialErrorData {

    var threatKind: ThreatKind? {
        switch self {
        case .ssl:
            return nil
        case let .maliciousSite(threatKind, _):
            return threatKind
        }
    }

}
