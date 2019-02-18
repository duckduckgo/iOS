//
//  FindInPage.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
