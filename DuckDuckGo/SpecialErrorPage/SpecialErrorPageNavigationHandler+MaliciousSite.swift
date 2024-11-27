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

enum MaliciousSiteProtectionNavigationResult: Equatable {
    case navigationHandled(SpecialErrorModel)
    case navigationNotHandled
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
        // Implement logic to use `maliciousSiteProtectionManager.evaluate(url)`
        // Return navigationNotHandled for the time being
        return .navigationNotHandled
    }

}

// MARK: - SpecialErrorPageActionHandler

extension MaliciousSiteProtectionNavigationHandler: SpecialErrorPageActionHandler {

    func visitSite() {
        // Fire Pixel
    }

    func leaveSite() {
        // Fire Pixel
    }

    func advancedInfoPresented() {
        // Fire Pixel
    }

}
