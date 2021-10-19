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

    public weak var delegate: PrintingUserScriptDelegate?

    public var source: String = """
(function() {

    function styleInPage(css, verbose){
        if(typeof getComputedStyle== "undefined")
        getComputedStyle= function(elem){
            return elem.currentStyle;
        }
        var who, hoo, values= [], val,
        nodes= document.body.getElementsByTagName('*'),
        L= nodes.length;
        for(var i= 0; i<L; i++){
            who= nodes[i];
            if(who.style){
                hoo= '#'+(who.id || who.nodeName+'('+i+')');
                val= who.style.fontFamily || getComputedStyle(who, '')[css];
                if(val){
                    if(verbose) values.push([hoo, val]);
                    else if(values.indexOf(val)== -1) values.push(val);
                }
                val_before = getComputedStyle(who, ':before')[css];
                if(val_before){
                    if(verbose) values.push([hoo, val_before]);
                    else if(values.indexOf(val_before)== -1) values.push(val_before);
                }
                val_after= getComputedStyle(who, ':after')[css];
                if(val_after){
                    if(verbose) values.push([hoo, val_after]);
                    else if(values.indexOf(val_after)== -1) values.push(val_after);
                }
            }
        }
        return values;
    }

    window.addEventListener("DOMContentLoaded", function(event) {
                            webkit.messageHandlers.log.postMessage("fontFamily:");
                            var resultFontFamily = styleInPage('fontFamily');
                            webkit.messageHandlers.log.postMessage(JSON.stringify(resultFontFamily));
    }, false)

}) ();
"""

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    public var forMainFrameOnly: Bool = false
    public var messageNames: [String] = []

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}

public extension WKWebView {
    
    func adjustTextSize(_ percentage: Int) {
        let jsString = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(percentage)%'"
        evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func doNotAdjustTextSize() {
        let jsString = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='none'"
        evaluateJavaScript(jsString, completionHandler: nil)
    }
}
