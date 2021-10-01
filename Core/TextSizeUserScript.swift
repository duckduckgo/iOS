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
    window.print = function() {
        // webkit.messageHandlers.printHandler.postMessage({});
        document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='100%';
    };
}) ();
"""

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    public var forMainFrameOnly: Bool = false
//    public var messageNames: [String] = ["printHandler"]
//
//    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        delegate?.printingUserScriptDidRequestPrintController(self)
//    }
    
    public func adjustTextSize(_ percentage: Int) {
        
    }

}

extension WKWebView {
    
    public func adjustTextSize(_ percentage: Int) {
                
    }
}
