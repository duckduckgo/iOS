//
//  AIChatRequestAuthorizationHandler.swift
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

import AIChat
import WebKit

struct AIChatRequestAuthorizationHandler: AIChatRequestAuthorizationHandling {
    let debugSettings: AIChatDebugSettingsHandling

    func shouldAllowRequestWithNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
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
