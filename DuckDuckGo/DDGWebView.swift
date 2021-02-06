//
//  DDGWebView.swift
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

class DDGWebView: WKWebView {

    weak var ddgWebViewDelegate: DDGWebViewDelegate?

    // swiftlint:disable identifier_name
    @IBAction func _lookup(_ sender: Any?) {
        print("***", #function, sender)
        evaluateJavaScript("window.getSelection().toString()") { [weak self] result, _ in
            guard let self = self,
                  let text = result as? String else { return }
            self.ddgWebViewDelegate?.webView(self, didRequestLookupText: text)
        }
    }
    // swiftlint:enable identifier_name

}

protocol DDGWebViewDelegate: AnyObject {

    func webView(_ webView: WKWebView, didRequestLookupText text: String)

}
