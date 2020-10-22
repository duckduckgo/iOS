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

public enum EmailMessageNames: String {
    case storeToken = "emailHandlerStoreToken"
}

public class EmailUserScript: NSObject, UserScript {
    
    private let emailManager = EmailManager()

    public lazy var source: String = {
        return loadJS("email")
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [EmailMessageNames.storeToken.rawValue]
        
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
            
            emailManager.storeToken(token, username: username)
        }
    }
}
