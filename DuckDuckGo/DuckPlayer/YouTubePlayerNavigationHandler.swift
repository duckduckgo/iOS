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
import Core

final class YoutubePlayerNavigationHandler {
    
    var duckPlayer: DuckPlayerProtocol
    var referrer: DuckPlayerReferrer = .other {
        didSet {
            print(referrer)
        }
    }
    
    private struct Constants {
        static let SERPURL =  "https://duckduckgo.com/"
        static let refererHeader = "Referer"
        static let templateDirectory = "pages/duckplayer"
        static let templateName = "index"
        static let templateExtension = "html"
        static let localhost = "http://localhost"
        static let duckPlayerAlwaysString = "always"
        static let duckPlayerDefaultString = "default"
        static let settingsKey = "settings"
        static let httpMethod = "GET"
    }
    
    init(duckPlayer: DuckPlayerProtocol) {
        self.duckPlayer = duckPlayer
    }
    
    static var htmlTemplatePath: String {
        guard let file = ContentScopeScripts.Bundle.path(forResource: Constants.templateName,
                                                         ofType: Constants.templateExtension,
                                                         inDirectory: Constants.templateDirectory) else {
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
        request.addValue(Constants.localhost, forHTTPHeaderField: Constants.refererHeader)
        request.httpMethod = Constants.httpMethod
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
        webView.loadSimulatedRequest(request, responseHTML: responseHTML)
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
        
        // Daily Unique View Pixel
        if let url = navigationAction.request.url,
           url.isDuckPlayer,
           duckPlayer.settings.mode != .disabled {
            let setting = duckPlayer.settings.mode == .enabled ? Constants.duckPlayerAlwaysString : Constants.duckPlayerDefaultString
            DailyPixel.fire(pixel: Pixel.Event.duckPlayerDailyUniqueView, withAdditionalParameters: [Constants.settingsKey: setting])
        }
        
        // Pixel for Views From Youtube
        if let url = navigationAction.request.url,
            referrer == .youtube,
            duckPlayer.settings.mode == .enabled {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromYoutubeAutomatic, debounce: 2)
        }
        
        // If DuckPlayer is Enabled or in ask mode, render the video
        if let url = navigationAction.request.url,
            url.isDuckURLScheme,
           duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
            let html = Self.makeHTMLFromTemplate()
            let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))

            webView.loadSimulatedRequest(newRequest, responseHTML: html)
            completion(.allow)
            return
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
        
        // Pixel for Views From SERP
        if let url = navigationAction.request.url,
            navigationAction.request.allHTTPHeaderFields?[Constants.refererHeader] == Constants.SERPURL,
            duckPlayer.settings.mode == .enabled, !url.isDuckPlayer {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromSERP, debounce: 2)
        }
        
        // Pixel for views from Other Sites
        if let url = navigationAction.request.url,
            navigationAction.request.allHTTPHeaderFields?[Constants.refererHeader] != Constants.SERPURL,
            duckPlayer.settings.mode == .enabled, !url.isDuckPlayer {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromOther, debounce: 2)
        }
        
        
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
