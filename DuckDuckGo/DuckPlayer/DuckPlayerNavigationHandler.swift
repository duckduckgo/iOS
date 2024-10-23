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
import BrowserServicesKit
import DuckPlayer
import os.log

final class DuckPlayerNavigationHandler {
        
    var duckPlayer: DuckPlayerProtocol
    var referrer: DuckPlayerReferrer = .other
    var renderedVideoID: String?
    var renderedURL: URL?
    var featureFlagger: FeatureFlagger
    var appSettings: AppSettings
    var navigationType: WKNavigationType = .other
    var pixelFiring: PixelFiring.Type
    private lazy var internalUserDecider = AppDependencyProvider.shared.internalUserDecider
    
    private struct Constants {
        static let SERPURL =  "duckduckgo.com/"
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
        static let youtubeScheme = "youtube://"
        static let duckPlayerScheme = URL.NavigationalScheme.duck.rawValue
        static let duckPlayerHeaderKey = "X-Navigation-Source"
        static let duckPlayerHeaderValue = "DuckPlayer"
        static let duckPlayerReferrerHeaderKey = "X-Navigation-DuckPlayerReferrer"
    }
    
    init(duckPlayer: DuckPlayerProtocol = DuckPlayer(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         appSettings: AppSettings,
         pixelFiring: PixelFiring.Type = Pixel.self) {
        self.duckPlayer = duckPlayer
        self.featureFlagger = featureFlagger
        self.appSettings = appSettings
        self.pixelFiring = pixelFiring
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
    
    private var duckPlayerMode: DuckPlayerMode {
        let isEnabled = featureFlagger.isFeatureOn(.duckPlayer)
        return isEnabled ? duckPlayer.settings.mode : .disabled
    }
    
    private var isYouTubeAppInstalled: Bool {
        if let youtubeURL = URL(string: Constants.youtubeScheme) {
            return UIApplication.shared.canOpenURL(youtubeURL)
        }
        return false
    }
    
    private func getYoutubeURLFromOpenInYoutubeLink(url: URL) -> URL? {
        guard isWatchInYouTubeURL(url: url),
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let videoParameterItem = urlComponents.queryItems?.first(where: { $0.name == Constants.watchInYoutubeVideoParameter }),
              let id = videoParameterItem.value,
              let newURL = URL.youtube(id, timestamp: nil).addingWatchInYoutubeQueryParameter() else {
            return nil
        }
        return newURL
    }

    private func isWatchInYouTubeURL(url: URL) -> Bool {
        guard url.scheme == Constants.duckPlayerScheme,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              urlComponents.path == "/\(Constants.watchInYoutubePath)" else {
            return false
        }
        return true
    }
    
    // Validates a duck:// url and loads it
    private func redirectToDuckPlayerVideo(url: URL?, webView: WKWebView) {
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
        
        
        // Open in new tab if needed
        if let url = webView.url,
            duckPlayer.settings.openInNewTab {
            openInNewTab(isJavascriptLink: true, webView: webView)
            return
        }
        
        renderedURL = url
        renderedVideoID = videoID
        let duckPlayerURL = URL.duckPlayer(videoID)
        Logger.duckPlayer.debug("DP: Redirecting to DuckPlayer Video: \(duckPlayerURL.absoluteString)")
        loadWithDuckPlayerHeaders(URLRequest(url: duckPlayerURL), referrer: referrer, webView: webView)
        
    }
    
    // Validates a youtube watch URL and loads it
    private func redirectToYouTubeVideo(url: URL?, webView: WKWebView) {
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
        
        var redirectURL = url
        
        // Parse OpenInYouTubeURLs if present
        if let parsedURL = getYoutubeURLFromOpenInYoutubeLink(url: url) {
            redirectURL = parsedURL
        }
        duckPlayer.settings.allowFirstVideo = true
        renderedVideoID = videoID
        if let finalURL = redirectURL.addingWatchInYoutubeQueryParameter() {
            loadWithDuckPlayerHeaders(URLRequest(url: redirectURL), referrer: referrer, webView: webView)
        }
    }
    
    // Performs a simple back/forward navigation
    private func performBackForwardNavigation(webView: WKWebView, direction: DuckPlayerNavigationDirection) {
        if direction == .back {
            webView.goBack()
        } else {
            webView.goForward()
        }
    }
    
    // Fire pixels displayed when DuckPlayer is shown
    private func fireDuckPlayerPixels() {
        
        // First daily unique user Duck Player view
        pixelFiring.fire(.duckPlayerDailyUniqueView, withAdditionalParameters: ["settings": duckPlayer.settings.mode.stringValue])
        
        // Duck Player viewed with Always setting, referred from YouTube
        if (referrer == .youtube) && duckPlayer.settings.mode == .enabled {
            pixelFiring.fire(.duckPlayerViewFromYoutubeAutomatic, withAdditionalParameters: [:])
        }
        
        // Duck Player viewed from SERP overlay
        if referrer == .serp && duckPlayer.settings.mode == .enabled {
            pixelFiring.fire(.duckPlayerViewFromSERP, withAdditionalParameters: [:])
        }
        
        // Other referers
        if referrer == .other {
            pixelFiring.fire(.duckPlayerViewFromOther, withAdditionalParameters: [:])
        }
        
    }
    
    private func fireOpenInYoutubePixel() {
        pixelFiring.fire(.duckPlayerWatchOnYoutube, withAdditionalParameters: [:])
    }
    
    private func openInNewTab(isJavascriptLink: Bool, webView: WKWebView) {
        
        if isJavascriptLink {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                webView.stopLoading()
                webView.goBack()
            }
            
        }
        
    }
    
    // Replaces webView.load to add DuckPlayer headers, used for navigation
    func loadWithDuckPlayerHeaders(_ request: URLRequest, referrer: DuckPlayerReferrer, webView: WKWebView) {
            
        var newRequest = request
                
        newRequest.addValue("DuckPlayer", forHTTPHeaderField: DuckPlayerNavigationHandler.Constants.duckPlayerHeaderKey)
        newRequest.addValue(referrer.stringValue, forHTTPHeaderField: DuckPlayerNavigationHandler.Constants.duckPlayerReferrerHeaderKey)
                
        webView.load(newRequest)
    }
    
}

extension DuckPlayerNavigationHandler: DuckPlayerNavigationHandling {
    
