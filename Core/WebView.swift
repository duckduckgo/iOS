//
//  WebView.swift
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

import WebKit

public protocol WebViewDelegate: AnyObject {

    func webView(_ :WebView, didRequestDefinitionOfTerm term: String)

}

public class WebView: WKWebView {

    public weak var webViewDelegate: WebViewDelegate?

    // swiftlint:disable identifier_name
    @IBAction func _lookup(_ sender: UIMenuController?) {
        evaluateJavaScript("window.getSelection().toString()") { result, _ in
            guard let term = result as? String else { return }
            self.webViewDelegate?.webView(self, didRequestDefinitionOfTerm: term)
        }
    }
    // swiftlint:enable identifier_name

}
