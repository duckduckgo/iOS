//
//  UserScripts.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import WebKit
import BrowserServicesKit

public struct UserScripts {

    public let userScripts: [UserScript]

    public init(userScripts: [UserScript]) {
        self.userScripts = userScripts
    }

    public func applyTo(_ webView: WKWebView) {
        removeMessageHandlersFrom(webView) // incoming config might be a copy of an existing confg with handlers
        webView.configuration.userContentController.removeAllUserScripts()

        userScripts.forEach { script in

            webView.configuration.userContentController.addUserScript(WKUserScript(source: script.source,
                                                                                   injectionTime: script.injectionTime,
                                                                                   forMainFrameOnly: script.forMainFrameOnly))

            if #available(iOS 14, *),
               let replyHandler = script as? WKScriptMessageHandlerWithReply {
                script.messageNames.forEach { messageName in
                    webView.configuration.userContentController.addScriptMessageHandler(replyHandler, contentWorld: .page, name: messageName)
                }
            } else {
                script.messageNames.forEach { messageName in
                    webView.configuration.userContentController.add(script, name: messageName)
                }
            }

        }
    }

    public func removeMessageHandlersFrom(_ webView: WKWebView) {
        let controller = webView.configuration.userContentController
        userScripts.forEach { script in
            script.messageNames.forEach { messageName in
                controller.removeScriptMessageHandler(forName: messageName)
            }
        }
    }

}
