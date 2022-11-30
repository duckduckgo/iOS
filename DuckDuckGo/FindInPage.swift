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

}

class FindInPage: NSObject {

    weak var delegate: FindInPageDelegate?
    weak var webView: WKWebView?

    var searchTerm: String = ""
    var current: Int = 0
    var total: Int = 0

    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }

    func done() {
        evaluate(js: "window.__firefox__.findDone()")
    }

    func next() {
        evaluate(js: "window.__firefox__.findNext()")
    }

    func previous() {
        delegate?.updated(findInPage: self)
        evaluate(js: "window.__firefox__.findPrevious()")
    }

    func search(forText text: String) -> Bool {
        guard text != searchTerm else { return false }
        searchTerm = text
        
        let escaped =
        text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\'", with: "\\\'")

        evaluate(js: "window.__firefox__.find('\(escaped)')")

        return true
    }

    private func evaluate(js: String) {
        webView?.evaluateJavaScript(js, in: nil, in: .defaultClient)
    }

    func update(currentResult: Int?, totalResults: Int?) {
        current = currentResult ?? current
        total = totalResults ?? total
        delegate?.updated(findInPage: self)
    }

}
