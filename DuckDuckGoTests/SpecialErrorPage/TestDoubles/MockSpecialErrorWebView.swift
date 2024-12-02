//
//  MockSpecialErrorWebView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

class MockSpecialErrorWebView: WKWebView {

    var loadRequestHandler: ((URLRequest, String) -> Void)?
    var currentURL: URL?
    private var _canGoBack: Bool = false

    private(set) var didCallGoBack = false
    private(set) var didCallReload = false

    override func loadSimulatedRequest(_ request: URLRequest, responseHTML string: String) -> WKNavigation {
        loadRequestHandler?(request, string)
        return super.loadSimulatedRequest(request, responseHTML: string)
    }

    override var url: URL? {
        currentURL
    }

    func setCurrentURL(_ url: URL) {
        self.currentURL = url
    }

    override var canGoBack: Bool {
        _canGoBack
    }

    func setCanGoBack(_ canGoBack: Bool) {
        _canGoBack = canGoBack
    }

    override func goBack() -> WKNavigation? {
        didCallGoBack = true
        return super.goBack()
    }

    override func reload() -> WKNavigation? {
        didCallReload = true
        return super.reload()
    }

}
