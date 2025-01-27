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
import BrowserServicesKit
import RemoteMessaging

protocol AIChatUserScriptHandling {
    func getAIChatNativeConfigValues(params: Any, message: UserScriptMessage) -> Encodable?
    func getAIChatNativeHandoffData(params: Any, message: UserScriptMessage) -> Encodable?
    func openAIChat(params: Any, message: UserScriptMessage) async -> Encodable?
    func setPayloadHandler(_ payloadHandler: (any AIChatPayloadHandling)?)
}

final class AIChatUserScriptHandler: AIChatUserScriptHandling {
    private var payloadHandler: (any AIChatPayloadHandling)?
    private let featureFlagger: FeatureFlagger

    init(featureFlagger: FeatureFlagger) {
        self.featureFlagger = featureFlagger
    }

    private var isHandoffEnabled: Bool {
        featureFlagger.isFeatureOn(.aiChatDeepLink)
    }

    private var platform: String {
        "ios"
    }

    enum AIChatKeys {
        static let aiChatPayload = "aiChatPayload"
    }

    /// Invoked by the front-end code when it intends to open the AI Chat interface.
    /// The front-end can provide a payload that will be used the next time the AI Chat view is displayed.
    /// This function stores the payload and triggers a notification to handle the AI Chat opening process.
    @MainActor
    func openAIChat(params: Any, message: UserScriptMessage) async -> Encodable? {
        var payload: AIChatPayload?
        if let paramsDict = params as? AIChatPayload {
            payload = paramsDict[AIChatKeys.aiChatPayload] as? AIChatPayload
        }

        NotificationCenter.default.post(
            name: .urlInterceptAIChat,
            object: payload,
            userInfo: nil
        )

        return nil
    }

    public func getAIChatNativeConfigValues(params: Any, message: UserScriptMessage) -> Encodable? {
        AIChatNativeConfigValues(isAIChatHandoffEnabled: isHandoffEnabled,
                               platform: platform)
    }

    public func getAIChatNativeHandoffData(params: Any, message: UserScriptMessage) -> Encodable? {
        AIChatNativeHandoffData(isAIChatHandoffEnabled: isHandoffEnabled,
                               platform: platform,
                               aiChatPayload: payloadHandler?.consumePayload() as? AIChatPayload)
    }

    func setPayloadHandler(_ payloadHandler: (any AIChatPayloadHandling)?) {
        self.payloadHandler = payloadHandler
    }
}
