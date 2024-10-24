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
    weak var tabNavigationHandler: DuckPlayerTabNavigationHandling?
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
         pixelFiring: PixelFiring.Type = Pixel.self,
         tabNavigationHandler: DuckPlayerTabNavigationHandling? = nil) {
        self.duckPlayer = duckPlayer
        self.featureFlagger = featureFlagger
        self.appSettings = appSettings
        self.pixelFiring = pixelFiring
        self.tabNavigationHandler = tabNavigationHandler
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
        
        let duckPlayerURL = URL.duckPlayer(videoID)
        
        // Cancel navigation if OpenInNewTab is enabled
        if let url = webView.url,
            duckPlayer.settings.openInNewTab,
            featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab) {
            cancelNavigation(url: url, webView: webView, completion: {
                Logger.duckPlayer.debug("DP: Redirecting to DuckPlayer Video: \(duckPlayerURL.absoluteString)")
                self.loadWithDuckPlayerHeaders(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView)
            })
        }
        
        // If the URL is a Youtube Watch video, cancel navigation
        if url.isYoutubeWatch {
            cancelNavigation(url: url, webView: webView, completion: {
                Logger.duckPlayer.debug("DP: Redirecting to DuckPlayer Video: \(duckPlayerURL.absoluteString)")
                self.loadWithDuckPlayerHeaders(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView)
            })
        }
        
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
    
    private func cancelNavigation(url: URL, webView: WKWebView, completion: (() -> Void)? = nil) {
        
        // Javascript links don't go through decidePolicy For, so we need to stop nav
        // And go back to the previous URL. Which effectively cancels the navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            webView.stopLoading()
            self.handleBackForwardNavigation(webView: webView, direction: .back)
            completion?()
        }
    }
    
    // Loads the provided URL in a new Tab.  It delegates this to the tabNavigationHandler
    // in TabViewController.
    // We add some URL parameters to identify the URL's when they load
    private func openInNewTab(url: URL) {
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        var queryItems = components.queryItems ?? []
        // Adds a Referrer header which is then parsed to fire pixels based on the referrer
        queryItems.append(URLQueryItem(name: Constants.duckPlayerReferrerHeaderKey, value: referrer.stringValue))
        
        // Adds a newTab parameter to prevent navigation loops in the new tab
        //queryItems.append(URLQueryItem(name: Constants.newTabParameter, value: "1"))
        components.queryItems = queryItems
        
        if let url = components.url {
            tabNavigationHandler?.openTab(for: url)
            renderedVideoID = nil
        }
        
    }
    
    // TabViewController cancels all Youtube navigation by default, so this replaces webView.load
    // to add specific DuckPlayer headers.  These headers are used to identify DuckPlayerHandler
    // Navigation in Tabview controller and let it through.
    func loadWithDuckPlayerHeaders(_ request: URLRequest, referrer: DuckPlayerReferrer, webView: WKWebView) {
            
        var newRequest = request
                
        newRequest.addValue("DuckPlayer", forHTTPHeaderField: DuckPlayerNavigationHandler.Constants.duckPlayerHeaderKey)
        newRequest.addValue(referrer.stringValue, forHTTPHeaderField: DuckPlayerNavigationHandler.Constants.duckPlayerReferrerHeaderKey)
        
        Logger.duckPlayer.debug("Loading Youtube URL with DuckPlayer headers: \(request.url?.absoluteString ?? "")")
            
        if let url = newRequest.url {
            renderedURL = url
            if let (videoID, _) = url.youtubeVideoParams {
                renderedVideoID = videoID
            } else {
                renderedVideoID = nil
            }
        }
        
        // Perform the load
        webView.load(newRequest)
    }
    
    
}

extension DuckPlayerNavigationHandler: DuckPlayerNavigationHandling {
    
