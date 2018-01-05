//
//  WebEventsDelegate.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public protocol WebEventsDelegate: class {

    func attached(webView: WKWebView)
    
    func detached(webView: WKWebView)

    func contentProcessDidTerminate(webView: WKWebView)
    
    func webView(_ webView: WKWebView, shouldLoadUrl url: URL, forDocument documentUrl: URL) -> Bool
    
    func webView(_ webView: WKWebView, didReceiveLongPressForUrl url: URL, atPoint point: Point)

    func webView(_ webView: WKWebView, didUpdateHasOnlySecureContent hasOnlySecureContent: Bool)

    func webView(_ webView: WKWebView, didChangeUrl url: URL?)

    func webpageDidStartLoading()
    
    func webpageDidFinishLoading()
    
    func webpageDidFailToLoad()
    
    func faviconWasUpdated(_ favicon: URL, forUrl: URL)

}
