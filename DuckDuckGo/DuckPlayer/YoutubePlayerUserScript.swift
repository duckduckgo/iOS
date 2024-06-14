//
//  YoutubePlayerUserScript.swift
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Common
import UserScript

final class YoutubePlayerUserScript: NSObject, Subfeature {

    weak var broker: UserScriptMessageBroker?
    weak var webView: WKWebView?

    var isEnabled: Bool = false

    // this isn't an issue to be set to 'all' because the page
    public let messageOriginPolicy: MessageOriginPolicy = .all
    public let featureName: String = "duckPlayerPage"

    struct Handlers {
        static let setUserValues = "setUserValues"
        static let getUserValues = "getUserValues"
    }
    
    // MARK: - Subfeature
    
    public func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    // MARK: - MessageNames

    enum MessageNames: String, CaseIterable {
        case setUserValues
        case getUserValues
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch methodName {
        case Handlers.setUserValues:
            return DuckPlayer.shared.handleGetUserValues
        case Handlers.getUserValues:
            return DuckPlayer.shared.handleSetUserValuesMessage(from: .duckPlayer)
        default:
            assertionFailure("YoutubePlayerUserScript: Failed to parse User Script message: \(methodName)")
            return nil
        }
    }

    func userValuesUpdated(userValues: UserValues) {
        if let webView = webView {
            broker?.push(method: "onUserValuesChanged", params: userValues, for: self, into: webView)
        }
    }
}
