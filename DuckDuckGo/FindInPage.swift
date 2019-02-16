//
//  FindInPage.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 14/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation
import WebKit

protocol FindInPageDelegate: NSObjectProtocol {
    
    func updated(findInPage: FindInPage)

    func done(findInPage: FindInPage)

}

// TODO call the JS
class FindInPage {

    weak var delegate: FindInPageDelegate?
    let webView: WKWebView

    var searchTerm: String = ""
    var current: Int = 0
    var total: Int = 0

    init(webView: WKWebView) {
        self.webView = webView
    }

    func done() {
        delegate?.done(findInPage: self)
    }

    func next() {
        current += 1
        if current > total {
            current = 1
        }
        delegate?.updated(findInPage: self)
    }

    func previous() {
        current -= 1
        if current < 1 {
            current = total
        }
        delegate?.updated(findInPage: self)
    }

    func search(forText text: String) {
        searchTerm = text
        total = text.isEmpty ? 0 : 3
        current = 1
        delegate?.updated(findInPage: self)
    }

}