    // Handle rendering the simulated request for duck:// links
    @MainActor
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView) {

        // Check if should open in a new tab
        if duckPlayer.settings.openInNewTab {
            
            return
        }
        
        Logger.duckPlayer.debug("Handling Navigation for \(navigationAction.request.url?.absoluteString ?? "")")
                
        duckPlayer.settings.allowFirstVideo = false // Disable overlay for first video

        guard let url = navigationAction.request.url else { return }

        // Redirect to YouTube if DuckPlayer is disabled
        guard featureFlagger.isFeatureOn(.duckPlayer) && duckPlayer.settings.mode != .disabled else {
            if let (videoID, _) = url.youtubeVideoParams {
                loadWithDuckPlayerHeaders(URLRequest(url: URL.youtube(videoID)), referrer: referrer, webView: webView)
            }
            return
        }
        
        // Handle "open in YouTube" links (duck://player/openInYoutube)
        if let newURL = getYoutubeURLFromOpenInYoutubeLink(url: url),
           let (videoID, _) = newURL.youtubeVideoParams {
            
            duckPlayer.settings.allowFirstVideo = true // Always skip overlay for these links
            
            // Fire a Pixel for Open in Youtube
            self.fireOpenInYoutubePixel()
                
            
            // Attempt to open in YouTube app or load in webView
            if appSettings.allowUniversalLinks, isYouTubeAppInstalled,
               let youtubeAppURL = URL(string: "\(Constants.youtubeScheme)\(videoID)") {
                UIApplication.shared.open(youtubeAppURL)
            } else {
                redirectToYouTubeVideo(url: newURL, webView: webView)
            }
            return
        }

        // Handle duck:// scheme URLs
        if url.isDuckURLScheme,
           let (videoID, _) = url.youtubeVideoParams {

            // Simulate DuckPlayer request if in enabled/ask mode and not redirected to YouTube
            if duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk,
               !url.hasWatchInYoutubeQueryParameter {
                let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
                Logger.duckPlayer.debug("DP: Loading Simulated Request for \(url.absoluteString)")
                
                // The webview needs some time for state to propagate
                // Before performing the simulated request
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    webView.stopLoading()
                    self.performRequest(request: newRequest, webView: webView)
                    self.renderedVideoID = videoID
                    self.fireDuckPlayerPixels()
                }
            } else {
                redirectToYouTubeVideo(url: url, webView: webView)
            }
            return
        }

