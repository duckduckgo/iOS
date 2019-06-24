//
//  JavascriptLoader.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public class JavascriptLoader {

    public enum Script: String {
        case findinpage
        case document
        case disconnectme
        case contentblocker
        case apbfilter = "abp-filter-parser-packed"
        case apbfilterES2015 = "abp-filter-parser-packed-es2015"
        case tlds
        case messaging
        case debugMessagingEnabled = "debug-messaging-enabled"
        case debugMessagingDisabled = "debug-messaging-disabled"
        case bloom = "bloom-filter-packed"
        case bloomES2015 = "bloom-filter-packed-es2015"
        case cachedEasylist = "easylist-cached"
        case easylistParsing = "easylist-parsing"
        case blockerData = "blockerdata"
        case surrogate
        case detection
    }

    class func path(for jsFile: String) -> String {
        let bundle = Bundle(for: JavascriptLoader.self)
        let path = bundle.path(forResource: jsFile, ofType: "js")!
        return path
    }

    public func load(_ script: Script, into controller: WKUserContentController, forMainFrameOnly: Bool,
                     injectionTime: WKUserScriptInjectionTime = .atDocumentStart) {
        load(script: script, withReplacements: [:], into: controller, forMainFrameOnly: forMainFrameOnly)
    }

    public func load(script: JavascriptLoader.Script, withReplacements replacements: [String: String] = [:],
                     into controller: WKUserContentController, forMainFrameOnly: Bool, injectionTime: WKUserScriptInjectionTime = .atDocumentStart) {

        var js = try? String(contentsOfFile: JavascriptLoader.path(for: script.rawValue))
        for (key, value) in replacements {
            js = js?.replacingOccurrences(of: key, with: value, options: .literal)
        }

        if let js = js {
            load(js: js, into: controller, forMainFrameOnly: forMainFrameOnly, injectionTime: injectionTime)
        }
    }

    public func load(js: String, into controller: WKUserContentController, forMainFrameOnly: Bool,
                     injectionTime: WKUserScriptInjectionTime = .atDocumentStart) {
        
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: forMainFrameOnly)
        controller.addUserScript(script)
    }

}
