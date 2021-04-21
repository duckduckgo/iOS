//
//  BookmarkletPolicy.swift
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

import Foundation
import WebKit

class BookmarkletPolicy: NavigationActionPolicy {

    private weak var webView: WKWebView?

    init(webView: WKWebView) {
        self.webView = webView
    }

    func check(navigationAction: WKNavigationAction, completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        guard let url = navigationAction.request.url,
              url.isBookmarklet(),
              let js = url.toDecodedBookmarklet() else {
            completion(.allow, nil)
            return
        }

        completion(.cancel) {
            self.webView?.evaluateJavaScript(js)
        }

    }

}
