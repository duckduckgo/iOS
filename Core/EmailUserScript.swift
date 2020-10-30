//
//  EmailUserScript.swift
//  DuckDuckGo
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

enum EmailMessageNames: String {
    case storeToken = "emailHandlerStoreToken"
    case checkSignedInStatus = "emailHandlerCheckAppSignedInStatus"
    case checkCanInjectAutofill = "emailHandlerCheckCanInjectAutoFill"
    case getAlias = "emailHandlerGetAlias"
}

public class EmailUserScript: NSObject, UserScript {
    
    private let emailManager = EmailManager()
    
    public var webView: WKWebView?
    
    public lazy var source: String = {
        return loadJS("email-autofill")
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentEnd
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [
        EmailMessageNames.storeToken.rawValue,
        EmailMessageNames.checkSignedInStatus.rawValue,
        EmailMessageNames.checkCanInjectAutofill.rawValue,
        EmailMessageNames.getAlias.rawValue
    ]
    
    public var isSignedIn: Bool {
        emailManager.isSignedIn
    }
        
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
        guard let type = EmailMessageNames(rawValue: message.name) else {
            print("Receieved invalid message name")
            return
        }
        
        switch type {
        case .storeToken:
            guard let dict = message.body as? [String: Any],
                  let token = dict["token"] as? String,
                  let username = dict["username"] as? String else { return }
            
            emailManager.storeToken(token, username: username)
        case .checkSignedInStatus:
            let signedInStatus = String(emailManager.isSignedIn)
            webView!.evaluateJavaScript("window.postMessage({checkExtensionSignedInCallback: true, isAppSignedIn: \(signedInStatus), fromIOSApp: true}, window.origin)")
        case .checkCanInjectAutofill:
            let canInject = emailManager.isSignedIn
            webView!.evaluateJavaScript("window.postMessage({checkCanInjectAutoFillCallback: true, canInjectAutoFill: \(canInject), fromIOSApp: true}, window.origin)")
        case .getAlias:
            print(self.emailManager.token)
            print(self.emailManager.username)
            emailManager.getAliasIfNeededAndConsume { alias in
                guard let alias = alias else {
                    print("oh no")
                    return
                }
                self.webView!.evaluateJavaScript("window.postMessage({type: 'getAliasResponse', alias: \"\(alias)\", fromIOSApp: true}, window.origin)")
            }
        }
    }
    
    public func notifyWebViewEmailSignedInStatus() {
        //todo probs don't need this
//        let signedInStatus = String(emailManager.isSignedIn)
//        webView!.evaluateJavaScript("window.postMessage({checkExtensionSignedIn: true, isAppSignedIn: \(signedInStatus)})")
    }
}
