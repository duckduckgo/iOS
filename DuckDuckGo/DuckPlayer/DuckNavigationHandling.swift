//
//  DuckNavigationHandling.swift
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

import WebKit

protocol DuckNavigationHandling {
    var referrer: DuckPlayerReferrer { get set }
    var duckPlayer: DuckPlayerProtocol { get }
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView)
    func handleURLChange(url: URL?, webView: WKWebView)
    func handleDecidePolicyFor(_ navigationAction: WKNavigationAction, webView: WKWebView)
    func handleGoBack(webView: WKWebView)
    func handleReload(webView: WKWebView)
}

extension WKWebView {
   
   func goBack(skippingHistoryItems: Int) {
       
       let backList = self.backForwardList.backList
       guard skippingHistoryItems > 1,
       let lastElement = backList[safe: backList.count - skippingHistoryItems] else {
           self.goBack()
           return
       }
       self.go(to: lastElement)
   }
   
}
