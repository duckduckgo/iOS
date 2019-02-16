//
//  FindInPage.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 14/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation
import WebKit
import Core

protocol FindInPageDelegate: NSObjectProtocol {
    
    func updated(findInPage: FindInPage)

    func done(findInPage: FindInPage)

}

class FindInPage: NSObject {

    weak var delegate: FindInPageDelegate?
    let webView: WKWebView

    var searchTerm: String = ""
    var current: Int = 0
    var total: Int = 0

    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }

    func done() {
        delegate?.done(findInPage: self)
        webView.evaluateJavaScript("window.__firefox__.findDone()")
    }

    func next() {
        webView.evaluateJavaScript("window.__firefox__.findNext()")
    }

    func previous() {
        delegate?.updated(findInPage: self)
        webView.evaluateJavaScript("window.__firefox__.findPrevious()")
    }

    func search(forText text: String) {
        guard text != searchTerm else { return }
        searchTerm = text
        webView.evaluateJavaScript("window.__firefox__.find('\(text)')")
    }

    func update(currentResult: Int?, totalResults: Int?) {
        current = currentResult ?? current
        total = totalResults ?? total
        delegate?.updated(findInPage: self)
    }

}

extension FindInPage: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

    }

}
