//
//  WebViewCreationDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

public protocol WebViewCreationDelegate: class {
    
    func webViewCreated(webView: WKWebView)
    
    func webViewDestroyed(webView: WKWebView)
}
