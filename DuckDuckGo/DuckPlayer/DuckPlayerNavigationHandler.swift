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
        
    enum HandlerNavigationType {
        case back, duckPlayer, none
    }

    var duckPlayer: DuckPlayerProtocol
    var referrer: DuckPlayerReferrer = .other
    var renderedVideoID: String?
    var renderedURL: URL?
    var featureFlagger: FeatureFlagger
    var appSettings: AppSettings
    var pixelFiring: PixelFiring.Type
    var isOpeningNewTab: Bool = false
    weak var tabNavigationHandler: DuckPlayerTabNavigationHandling?
    
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
        static let newTabParameter = "isNewTab"
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
    
    private var isDuckPlayerFeatureEnabled: Bool {
        featureFlagger.isFeatureOn(.duckPlayer)
    }
    
    private var isOpenInNewTabEnabled: Bool {
        featureFlagger.isFeatureOn(.duckPlayer) && featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab) && duckPlayer.settings.openInNewTab
    }
    
    private var duckPlayerMode: DuckPlayerMode {
        let isEnabled = isDuckPlayerFeatureEnabled
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
    
    // Loads a URL in Duck Player
    @MainActor
    private func redirectToDuckPlayerVideo(url: URL?, webView: WKWebView) {
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
        
        let duckPlayerURL = URL.duckPlayer(videoID)
        
        // Determine if navigation needs to be canceled
        // (If the page is a Youtube Watch Page or we're opening a new tab
        if isOpenInNewTabEnabled {
            cancelNavigation(url: url, webView: webView) {
                Logger.duckPlayer.debug("DP: Cancelling Navigation on existing tab and redirecting to DuckPlayer Video in New: \(duckPlayerURL.absoluteString)")
                self.loadWithDuckPlayerHeaders(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView)
            }
        }
        else {
            Logger.duckPlayer.debug("DP: Loading DuckPlayer Video: \(duckPlayerURL.absoluteString)")
            self.loadWithDuckPlayerHeaders(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView)
        }
    }
    
    // Loads a Youtube Video Page
    @MainActor
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
        renderedURL = removeDuckPlayerParameters(from: url)
        if let finalURL = redirectURL.addingWatchInYoutubeQueryParameter() {
            loadWithDuckPlayerHeaders(URLRequest(url: finalURL), referrer: referrer, webView: webView)
        }
    }
    
    
    // Fire pixels displayed when DuckPlayer is shown
    private func fireDuckPlayerPixels() {
        
        // First daily unique user Duck Player view
        pixelFiring.fire(.duckPlayerDailyUniqueView, withAdditionalParameters: ["settings": duckPlayerMode.stringValue])
        
        // Duck Player viewed with Always setting, referred from YouTube
        if (referrer == .youtube) && duckPlayerMode == .enabled {
            pixelFiring.fire(.duckPlayerViewFromYoutubeAutomatic, withAdditionalParameters: [:])
        }
        
        // Duck Player viewed from SERP overlay
        if referrer == .serp && duckPlayerMode == .enabled {
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
    
    @MainActor
    private func cancelNavigation(url: URL, webView: WKWebView, completion: (() -> Void)? = nil) {                
        webView.stopLoading()
        completion?()
    }
    
    // Loads the provided URL in a new Tab.  It delegates this to the tabNavigationHandler
    // in TabViewController.
    // We add some URL parameters to identify the URL's when they load
    private func openInNewTab(url: URL) {
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        // Only open a new tab for the fist event
        // Youtube Javascript Navigation may fire multiple
        // navigation events simultaneously
        // While this is OK for regular navigation,
        // We don't want multiple if that's tabs in that case
        if !isOpeningNewTab {
            
            var queryItems = components.queryItems ?? []
            // Adds a Referrer header which is then parsed to fire pixels based on the referrer
            queryItems.append(URLQueryItem(name: Constants.duckPlayerReferrerHeaderKey, value: referrer.stringValue))
            
            // Adds a newTab parameter to prevent navigation loops in the new tab
            queryItems.append(URLQueryItem(name: Constants.newTabParameter, value: "1"))
            components.queryItems = queryItems
            
            if let url = components.url {
                tabNavigationHandler?.openTab(for: url)

                // After the new tab is open, reset the rendered URL and video ID
                // In the source tab so you can open the same video Again
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.renderedURL = nil
                    self.renderedVideoID = nil
                    self.isOpeningNewTab = false
                }
            }
        }
        
    }
    
    
    // TabViewController cancels all Youtube navigation by default, so this replaces webView.load
    // to add specific DuckPlayer headers.  These headers are used to identify DuckPlayerHandler
    // Navigation in Tabview controller and let it through.
    private func loadWithDuckPlayerHeaders(_ request: URLRequest, referrer: DuckPlayerReferrer, webView: WKWebView) {
            
        guard let url = request.url, renderedURL != removeDuckPlayerParameters(from: url) else {
            return
        }
        
        var newRequest = request
                
        newRequest.addValue("DuckPlayer", forHTTPHeaderField: DuckPlayerNavigationHandler.Constants.duckPlayerHeaderKey)
        newRequest.addValue(referrer.stringValue, forHTTPHeaderField: DuckPlayerNavigationHandler.Constants.duckPlayerReferrerHeaderKey)
        
        Logger.duckPlayer.debug("DP: Loading Youtube URL with DuckPlayer headers: \(request.url?.absoluteString ?? "")")
        
        // Perform the load
        webView.load(newRequest)
    }
    
    private func isNewTab(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return false
        }

        for queryItem in queryItems where queryItem.name == Constants.newTabParameter {
            return true
        }

        return false
    }
    
    // Remove all DuckPlayer Parameters
    private func removeDuckPlayerParameters(from url: URL) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return url
        }
        
        let parametersToRemove = [Constants.newTabParameter,
                                  Constants.duckPlayerHeaderKey,
                                  Constants.duckPlayerReferrerHeaderKey]
        
        // Filter out the parameters you want to remove
        components.queryItems = queryItems.filter { !parametersToRemove.contains($0.name) }
        
        // Return the modified URL
        return components.url
    }
        
    
}

