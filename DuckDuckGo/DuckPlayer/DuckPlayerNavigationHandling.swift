//
//  DuckPlayerNavigationHandling.swift
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

enum DuckPlayerNavigationHandlerURLChangeResult {
    
    enum HandlingResult {
        case featureOff
        case invalidURL
        case duckPlayerDisabled
        case isNotYoutubeWatch
        case disabledForVideo        
        case duplicateNavigation
    }

    case handled
    case notHandled(HandlingResult)
}

enum DuckPlayerNavigationDirection {
    case back, forward
}


protocol DuckPlayerNavigationHandling: AnyObject {
    var referrer: DuckPlayerReferrer { get set }
    var tabNavigationHandler: DuckPlayerTabNavigationHandling? { get set }
    var duckPlayer: DuckPlayerProtocol { get }
    func handleNavigation(_ navigationAction: WKNavigationAction,
                          webView: WKWebView)
    func handleURLChange(webView: WKWebView) -> DuckPlayerNavigationHandlerURLChangeResult
    func handleGoBack(webView: WKWebView)
    func handleReload(webView: WKWebView)
    func handleAttach(webView: WKWebView)
    func handleDidFinishLoading(webView: WKWebView)
    func getDuckURLFor(_ url: URL) -> URL
    func shouldCancelNavigation(navigationAction: WKNavigationAction, webView: WKWebView) -> Bool
    func setReferrer(navigationAction: WKNavigationAction, webView: WKWebView)    
    
}

protocol DuckPlayerTabNavigationHandling: AnyObject {
    var isNewTab: Bool { get }
    func openTab(for url: URL)
    func closeTab()
    
}
