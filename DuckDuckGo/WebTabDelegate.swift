//
//  WebTabDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 02/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

protocol WebTabDelegate: class {
    
    func openNewTab(fromWebView webView: WKWebView, forUrl url: URL)
    
    func refreshControls()
    
    func resetAll()
}
