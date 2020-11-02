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


//TODO what happens if they are signed into the app, but then sign in to a different user on web?
public class EmailUserScript: NSObject, UserScript {
    
    public let emailManager = EmailManager()
    
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
    
    //TODO we should inject emailManager and not have this
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
            let properties = "checkExtensionSignedInCallback: true, isAppSignedIn: \(signedInStatus)"
            let jsString = EmailUserScript.postMessageJSString(withPropertyString: properties)
            self.webView!.evaluateJavaScript(jsString)
        case .checkCanInjectAutofill:
            let canInject = emailManager.isSignedIn
            let properties = "checkCanInjectAutoFillCallback: true, canInjectAutoFill: \(canInject)"
            let jsString = EmailUserScript.postMessageJSString(withPropertyString: properties)
            self.webView!.evaluateJavaScript(jsString)
        case .getAlias:
            emailManager.getAliasEmailIfNeededAndConsume { alias in
                guard let alias = alias else {
                    print("oh no")
                    return
                }
                let jsString = EmailUserScript.postMessageJSString(withPropertyString: "type: 'getAliasResponse', alias: \"\(alias)\"")
                self.webView!.evaluateJavaScript(jsString)
            }
        }
    }
    
    public func notifyWebViewEmailSignedInStatus() {
        //todo probs don't need this
//        let signedInStatus = String(emailManager.isSignedIn)
//        webView!.evaluateJavaScript("window.postMessage({checkExtensionSignedIn: true, isAppSignedIn: \(signedInStatus)})")
    private static func postMessageJSString(withPropertyString propertyString: String) -> String {
        let string = "window.postMessage({%@, fromIOSApp: true}, window.origin)"
        return String(format: string, propertyString)
    }
}
