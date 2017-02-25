//
//  WKWebView.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

extension WKWebView {
    
    public static func createPrivateBrowser(frame: CGRect) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let webView = WKWebView(frame: frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return webView
    }
    
    public func loadScripts() {
        let javacriptLoader = JavascriptLoader()
        javacriptLoader.load(.documentExtension, withController: configuration.userContentController)
    }
    
    public func clearCache(completionHandler: @escaping () -> Swift.Void) {
        let allData = WKWebsiteDataStore.allWebsiteDataTypes()
        let distantPast = Date.distantPast
        let dataStore = configuration.websiteDataStore
        dataStore.removeData(ofTypes: allData, modifiedSince: distantPast, completionHandler: completionHandler)
    }
    
    public func getUrlAtPoint(x: Int, y: Int, completion: @escaping (URL?) -> Swift.Void) {
        let javascript = "getHrefFromPoint(\(x), \(y))"
        evaluateJavaScript(javascript) { (result, error) in
            if let text = result as? String {
                let url = URL(string: text)
                completion(url)
            }
        }
    }
}
