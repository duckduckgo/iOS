//
//  AIChatUserScriptHandling.swift
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
import UserScript
import Foundation

protocol AIChatUserScriptHandling {
    func handleGetUserValues(params: Any, message: UserScriptMessage) -> Encodable?
    func openAIChat(params: Any, message: UserScriptMessage) async -> Encodable?
}

struct AIChatUserScriptHandler: AIChatUserScriptHandling {
    @MainActor func openAIChat(params: Any, message: UserScriptMessage) async -> Encodable? {
    //    WindowControllersManager.shared.showTab(with: .settings(pane: .aiChat))
        return nil
    }

    public func handleGetUserValues(params: Any, message: UserScriptMessage) -> Encodable? {
        AIChatScriptUserValues(isAIChatEnabled: true,
                   platform: "iOS",
                   aiChatPayload: nil)
    }
}
