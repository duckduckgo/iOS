//
//  DocumentUserScript.swift
//  Core
//
//  Created by Chris Brind on 31/03/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
        let javascript = "duckduckgoDocument.getHrefFromPoint(\(x), \(y))"
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
        let javascript = "duckduckgoDocument.getHrefFromPoint(\(x), \(y))"
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

    deinit {
        print("*** deinit DOCS")
    }
    
}
