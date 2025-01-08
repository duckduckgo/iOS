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

final class AIChatUserScript: NSObject, Subfeature {
    private let testURL = URL(string: "https://674a-2001-818-ddd2-cb00-4063-2985-12ff-d946.ngrok-free.app/")!

    enum MessageNames: String, CaseIterable {
        case openAIChat
        case getUserValues
    }

    private let handler: AIChatUserScriptHandling
    public let featureName: String = "aiChat"
    weak var broker: UserScriptMessageBroker?
    private(set) var messageOriginPolicy: MessageOriginPolicy

    init(handler: AIChatUserScriptHandling) {
        self.handler = handler
        var rules = [HostnameMatchingRule]()

        /// Default rule for DuckDuckGo AI Chat
        rules.append(.exact(hostname: "674a-2001-818-ddd2-cb00-4063-2985-12ff-d946.ngrok-free.app"))

        self.messageOriginPolicy = .only(rules: rules)
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch MessageNames(rawValue: methodName) {
        case .getUserValues:
            return handler.handleGetUserValues
        case .openAIChat:
            return handler.openAIChat
        default:
            return nil
        }
    }
}
