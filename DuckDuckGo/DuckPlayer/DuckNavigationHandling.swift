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
    func handleJSNavigation(url: URL?, webView: WKWebView)
    func handleDecidePolicyFor(_ navigationAction: WKNavigationAction,
                               completion: @escaping (WKNavigationActionPolicy) -> Void,
                               webView: WKWebView)
    func handleGoBack(webView: WKWebView)
    func handleReload(webView: WKWebView)
}

extension WKWebView {
   
    
    // This simulates going back an N number of elements
    // While this could use self.go(item) that will not
    // maintain scroll position.  This does.
    func goBack(skippingHistoryItems: Int) {
            guard skippingHistoryItems > 0 else {
                return
            }
            self.goBack()
            var remainingSkips = skippingHistoryItems - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.goBackSkippingHistoryItemsRecursively(remainingSkips)
            }
        }
        
        private func goBackSkippingHistoryItemsRecursively(_ remainingSkips: Int) {
            guard remainingSkips > 0 else {
                return
            }
            self.goBack()
            let newRemainingSkips = remainingSkips - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.goBackSkippingHistoryItemsRecursively(newRemainingSkips)
            }
        }
}