        // Handle YouTube watch URLs based on DuckPlayer settings
        if url.isYoutubeWatch, duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk {
            if url.hasWatchInYoutubeQueryParameter {
                redirectToYouTubeVideo(url: url, webView: webView)
            } else {
                redirectToDuckPlayerVideo(url: url, webView: webView)
            }
        }
    }
    
    @MainActor
    func handleURLChange(webView: WKWebView) -> DuckPlayerNavigationHandlerURLChangeResult {
        
        Logger.duckPlayer.debug("DP: Initializing Navigation handler for URL: \(webView.url?.absoluteString ?? "No URL")")
        
        // Check if DuckPlayer feature is ON
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            Logger.duckPlayer.debug("DP: Feature flag is off, skipping")
            return .notHandled(.featureOff)
        }
        
        // Check if the URL is a DuckPlayer URL (handled elsewhere)
        guard !(webView.url?.isDuckURLScheme ?? false) else {
            return .notHandled(.isAlreadyDuckAddress)
        }
        
        // If the URL hasn't changed, exit
        guard webView.url != renderedURL else {
            Logger.duckPlayer.debug("DP: URL has not changed, skipping")
            return .notHandled(.urlHasNotChanged)
        }
                
        // Disable the Youtube Overlay for Player links
        // Youtube player links should open the video in Youtube
        // without overlay
        if let url = webView.url, url.hasWatchInYoutubeQueryParameter {
            duckPlayer.settings.allowFirstVideo = true
            return .notHandled(.disabledForNextVideo)
        }
        
        // Ensure DuckPlayer is active
        guard duckPlayer.settings.mode == .enabled else {
            Logger.duckPlayer.debug("DP: DuckPlayer is Disabled, skipping")
            return .notHandled(.duckPlayerDisabled)
        }
        
        // Update rendered URL and Referer if needed
        if let url = webView.url {
            renderedURL = url
        }
        
        // Check for valid YouTube video parameters
        guard let url = webView.url,
              let (videoID, _) = url.youtubeVideoParams else {
            Logger.duckPlayer.debug("DP: No video parameters present in the URL, skipping")
            renderedVideoID = nil
            return .notHandled(.videoIDNotPresent)
        }
        
        // If the video has already been rendered, exit
        guard renderedVideoID != videoID else {
            Logger.duckPlayer.debug("DP: Video already rendered, skipping")
            return .notHandled(.videoAlreadyHandled)
        }
        
        // If DuckPlayer is disabled for the next video, skip handling and reset
        if duckPlayer.settings.allowFirstVideo {
            duckPlayer.settings.allowFirstVideo = false
            Logger.duckPlayer.debug("DP: Skipping video, DuckPlayer disabled for the next video")
            renderedVideoID = videoID
            return .notHandled(.disabledForNextVideo)
        }
        
        // Finally, handle the redirection to DuckPlayer
        Logger.duckPlayer.debug("DP: Handling navigation for \(webView.url?.absoluteString ?? "No URL")")
        redirectToDuckPlayerVideo(url: url, webView: webView)
        return .handled
    }

    
    @MainActor
    func handleBackForwardNavigation(webView: WKWebView, direction: DuckPlayerNavigationDirection) {
        
        // Reset DuckPlayer status
        duckPlayer.settings.allowFirstVideo = false
            
        Logger.duckPlayer.debug("DP: Handling \(direction == .back ? "Back" : "Forward") Navigation")
        
        // Check if the DuckPlayer feature is enabled
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            performBackForwardNavigation(webView: webView, direction: direction)
            return
        }
        
        // Check if the list has items in the desired direction
        let navigationList = direction == .back ? webView.backForwardList.backList : webView.backForwardList.forwardList
        guard !navigationList.isEmpty else {
            performBackForwardNavigation(webView: webView, direction: direction)
            return
        }

        // If we are not at DuckPlayer, just perform the navigation
        if !(webView.url?.isDuckPlayer ?? false) {
            performBackForwardNavigation(webView: webView, direction: direction)
            
        } else {
            // We may need to skip the YouTube video already rendered in DuckPlayer
            guard let (listVideoID, _) = (direction == .back ? navigationList.reversed().first : navigationList.first)?.url.youtubeVideoParams,
                  let (currentVideoID, _) = webView.url?.youtubeVideoParams,
                  duckPlayer.settings.mode != .disabled else {
                performBackForwardNavigation(webView: webView, direction: direction)
                return
            }
            
            // Check if the current and previous/next video IDs match
            if listVideoID == currentVideoID {
                let reversedList = navigationList.reversed()
                let nextIndex = reversedList.index(reversedList.startIndex, offsetBy: direction == .back ? 1 : 0)
                
                if nextIndex < reversedList.endIndex {
                    webView.go(to: reversedList[nextIndex])
                } else {
                    performBackForwardNavigation(webView: webView, direction: direction)
                }
            } else {
                performBackForwardNavigation(webView: webView, direction: direction)
            }
        }
    }

    
    // Handle Reload for DuckPlayer Videos
    @MainActor
    func handleReload(webView: WKWebView) {
        
        Logger.duckPlayer.debug("DP: Handling Reload")
                
        // Reset DuckPlayer status
        duckPlayer.settings.allowFirstVideo = false
        renderedVideoID = nil
        renderedURL = nil
        
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            webView.reload()
            return
        }
                
        if let url = webView.url, url.isDuckPlayer,
            !url.isDuckURLScheme,
            let (videoID, timestamp) = url.youtubeVideoParams,
            duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk {
            Logger.duckPlayer.debug("DP: Handling DuckPlayer Reload for \(url.absoluteString)")
            redirectToDuckPlayerVideo(url: url, webView: webView)
        } else {
            webView.reload()
        }
    }
    
    @MainActor
    func handleAttach(webView: WKWebView) {
        
        Logger.duckPlayer.debug("DP: Attach WebView")
        
        // Reset DuckPlayer status
        duckPlayer.settings.allowFirstVideo = false
                
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            return
        }
        
        if let url = webView.url, url.isDuckPlayer,
            !url.isDuckURLScheme,
            duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk {
            Logger.duckPlayer.debug("DP: Handling Initial Load of a video for \(url.absoluteString)")
            handleReload(webView: webView)
        }
        
    }
    
    // Get the duck:// URL youtube-no-cookie URL
    func getDuckURLFor(_ url: URL) -> URL {
        guard let (youtubeVideoID, timestamp) = url.youtubeVideoParams,
                url.isDuckPlayer,
                !url.isDuckURLScheme,
                duckPlayerMode != .disabled
        else {
            return url
        }
        return URL.duckPlayer(youtubeVideoID, timestamp: timestamp)
    }
    
    // Sets the referrer based on URL and headers
    func setReferrer(navigationAction: WKNavigationAction, webView: WKWebView) {
                    
        // If there is a SERP referer Header, use it
        if let referrer = navigationAction.request.allHTTPHeaderFields?[Constants.refererHeader], referrer.contains(Constants.SERPURL) {
            self.referrer = .serp
            return
        }
        
        // If this is a new tab (no history), but there's a DuckPlayer header, use it
        if webView.backListItemsCount() == 0,
           let headers = navigationAction.request.allHTTPHeaderFields,
           let navigationSource = headers[Constants.duckPlayerReferrerHeaderKey] {
            
            switch navigationSource {
            case DuckPlayerReferrer.serp.stringValue:
                referrer = .serp
            case DuckPlayerReferrer.youtube.stringValue:
                referrer = .youtube
            case DuckPlayerReferrer.other.stringValue:
                referrer = .other
            default:
                break
            }
            return
        }
        
        // If There's no history, and the user arrived directly
        // at Watch
        if webView.backListItemsCount() == 0
            && webView.url?.isYoutubeWatch ?? false || webView.url == nil
            && duckPlayer.settings.mode == .enabled {
            referrer = .other
            return
        }
        
        // Set the referrer to be Youtube Overlay
        // when disable and visiting a video page
        if webView.url?.isYoutubeWatch ?? false
            && duckPlayer.settings.mode == .alwaysAsk {
            referrer = .youtubeOverlay
            return
        }
                        
        // Otherwise, just set the header based on the URL
        if let url = navigationAction.request.url {
            
            // We only need a referrer when DP is enabled
            if url.isDuckPlayer && duckPlayer.settings.mode == .enabled {
                referrer = .youtube
                return
            }
        }
    }

    // Determine if navigation should be cancelled
    // This is to be used in DecidePolicy For to prevent the webView
    // from opening the Youtube app on user-triggered links
    @MainActor
    func shouldCancelNavigation(navigationAction: WKNavigationAction, webView: WKWebView) -> Bool {
                        
        // If the custom "X-Navigation-Source" header is present
        // And we should open in the same dont cancel.
        if let headers = navigationAction.request.allHTTPHeaderFields,
           let navigationSource = headers[Constants.duckPlayerHeaderKey],
           navigationSource == Constants.duckPlayerHeaderValue {
            return false
        }

        // Otherwise, validate if the page is a Youtube page, and DuckPlayer is Enabled
        if featureFlagger.isFeatureOn(.duckPlayer),
            duckPlayer.settings.mode != .disabled,
            let url = navigationAction.request.url,
            url.isYoutube || url.isYoutubeWatch {
                        
            // If we should open in the same tab, go ahead
            if !duckPlayer.settings.openInNewTab {
                loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
                return true
            }
            
            if duckPlayer.settings.openInNewTab && !url.isYoutubeWatch {
                loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
                return true
            }
            
            if duckPlayer.settings.openInNewTab && url.isYoutubeWatch {
                openInNewTab(isJavascriptLink: false, webView: webView)
                return true
            }
        }

        // Allow all other navigations
        return false
    }
    
    // This handles all navigation within youtube.com
    @MainActor
    func handleYoutubeNavigation(navigationAction: WKNavigationAction, webView: WKWebView) {
        loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
    }
    
}

extension WKWebView {
    var isEmptyTab: Bool {
        return self.url == nil || self.url?.absoluteString == "about:blank"
    }
    
    @objc func backListItemsCount() -> Int {
        return backForwardList.backList.count
    }
    
}
