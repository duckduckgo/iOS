//
//  WKUserContentController+Handler.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import UserScript

@MainActor
extension WKUserContentController {

    func addHandler(_ userScript: UserScript) {
        for messageName in userScript.messageNames {
            let contentWorld: WKContentWorld = userScript.getContentWorld()
            if let handlerWithReply = userScript as? WKScriptMessageHandlerWithReply {
                addScriptMessageHandler(handlerWithReply, contentWorld: contentWorld, name: messageName)
            } else {
                add(userScript, contentWorld: contentWorld, name: messageName)
            }
        }
    }

    func removeHandler(_ userScript: UserScript) {
        userScript.messageNames.forEach {
            let contentWorld: WKContentWorld = userScript.getContentWorld()
            removeScriptMessageHandler(forName: $0, contentWorld: contentWorld)
        }
    }

}
