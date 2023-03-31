//
//  FindInPageUserScript.swift
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

import Core
import WebKit
import UserScript
import FindInPageIOSJSSupport

public class FindInPageUserScript: NSObject, UserScript {

    public lazy var source: String = {
        return Self.loadJS("findinpage", from: FindInPageIOSJSSupport.bundle)
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = ["findInPageHandler"]
    
    var findInPage: FindInPage?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else { return }
        let currentResult = dict["currentResult"] as? Int
        let totalResults = dict["totalResults"] as? Int
        findInPage?.update(currentResult: currentResult, totalResults: totalResults)
    }
}
