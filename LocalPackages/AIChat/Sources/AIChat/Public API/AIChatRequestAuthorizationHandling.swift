//
//  AIChatRequestAuthorizationHandling.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import WebKit

public protocol AIChatRequestAuthorizationHandling {
    /// Determines whether a web request should be handled within the custom AI Chat UI.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action associated with the request, providing context about how the request was initiated.
    ///
    /// - Returns: A Boolean value indicating whether the request should be handled within the custom AI Chat page.
    ///   - `true`: The request will be processed inside the custom AI Chat UI.
    ///   - `false`: The request will be canceled, and the `AIChatViewControllerDelegate` method
    ///     `aiChatViewController(_:didRequestToLoad:)` will be called to handle the request externally.
    @MainActor func shouldAllowRequestWithNavigationAction(_ navigationAction: WKNavigationAction) -> Bool
}

public struct AIChatRequestAuthorizationHandler: AIChatRequestAuthorizationHandling {
    let debugSettings: AIChatDebugSettingsHandling

    public init(debugSettings: AIChatDebugSettingsHandling) {
        self.debugSettings = debugSettings
    }

    @MainActor
    public func shouldAllowRequestWithNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        /// If we have debug settings, lets allow all requests since we might have redirects like Duo
        if debugSettings.messagePolicyHostname?.isEmpty == false {
            return true
        }
        if let url = navigationAction.request.url {
            if url.isDuckAIURL || navigationAction.targetFrame?.isMainFrame == false {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
