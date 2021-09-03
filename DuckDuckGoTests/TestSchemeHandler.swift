//
//  TestSchemeHandler.swift
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

import XCTest
import WebKit

class TestSchemeHandler: NSObject, WKURLSchemeHandler {
    typealias RequestResponse = (URL) -> Data

    public var requestHandlers = [URL: RequestResponse]()

    public let scheme = "test"
    
    public var genericHandler: RequestResponse = { _ in
        return Data()
    }

    public var handledRequests = [URL]()

    func reset() {
        requestHandlers.removeAll()
        handledRequests.removeAll()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) { }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let url = urlSchemeTask.request.url!
        handledRequests.append(url)

        let handler = self.requestHandlers[url] ?? self.genericHandler

        let data = handler(url)

        let response = URLResponse(url: url,
                                   mimeType: "text/html",
                                   expectedContentLength: data.count,
                                   textEncodingName: nil)
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }
}
