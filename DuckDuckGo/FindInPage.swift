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
    
}

class FindInPage {

    weak var delegate: FindInPageDelegate?
    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
}
