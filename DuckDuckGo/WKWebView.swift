//
//  WKWebView.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

extension WKWebView {
    
    static func createPrivateBrowser(frame: CGRect) -> WKWebView {
        let webView = WKWebView.init(frame: frame)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        return webView
    }
    
    func clearCache(completionHandler: @escaping () -> Swift.Void) {
        let allData = WKWebsiteDataStore.allWebsiteDataTypes()
        let distantPast = Date.distantPast
        let dataStore = configuration.websiteDataStore
        dataStore.removeData(ofTypes: allData, modifiedSince: distantPast, completionHandler: completionHandler)
    }
}
