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

public protocol EmailUserScriptDelegate: class {
    func emailUserScriptDidRequestSignedInStatus(emailUserScript: EmailUserScript) -> Bool
    func emailUserScriptDidRequestAlias(emailUserScript: EmailUserScript, completionHandler: @escaping AliasCompletion)
    func emailUserScript(_ emailUserScript: EmailUserScript, didRequestStoreToken token: String, username: String)
}

public class EmailUserScript: NSObject, UserScript {
    
    private enum EmailMessageNames: String {
        case storeToken = "emailHandlerStoreToken"
        case checkSignedInStatus = "emailHandlerCheckAppSignedInStatus"
        case checkCanInjectAutofill = "emailHandlerCheckCanInjectAutoFill"
        case getAlias = "emailHandlerGetAlias"
    }
    
    public weak var delegate: EmailUserScriptDelegate?
    
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
        
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let type = EmailMessageNames(rawValue: message.name) else {
            print("Receieved invalid message name")
            return
        }
        
        switch type {
        case .storeToken:
            guard let dict = message.body as? [String: Any],
                  let token = dict["token"] as? String,
                  let username = dict["username"] as? String else { return }
            delegate?.emailUserScript(self, didRequestStoreToken: token, username: username)
            
        case .checkSignedInStatus:
            let signedIn = delegate?.emailUserScriptDidRequestSignedInStatus(emailUserScript: self) ?? false
            let signedInString = String(signedIn)
            let properties = "checkExtensionSignedInCallback: true, isAppSignedIn: \(signedInString)"
            let jsString = EmailUserScript.postMessageJSString(withPropertyString: properties)
            self.webView?.evaluateJavaScript(jsString)
            
        case .checkCanInjectAutofill:
            let signedIn = delegate?.emailUserScriptDidRequestSignedInStatus(emailUserScript: self) ?? false
            let canInjectString = String(signedIn)
            let properties = "checkCanInjectAutoFillCallback: true, canInjectAutoFill: \(canInjectString)"
            let jsString = EmailUserScript.postMessageJSString(withPropertyString: properties)
            self.webView?.evaluateJavaScript(jsString)
            
        case .getAlias:
            delegate?.emailUserScriptDidRequestAlias(emailUserScript: self) { alias, _ in
                guard let alias = alias else {
                    return
                }
                let jsString = EmailUserScript.postMessageJSString(withPropertyString: "type: 'getAliasResponse', alias: \"\(alias)\"")
                self.webView?.evaluateJavaScript(jsString)
            }
        }
    }
    
    private static func postMessageJSString(withPropertyString propertyString: String) -> String {
        let string = "window.postMessage({%@, fromIOSApp: true}, window.origin)"
        return String(format: string, propertyString)
    }
}
