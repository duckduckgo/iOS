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
    
    func testWhenWebViewCreatedWithNonPersistenceThenDataStoreIsNonPersistent() {
        let webView = WKWebView.createWebView(frame: CGRect(), persistsData: false)
        XCTAssertFalse(webView.configuration.websiteDataStore.isPersistent)
    }

    func testWhenWebViewCreatedWithPersistenceThenDataStoreIsPersistent() {
        let webView = WKWebView.createWebView(frame: CGRect(), persistsData: true)
        XCTAssertTrue(webView.configuration.websiteDataStore.isPersistent)
    }
    
}
