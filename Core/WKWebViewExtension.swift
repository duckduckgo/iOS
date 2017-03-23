//
//  WKWebView.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

extension WKWebView {
    
    public static func createPrivateWebView(frame: CGRect) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        if #available(iOSApplicationExtension 10.0, *) {
            configuration.dataDetectorTypes = .link
        }
        let webView = WKWebView(frame: frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return webView
    }
    
    public func createSiblingWebView() -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return webView
    }
    
    public func clearCache(completionHandler: @escaping () -> Swift.Void) {
        let allData = WKWebsiteDataStore.allWebsiteDataTypes()
        let distantPast = Date.distantPast
        let dataStore = configuration.websiteDataStore
        dataStore.removeData(ofTypes: allData, modifiedSince: distantPast, completionHandler: completionHandler)
    }
    
    public func loadScripts() {
        load(scripts: [.document, .favicon])
    }
    
    private func load(scripts: [JavascriptLoader.Script]) {
        let javascriptLoader = JavascriptLoader()
        for script in scripts {
            javascriptLoader.load(script, withController: configuration.userContentController)
        }
    }
    
    public func getUrlAtPoint(x: Int, y: Int, completion: @escaping (URL?) -> Swift.Void) {
        let javascript = "duckduckgoDocument.getHrefFromPoint(\(x), \(y))"
        evaluateJavaScript(javascript) { (result, error) in
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
        evaluateJavaScript(javascript) { (result, error) in
            if let text = result as? String {
                url = URL(string: text)
            }
            complete = true
        }
        
        while (!complete) {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture)
        }
        return url
    }
    
    public func getFavicon(completion: @escaping (URL?) -> Swift.Void) {
        let javascript = "duckduckgoFavicon.getFavicon()"
        evaluateJavaScript(javascript) { (result, error) in
            guard let urlString = result as? String else { completion(nil); return }
            guard let url = URL(string: urlString) else { completion(nil); return }
            completion(url)
        }
    }
}
