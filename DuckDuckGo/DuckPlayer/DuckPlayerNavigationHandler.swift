//
//  DuckPlayerNavigationHandler.swift
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
import Common

final class DuckPlayerNavigationHandler {
    
    var duckPlayer: DuckPlayerProtocol
    var referrer: DuckPlayerReferrer = .other
    var lastHandledVideoID: String?
    
        var isDuckPlayerTemporarilyDisabled = false
    
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
        static let watchInYoutubePath = "openInYoutube"
        static let watchInYoutubeVideoParameter = "v"
        static let urlInternalReferrer = "embeds_referring_euri"
    }
    
    init(duckPlayer: DuckPlayerProtocol) {
        self.duckPlayer = duckPlayer
        os_log("DP: Trying to load the same video while in DuckPlayer, use Youtube:", log: .duckPlayerLog, type: .debug)
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
    
    func hasEmbedsReferringEuriParameter(urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return false
        }

        for queryItem in queryItems where queryItem.name == Constants.urlInternalReferrer {
            return true
        }

        return false
    }
    
}

extension DuckPlayerNavigationHandler: DuckNavigationHandling {

    // Handle rendering the simulated request if the URL is duck://
    // and DuckPlayer is either enabled or alwaysAsk
    @MainActor
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView) {
        
        os_log("DP: Handling DuckPlayer Player Navigation for %s", log: .duckPlayerLog, type: .debug, navigationAction.request.url?.absoluteString ?? "")
       
        guard let url = navigationAction.request.url else { return }
        
        // Handle Youtube internal links like "Age restricted" and "Copyright restricted" videos
        // These should not be handled by DuckPlayer
        if url.isYoutubeVideo,
            hasEmbedsReferringEuriParameter(urlString: url.absoluteString) {
                return
        }
        
        // Handle Open in Youtube Links
        // duck://player/openInYoutube?v=12345
        if url.scheme == "duck" {
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            if urlComponents?.path == "/\(Constants.watchInYoutubePath)",
               let queryItems = urlComponents?.queryItems {
                
                if let videoParameterItem = queryItems.first(where: { $0.name == Constants.watchInYoutubeVideoParameter }),
                   let id = videoParameterItem.value {
                        // Disable DP temporarily
                        isDuckPlayerTemporarilyDisabled = true
                        handleURLChange(url: URL.youtube(id, timestamp: nil), webView: webView)
                        return
                }
            }
        }
        
        // Daily Unique View Pixel
        if url.isDuckPlayer,
           duckPlayer.settings.mode != .disabled {
            let setting = duckPlayer.settings.mode == .enabled ? Constants.duckPlayerAlwaysString : Constants.duckPlayerDefaultString
            DailyPixel.fire(pixel: Pixel.Event.duckPlayerDailyUniqueView, withAdditionalParameters: [Constants.settingsKey: setting])
        }
        
        // Pixel for Views From Youtube
        if referrer == .youtube,
            duckPlayer.settings.mode == .enabled {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromYoutubeAutomatic, debounce: 2)
        }
        
        // If DuckPlayer is Enabled or in ask mode, render the video
        if url.isDuckURLScheme,
           duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk,
            !isDuckPlayerTemporarilyDisabled {
            let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
            if #available(iOS 15.0, *) {
                os_log("DP: Loading Simulated Request for %s", log: .duckPlayerLog, type: .debug, navigationAction.request.url?.absoluteString ?? "")
                performRequest(request: newRequest, webView: webView)
                return
            }
        }
        
        // DuckPlayer is disabled, so we redirect to the video in YouTube
        if let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayer.settings.mode == .disabled {
            os_log("DP: is Disabled. We should load original video for %s", log: .duckPlayerLog, type: .debug)
            handleURLChange(url: URL.youtube(videoID, timestamp: timestamp), webView: webView)
            return
        }
    }
    
    // Handle URL changes not triggered via Omnibar
    // such as changes triggered via JS
    @MainActor
    func handleURLChange(url: URL?, webView: WKWebView) {

        guard let url else { return }
        
        // Handle Youtube internal links like "Age restricted" and "Copyright restricted" videos
         // These should not be handled by DuckPlayer
        if url.isYoutubeVideo,
             hasEmbedsReferringEuriParameter(urlString: url.absoluteString) {
                 return
         }
        
        // Do not handle the URL if the video was just handled
       if url.isYoutubeVideo || url.isDuckPlayer,
           let (videoID, _) = url.youtubeVideoParams,
            lastHandledVideoID == videoID,
            !isDuckPlayerTemporarilyDisabled {
                return
        }
        
        if url.isYoutubeVideo,
            !url.isDuckPlayer,
            let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
            
            os_log("DP: Handling URL change: %s", log: .duckPlayerLog, type: .debug, url.absoluteString)
            var newURL = URL.duckPlayer(videoID, timestamp: timestamp)
            
            // IF DP is temporarily disabled, load Youtube website
            // Then reset the setting
            if isDuckPlayerTemporarilyDisabled {
                os_log("DP: Duckplayer is temporarily disabled.  Opening Youtube", log: .duckPlayerLog, type: .debug)
                newURL = URL.youtube(videoID, timestamp: timestamp)
            } else {
                os_log("DP: Duckplayer is NOT disabled.  Opening DuckPlayer", log: .duckPlayerLog, type: .debug)
            }
            
            // Load the URL
            webView.load(URLRequest(url: newURL))
            
            // Add a delay before resetting to allow the Webview to properly render
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.lastHandledVideoID = videoID
                self.isDuckPlayerTemporarilyDisabled = false
            }
        }
    }
    
    // DecidePolicyFor handler to redirect relevant requests
    // to duck://player
    @MainActor
    func handleDecidePolicyFor(_ navigationAction: WKNavigationAction,
                               webView: WKWebView) {
        
        guard let url = navigationAction.request.url else { return }
        
         // Handle Youtube internal links like "Age restricted" and "Copyright restricted" videos
         // These should not be handled by DuckPlayer
         if url.isYoutubeVideo,
             hasEmbedsReferringEuriParameter(urlString: url.absoluteString) {
                 return
         }
        
        // Do not handle the URL if the video was just handled
        if url.isYoutubeVideo || url.isDuckPlayer,
           let (videoID, timestamp) = url.youtubeVideoParams,
            lastHandledVideoID == videoID,
            !isDuckPlayerTemporarilyDisabled {
                return
        }
        

        // Pixel for Views From SERP
        if navigationAction.request.allHTTPHeaderFields?[Constants.refererHeader] == Constants.SERPURL,
            duckPlayer.settings.mode == .enabled, !url.isDuckPlayer {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromSERP, debounce: 2)
        } else {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromOther, debounce: 2)
        }
        
        if url.isYoutubeVideo,
           !url.isDuckPlayer,
            let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk {
                os_log("DP: Handling decidePolicy for Duck Player with %s", log: .duckPlayerLog, type: .debug, url.absoluteString)
                handleURLChange(url: URL.duckPlayer(videoID, timestamp: timestamp), webView: webView)
            return
        }
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
            os_log("DP: Handling DuckPlayer Reload for %s", log: .duckPlayerLog, type: .debug, url.absoluteString)
            webView.load(URLRequest(url: .duckPlayer(videoID, timestamp: timestamp)))
        } else {
            webView.reload()
        }
    }
}
