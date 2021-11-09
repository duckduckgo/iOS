//
//  TextSizeUserScript.swift
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
import BrowserServicesKit
import WebKit

public class TextSizeUserScript: NSObject, UserScript {

    public var textSizeAdjustment: Float = 1.0
    
    public weak var delegate: PrintingUserScriptDelegate?

    public var source: String {
        let percentage = Int(textSizeAdjustment * 100)
        return """
        (function() {
        
            let topLevelUrl = getTopLevelURL();

            document.addEventListener("DOMContentLoaded", function(event) {
                webkit.messageHandlers.log.postMessage(" -- TextSizeUserScript - event DOMContentLoaded");
        
                document.adjustTextSize = adjustTextSize;
                
                document.adjustTextSize(\(percentage));
        
                webkit.messageHandlers.log.postMessage(" -- TextSizeUserScript - " + topLevelUrl.hostname);
                
            }, false)
        
            function getTopLevelURL() {
                try {
                    // FROM: https://stackoverflow.com/a/7739035/73479
                    // FIX: Better capturing of top level URL so that trackers in embedded documents are not considered first party
                    return new URL(window.location != window.parent.location ? document.referrer : document.location.href)
                } catch(error) {
                    return new URL(location.href)
                }
            }
            
            function adjustTextSize(percentage) {
                webkit.messageHandlers.log.postMessage(" -- TextSizeUserScript - setting:");
                document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust=percentage+"%";
            };
        
        }) ();
        
        """
    }

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    public var forMainFrameOnly: Bool = false
    public var messageNames: [String] = []

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { }
}

public extension WKWebView {
    
    func adjustTextSize(_ percentage: Int) {
        let jsString = "document.adjustTextSize(\(percentage));"
        evaluateJavaScript(jsString, completionHandler: nil)
    }
}