extension DuckPlayerNavigationHandler: DuckPlayerNavigationHandling {
    
    
    // Handle rendering the simulated request for duck:// links
    @MainActor
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView) {
        
        // Check if should open in a new tab
        if isOpenInNewTabEnabled,
           let url = navigationAction.request.url,
           let (videoID, _) = url.youtubeVideoParams,
           videoID != renderedVideoID,
           renderedURL != removeDuckPlayerParameters(from: url),
           getYoutubeURLFromOpenInYoutubeLink(url: url) == nil,
           !isNewTab(url: url) {
            openInNewTab(url: url)
            return
        }
            
        Logger.duckPlayer.debug("Handling Navigation for \(navigationAction.request.url?.absoluteString ?? "")")
                
        duckPlayer.settings.allowFirstVideo = false // Disable overlay for first video

        guard let url = navigationAction.request.url else { return }

        // Redirect to YouTube if DuckPlayer is disabled
        guard duckPlayerMode != .disabled else {
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
            if duckPlayerMode != .disabled,
               !url.hasWatchInYoutubeQueryParameter {
                let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
                Logger.duckPlayer.debug("DP: Loading Simulated Request for \(url.absoluteString)")
                
                // The webview needs some time for state to propagate
                // Before performing the simulated request
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
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
        
        // Check if DuckPlayer feature is ON
        guard isDuckPlayerFeatureEnabled else {
            Logger.duckPlayer.debug("DP: Feature flag is off, skipping")
            return .notHandled(.featureOff)
        }
        
        // Check if the URL is a DuckPlayer URL (handled elsewhere)
        guard !(webView.url?.isDuckURLScheme ?? false) else {
            return .notHandled(.isAlreadyDuckAddress)
        }
        
        // If the URL hasn't changed, exit
        guard let url = webView.url, removeDuckPlayerParameters(from: url) != renderedURL else {
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
        guard duckPlayerMode == .enabled else {
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

    
    // Controls Backnavigation logic for Youtube.  DuckPlayer is rendered as a new item in the
    // History stack, so we need special logic on back/forward nav.
    @MainActor
    func handleGoBack(webView: WKWebView) {

        Logger.duckPlayer.debug("DP: Handling Back Navigation")

        guard isDuckPlayerFeatureEnabled else {
            webView.goBack()
            return
        }

        renderedVideoID = nil
        renderedURL = nil
        
        // Check if the back list has items
        guard !webView.backForwardList.backList.isEmpty else {
            webView.goBack()
            return
        }

        // Find the last non-YouTube video URL in the back list
        let backList = webView.backForwardList.backList
        var nonYoutubeItem: WKBackForwardListItem?

        Logger.duckPlayer.debug("DP: Current back list: \(backList.map { $0.url.absoluteString })")

        for item in backList.reversed() where !item.url.isYoutubeVideo && !item.url.isDuckPlayer {
            nonYoutubeItem = item
            break
        }

        if let nonYoutubeItem = nonYoutubeItem, duckPlayerMode == .enabled {
            Logger.duckPlayer.debug("DP: Navigating back to \(nonYoutubeItem.url.absoluteString)")
            // Delay stopping the loading to avoid interference with go(to:)
            webView.stopLoading()
            webView.go(to: nonYoutubeItem)
        } else {
            Logger.duckPlayer.debug("DP: Navigating back to previous page")
            webView.stopLoading()
            webView.goBack()
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
        
        guard isDuckPlayerFeatureEnabled else {
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
                
        guard isDuckPlayerFeatureEnabled else {
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
            && duckPlayerMode == .enabled {
            referrer = .other
            return
        }
        
        // Set the referrer to be Youtube Overlay
        // when disable and visiting a video page
        if webView.url?.isYoutubeWatch ?? false
            && duckPlayerMode == .alwaysAsk {
            referrer = .youtubeOverlay
            return
        }
                        
        // Otherwise, just set the header based on the URL
        if let url = navigationAction.request.url {
            
            // We only need a referrer when DP is enabled
            if url.isDuckPlayer && duckPlayerMode == .enabled {
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
        
        // Do not intercept any backForward Navigation
        if navigationAction.navigationType == .backForward {
            return false
        }
        
        // If the custom "X-Navigation-Source" header is present
        // And we should open in the same tab, don't cancel.
        if let headers = navigationAction.request.allHTTPHeaderFields,
           let navigationSource = headers[Constants.duckPlayerHeaderKey],
           navigationSource == Constants.duckPlayerHeaderValue {
            return false
        }

        // Otherwise, validate if the page is a Youtube page, and DuckPlayer is Enabled and Load it if so
        if isDuckPlayerFeatureEnabled,
            duckPlayerMode != .disabled,
            !duckPlayer.settings.allowFirstVideo,
            let url = navigationAction.request.url,
            url.isYoutube || url.isYoutubeWatch {
                        
            loadWithDuckPlayerHeaders(navigationAction.request, referrer: referrer, webView: webView)
            return true
            
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
