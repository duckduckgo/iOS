//
//  DocumentUserScript.swift
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

public class DocumentUserScript: NSObject, UserScript {
    
    public lazy var source: String = {
       return loadJS("document")
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = []
    
    public weak var webView: WKWebView?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // no messaging
    }

    public func getUrlAtPoint(x: Int, y: Int, completion: @escaping (URL?) -> Void) {
        let javascript = "window.__ddg__.getHrefFromPoint(\(x), \(y))"
        webView?.evaluateJavaScript(javascript) { (result, _) in
            if let text = result as? String {
                let url = URL(string: text)
                completion(url)
            } else {
                completion(nil)
            }
        }
    }

    public func getUrlAtPointSynchronously(x: Int, y: Int) -> URL? {
        var complete = false
        var url: URL?
        let javascript = "window.__ddg__.getHrefFromPoint(\(x), \(y))"
        webView?.evaluateJavaScript(javascript) { (result, _) in
            if let text = result as? String {
                url = URL(string: text)
            }
            complete = true
        }

        while !complete {
            RunLoop.current.run(mode: RunLoop.Mode.default, before: .distantFuture)
        }
        return url
    }
}
