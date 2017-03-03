//
//  WKWebViewExtensionTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 26/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
import WebKit

class WKWebViewExtensionTests: XCTestCase {
    
    func testCreatePrivateBrowserUsesNonPersistentDataStore() {
        let webView = WKWebView.createPrivateWebView(frame: CGRect())
        XCTAssertFalse(webView.configuration.websiteDataStore.isPersistent)
    }
    
}
