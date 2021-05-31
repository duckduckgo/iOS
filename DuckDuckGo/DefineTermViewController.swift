//
//  DefineTermViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

class DefineTermViewController: UIViewController {

    var term: String?
    weak var parentTabViewController: TabViewController?

    let webView = WebView(frame: .zero, configuration: .nonPersistent())

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.webViewDelegate = self
        webView.frame = view.frame
        webView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        view.addSubview(webView)

        if let term = term {
            load(term: term)
        }
    }

    func load(term: String) {
        print("***", #function, term)
        let appUrls = AppUrls()
        let query = "define: \(term)"
        let queryUrl = appUrls.url(forQuery: query)
        let url = appUrls.applySearchHeaderParams(for: queryUrl)
        webView.load(URLRequest(url: url))
    }

}

extension DefineTermViewController: WebViewDelegate {

    func webView(_: WebView, didRequestDefinitionOfTerm term: String) {
        load(term: term)
    }

}
