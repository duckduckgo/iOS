//
//  WebEventsDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 02/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

public protocol WebEventsDelegate: class {

    func attached(webView: WKWebView)
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL)
    
    func webpageDidStartLoading()
    
    func webpageDidFinishLoading()
}
