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
    /// Creates a task for detecting malicious sites based on the provided navigation action.
    ///
    /// - Parameters:
    ///   - navigationAction: The `WKNavigationAction` object that contains information about
    ///     the navigation event.
    ///   - webView: The web view from which the navigation request began.
    @MainActor
    func createMaliciousSiteDetectionTask(for navigationAction: WKNavigationAction, webView: WKWebView)

    /// Retrieves a task for detecting malicious sites based on the provided navigation response.
    ///
    /// - Parameters:
    ///   - navigationResponse: The `WKNavigationResponse` object that contains information about
    ///     the navigation event.
    ///   - webView: The web view from which the navigation request began.
    /// - Returns: A `Task<MaliciousSiteProtectionNavigationResult, Never>?` that represents the
    ///   asynchronous operation for detecting malicious sites. If the task cannot be found,
    ///   the function returns `nil`.
    @MainActor
    func getMaliciousSiteDectionTask(for navigationResponse: WKNavigationResponse, webView: WKWebView) -> Task<MaliciousSiteProtectionNavigationResult, Never>?
}

final class MaliciousSiteProtectionNavigationHandler {
    private let maliciousSiteProtectionManager: MaliciousSiteDetecting
    private let storageCache: StorageCache

    @MainActor private(set) var maliciousURLExemptions: [URL: ThreatKind] = [:]
    @MainActor private(set) var bypassedMaliciousSiteThreatKind: ThreatKind?
    @MainActor private(set) var maliciousSiteDetectionTasks: [URL: Task<MaliciousSiteProtectionNavigationResult, Never>] = [:]

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
    func createMaliciousSiteDetectionTask(for navigationAction: WKNavigationAction, webView: WKWebView) {

        guard let url = navigationAction.request.url else {
            return
        }

        if let aboutBlankURL = URL(string: "about:blank"), url == aboutBlankURL {
            return
        }

        handleMaliciousExemptions(for: navigationAction.navigationType, url: url)

        guard !shouldBypassMaliciousSiteProtection(for: url) else {
            return
        }

        let threatDetectionTask: Task<MaliciousSiteProtectionNavigationResult, Never> = Task.detached { [weak self] in
            guard let self else { return .navigationNotHandled }

            guard let threatKind = await self.maliciousSiteProtectionManager.evaluate(url) else {
                return .navigationNotHandled
            }

            if await navigationAction.isTargetingMainFrame {
                let errorData = SpecialErrorData.maliciousSite(kind: threatKind, url: url)
                let response = MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: errorData)
                return .navigationHandled(.mainFrame(response))
            } else {
                // Extract the URL of the source frame (the iframe) that initiated the navigation action
                let iFrameTopURL = await navigationAction.sourceFrame.safeRequest?.url ?? url
                let errorData = SpecialErrorData.maliciousSite(kind: threatKind, url: iFrameTopURL)
                return .navigationHandled(.iFrame(maliciousURL: url, error: errorData))
            }
        }

        maliciousSiteDetectionTasks[url] = threatDetectionTask
    }

    @MainActor
    func getMaliciousSiteDectionTask(for navigationResponse: WKNavigationResponse, webView: WKWebView) -> Task<MaliciousSiteProtectionNavigationResult, Never>? {

        guard let url = navigationResponse.response.url else {
            assertionFailure("Could not find Malicious Site Detection Task for URL")
            return nil
        }

        return maliciousSiteDetectionTasks.removeValue(forKey: url)
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