    // Handle rendering the simulated request for duck:// links
    @MainActor
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView) {
        
        let tabHasEmptyURL = navigationAction.targetFrame?.safeRequest?.url?.absoluteString == ""
        let isDuckPlayerInNewTab = navigationAction.targetFrame?.safeRequest?.url?.isDuckPlayer ?? false && duckPlayer.settings.openInNewTab
        let isNewTab = tabHasEmptyURL || isDuckPlayerInNewTab
        
        // Check if should open in a new tab
        if featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab),
           duckPlayer.settings.openInNewTab,
           let url = navigationAction.request.url,
           let (videoID, _) = url.youtubeVideoParams,
           videoID != renderedVideoID,
           getYoutubeURLFromOpenInYoutubeLink(url: url) == nil,
           !isNewTab {
            renderedVideoID = videoID
            openInNewTab(url: url)
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
                openInNewTab(url: newURL)
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
    
    // TabViewController's observe delegates URL changes to this method, which basically reacts
    // to different URLs and present/redirect DuckPlayer when necesary.
    // This also takes care of managing duplicate URL changes
    @MainActor
    func handleURLChange(webView: WKWebView) -> DuckPlayerNavigationHandlerURLChangeResult {
                
        
        Logger.duckPlayer.debug("DP: Initializing Navigation handler for URL: \(webView.url?.absoluteString ?? "No URL")")
        
        // Check if the URL is a DuckPlayer URL (handled elsewhere)
        guard webView.url?.isYoutube ?? false || webView.url?.isDuckPlayer ?? false else {
            Logger.duckPlayer.debug("DP: Not a Youtube Watch URL")
            return .notHandled(.notAYoutubePage)
        }
        
        // Check if DuckPlayer feature is ON
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            Logger.duckPlayer.debug("DP: Feature flag is off, skipping")
            return .notHandled(.featureOff)
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
        
        // Check for valid YouTube video parameters
        guard let url = webView.url,
              let (videoID, _) = url.youtubeVideoParams else {
            Logger.duckPlayer.debug("DP: No video parameters present in the URL, skipping")
            renderedVideoID = nil
            return .notHandled(.videoIDNotPresent)
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

    
    // Controls Back/Forward navigation logic for Youtube.  DuckPlayer is rendered as a new item in the
    // History stack, so we need special logic on back/forward nav.
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

    
    // Handles reload operations for Youtube videos
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
    
    // Tasks performed as part of the initialization of TabViewcontroller, when the handler
    // Is attached to it
    @MainActor
    func handleAttach(webView: WKWebView) {
        
        Logger.duckPlayer.debug("DP: Attach WebView")
        
        // Reset DuckPlayer status
        duckPlayer.settings.allowFirstVideo = false
        renderedVideoID = nil
        renderedURL = nil
                
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
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
    
    // Sets the DuckPlayerReferer based on URL and headers.  This is called from the NavigationDelegate
    // as part of decidePolicy for.  The Referrer is used mostly to firing the correct pixels
    func setReferrer(navigationAction: WKNavigationAction, webView: WKWebView) {
                    
        // If there is a SERP referer Header, use it
        if let referrer = navigationAction.request.allHTTPHeaderFields?[Constants.refererHeader], referrer.contains(Constants.SERPURL) {
            self.referrer = .serp
            return
        }
        
        // If this is a new tab (no history), but theres a URL Referrer parameter, use it
        if webView.backListItemsCount() == 0, let url = navigationAction.request.url {
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let referrerParam = urlComponents?.queryItems?.first(where: { $0.name == Constants.duckPlayerHeaderKey })?.value
            
            switch referrerParam {
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
        // And we should open in the same tab, don't cancel.
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
                        
            // If open in new tab is OFF or the feature is disabled
            if !duckPlayer.settings.openInNewTab || !featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab) {
                webView.stopLoading()
                loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
                return true
            }
            
            if duckPlayer.settings.openInNewTab && !url.isYoutubeWatch {
                webView.stopLoading()
                loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
                return true
            }
            
            if duckPlayer.settings.openInNewTab && url.isYoutubeWatch {
                webView.stopLoading()
                loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
                return true
            }
        }

        // Allow all other navigations
        return false
    }
    
    
}

extension WKWebView {
    @objc func backListItemsCount() -> Int {
        return backForwardList.backList.count
    }
    
}
