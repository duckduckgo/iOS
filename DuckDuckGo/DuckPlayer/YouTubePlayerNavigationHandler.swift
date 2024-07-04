//
//  YouTubePlayerNavigationHandler.swift
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
import ContentScopeScripts
import WebKit

final class YoutubePlayerNavigationHandler {
    
    var duckPlayer: DuckPlayerProtocol
    
    init(duckPlayer: DuckPlayerProtocol) {
        self.duckPlayer = duckPlayer
    }
    
    private static let templateDirectory = "pages/duckplayer"
    private static let templateName = "index"
    
    static var htmlTemplatePath: String {
        guard let file = ContentScopeScripts.Bundle.path(forResource: Self.templateName, ofType: "html", inDirectory: Self.templateDirectory) else {
            assertionFailure("YouTube Private Player HTML template not found")
            return ""
        }
        return file
    }

    static func makeDuckPlayerRequest(from originalRequest: URLRequest) -> URLRequest {
        guard let (youtubeVideoID, timestamp) = originalRequest.url?.youtubeVideoParams else {
            assertionFailure("Request should have ID")
            return originalRequest
        }
        return makeDuckPlayerRequest(for: youtubeVideoID, timestamp: timestamp)
    }

    static func makeDuckPlayerRequest(for videoID: String, timestamp: String?) -> URLRequest {
        var request = URLRequest(url: .youtubeNoCookie(videoID, timestamp: timestamp))
        request.addValue("http://localhost/", forHTTPHeaderField: "Referer")
        request.httpMethod = "GET"
        return request
    }

    static func makeHTMLFromTemplate() -> String {
        guard let html = try? String(contentsOfFile: htmlTemplatePath) else {
            assertionFailure("Should be able to load template")
            return ""
        }
        return html
    }
    
    private func performNavigation(_ request: URLRequest, responseHTML: String, webView: WKWebView) {
        // iOS 14 will be soon dropped out (and it does not support simulatedRequests)
        if #available(iOS 15.0, *) {
            webView.loadSimulatedRequest(request, responseHTML: responseHTML)
        }
    }
    
    private func performRequest(request: URLRequest, webView: WKWebView) {
        let html = Self.makeHTMLFromTemplate()
        let duckPlayerRequest = Self.makeDuckPlayerRequest(from: request)
        performNavigation(duckPlayerRequest, responseHTML: html, webView: webView)
    }
    
}

extension YoutubePlayerNavigationHandler: DuckNavigationHandling {

    // Handle rendering the simulated request if the URL is duck://
    // and DuckPlayer is either enabled or alwaysAsk
    @MainActor
    func handleNavigation(_ navigationAction: WKNavigationAction,
                          webView: WKWebView,
                          completion: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // If DuckPlayer is Enabled or in ask mode, render the video
        if let url = navigationAction.request.url,
            url.isDuckURLScheme,
           duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
            let html = Self.makeHTMLFromTemplate()
            let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
            if #available(iOS 15.0, *) {
                webView.loadSimulatedRequest(newRequest, responseHTML: html)
                completion(.allow)
                return
            }
        }
        
        // DuckPlayer is disabled, so we redirect to the video in YouTube
        if let url = navigationAction.request.url,
            let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayer.settings.mode == .disabled {
            webView.load(URLRequest(url: URL.youtube(videoID, timestamp: timestamp)))
            completion(.allow)
            return
        }
        
        completion(.allow)
        
    }
    
    // Handle URL changes not triggered via Omnibar
    // such as changes triggered via JS
    @MainActor
    func handleURLChange(url: URL?, webView: WKWebView) {
        if let url = url, url.isYoutubeVideo,
            !url.isDuckPlayer,
            let (videoID, timestamp) = url.youtubeVideoParams,
           duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
            webView.stopLoading()
            let newURL = URL.duckPlayer(videoID, timestamp: timestamp)
            webView.load(URLRequest(url: newURL))
        }
    }
    
    // DecidePolicyFor handler to redirect relevant requests
    // to duck://player
    @MainActor
    func handleDecidePolicyFor(_ navigationAction: WKNavigationAction,
                               completion: @escaping (WKNavigationActionPolicy) -> Void,
                               webView: WKWebView) {
        if let url = navigationAction.request.url,
            url.isYoutubeVideo,
            !url.isDuckPlayer, let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
            webView.load(URLRequest(url: .duckPlayer(videoID, timestamp: timestamp)))
            completion(.allow)
            return
        }
        completion(.allow)
    }
    
    // Handle Webview BackButton on DuckPlayer videos
    @MainActor
    func handleGoBack(webView: WKWebView) {
        guard let backURL = webView.backForwardList.backItem?.url,
                backURL.isYoutubeVideo,
                backURL.youtubeVideoParams?.videoID == webView.url?.youtubeVideoParams?.videoID,
                duckPlayer.settings.mode == .enabled else {
            webView.goBack()
            return
        }
        webView.goBack(skippingHistoryItems: 2)
    }
    
    
    // Handle Reload for DuckPlayer Videos
    @MainActor
    func handleReload(webView: WKWebView) {
        if let url = webView.url, url.isDuckPlayer,
            !url.isDuckURLScheme,
            let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
            webView.load(URLRequest(url: .duckPlayer(videoID, timestamp: timestamp)))
        } else {
            webView.reload()
        }
    }
}
