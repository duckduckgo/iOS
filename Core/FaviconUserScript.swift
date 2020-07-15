//
//  FaviconUserScript.swift
//  Core
//
//  Created by Chris Brind on 15/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit

public class FaviconUserScript: NSObject, UserScript {
    
    public var source: String = """

(function() {

    function getFavicon() {
        return findFavicons()[0];
    };
    
    function findFavicons() {
         var selectors = {
            "link[rel~='icon']": 0,
            "link[rel='apple-touch-icon']": 1,
            "link[rel='apple-touch-icon-precomposed']": 2
        };

        var favicons = [];
        for (var selector in selectors) {
            var icons = document.head.querySelectorAll(selector);
            for (var i = 0; i < icons.length; i++) {
                var href = icons[i].href;
                
                if (href.indexOf("svg") >= 0 || (icons[i].type && icons[i].type.indexOf("svg") >= 0)) {
                    continue;
                }

                favicons.push(href)
            }
        }
        return favicons;
    };

    try {
        var favicon = getFavicon();
        if (null != favicon) {
            webkit.messageHandlers.faviconFound.postMessage(favicon);
        }
    } catch(error) {
        // webkit might not be defined
    }

}) ();
"""
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentEnd
    
    public var forMainFrameOnly: Bool = true
    
    public var messageNames: [String] = ["faviconFound"]
    
    public weak var webView: WKWebView?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let favicon = message.body as? String,
            let url = URL(string: favicon) else { return }

        Favicons.shared.replaceFaviconInCaches(using: url, forDomain: webView?.url?.host)

    }
        
}
