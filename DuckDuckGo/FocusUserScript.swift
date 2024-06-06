//
//  FocusUserScript.swift
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
import Core
import WebKit
import UserScript

public protocol FocusUserScriptDelegate: NSObjectProtocol {

    func focusUserScript(_ script: FocusUserScript, didRequestUpdateFocus focus: Bool)

}

public class FocusUserScript: NSObject, UserScript {

    public lazy var source: String = {
        return """
        document.addEventListener('focusin', function() {
            window.webkit.messageHandlers.focusHandler.postMessage(true);
        });
        document.addEventListener('focusout', function() {
            window.webkit.messageHandlers.focusHandler.postMessage(false);
        });
        """
    }()

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentEnd

    public var forMainFrameOnly: Bool = false

    public var messageNames: [String] = ["focusHandler"]

    public weak var delegate: FocusUserScriptDelegate?

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        guard let dict = message.body as? [String: Any] else { return }
        if message.name == "focusHandler", let isFocused = message.body as? Bool {
            if isFocused {
                print("Web content triggered keyboard")
                delegate?.focusUserScript(self, didRequestUpdateFocus: true)
            } else {
                print("Keyboard likely dismissed")
                delegate?.focusUserScript(self, didRequestUpdateFocus: false)
            }
        }

    }
}
