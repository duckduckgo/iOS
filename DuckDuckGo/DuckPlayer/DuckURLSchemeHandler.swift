//
//  DuckURLSchemeHandler.swift
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

final class DuckURLSchemeHandler: NSObject, WKURLSchemeHandler {

    static let emptyHtml = """
    <html>
      <head>
        <style>
          body {
            background: rgb(255, 255, 255);
            display: flex;
            height: 100vh;
          }
          // avoid page blinking in dark mode
          @media (prefers-color-scheme: dark) {
            body {
              background: rgb(51, 51, 51);
            }
          }
        </style>
      </head>
      <body />
    </html>
    """

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let requestURL = webView.url ?? urlSchemeTask.request.url else {
            assertionFailure("No URL for Private Player scheme handler")
            return
        }

        let youtubeHandler = YoutubePlayerNavigationHandler()
        let html = youtubeHandler.makeHTMLFromTemplate()
        let newRequest = youtubeHandler.makeDuckPlayerRequest(from: URLRequest(url: requestURL))
        if #available(iOS 15.0, *) {
            webView.loadSimulatedRequest(newRequest, responseHTML: html)
        } else {
            // Duckplayer will not be supported on iOS 14
        }
        
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
