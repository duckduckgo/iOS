//
//  AIChatUserScript.swift
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


import Common
import UserScript
import Foundation
import AIChat

final class AIChatUserScript: NSObject, Subfeature {

    enum MessageNames: String, CaseIterable {
        case openAIChat
        case getAIChatNativeConfigValues
        case getAIChatNativeHandoffData
    }

    private var handler: AIChatUserScriptHandling
    public let featureName: String = "aiChat"
    weak var broker: UserScriptMessageBroker?
    private(set) var messageOriginPolicy: MessageOriginPolicy

    init(handler: AIChatUserScriptHandling, debugSettings: AIChatDebugSettingsHandling) {
        self.handler = handler
        var rules = [HostnameMatchingRule]()

        /// Default rule for DuckDuckGo AI Chat
        if let ddgDomain = URL.ddg.host {
            rules.append(.exact(hostname: ddgDomain))
        }

        if let debugHostname = debugSettings.messagePolicyHostname {
            rules.append(.exact(hostname: debugHostname))
        }

        self.messageOriginPolicy = .only(rules: rules)
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch MessageNames(rawValue: methodName) {
        case .getAIChatNativeConfigValues:
            return handler.getAIChatNativeConfigValues
        case .getAIChatNativeHandoffData:
            return handler.getAIChatNativeHandoffData
        case .openAIChat:
            return handler.openAIChat
        default:
            return nil
        }
    }

    func setPayloadHandler(_ payloadHandler: any AIChatPayloadHandling) {
        self.handler.setPayloadHandler(payloadHandler)
    }
}
