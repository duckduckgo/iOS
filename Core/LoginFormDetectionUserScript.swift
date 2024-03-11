//
//  LoginFormDetectionUserScript.swift
//  Core
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import UserScript

public protocol LoginFormDetectionDelegate: NSObjectProtocol {

    func loginFormDetectionUserScriptDetectedLoginForm(_ script: LoginFormDetectionUserScript)

}

public class LoginFormDetectionUserScript: NSObject, UserScript {

    public lazy var source: String = {
        return Self.loadJS("login-form-detection", from: Bundle.core, withReplacements: [
            "$IS_DEBUG$": isDebugBuild ? "true" : "false"
        ])
    }()

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart

    public var forMainFrameOnly: Bool = false

    public var messageNames: [String] = [ "loginFormDetected" ]

    public weak var delegate: LoginFormDetectionDelegate?

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.loginFormDetectionUserScriptDetectedLoginForm(self)
    }
}
