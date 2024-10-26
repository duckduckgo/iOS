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

final class DuckPlayerNavigationHandler: NSObject {

    var duckPlayer: DuckPlayerProtocol
    var referrer: DuckPlayerReferrer = .other
    var renderedVideoID: String?
    var renderedURL: URL?
    var featureFlagger: FeatureFlagger
    var appSettings: AppSettings
    var pixelFiring: PixelFiring.Type
       
    // Redirection Throttle
    private var lastDuckPlayerRedirect: Date?
    private let lastDuckPlayerRedirectThrottleDuration: TimeInterval = 1
            
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
        static let duckPlayerReferrerParameter = "duckPlayerReferrer"
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
        
        //Logger.duckPlayer.debug("DP: redirectToDuckPlayerVideo: \(duckPlayerURL.absoluteString)")
        self.loadWithDuckPlayerParameters(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView)
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
            loadWithDuckPlayerParameters(URLRequest(url: finalURL), referrer: referrer, webView: webView)
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
    
    // There's no way to cancel JS navigation in advance, so we
    // just need to go back to the previous page
    @MainActor
    private func cancelJavascriptNavigation(webView: WKWebView, completion: (() -> Void)? = nil) {
                    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            webView.stopLoading()
            webView.goBack()
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
        queryItems.append(URLQueryItem(name: Constants.duckPlayerReferrerParameter, value: referrer.stringValue))
        
        // Adds a newTab parameter to prevent navigation loops in the new tab
        queryItems.append(URLQueryItem(name: Constants.newTabParameter, value: "1"))
        components.queryItems = queryItems
        
        if let url = components.url {
            tabNavigationHandler?.openTab(for: url)
            Logger.duckPlayer.debug("DP: openInNewTab: Done for \(url.absoluteString)")

            // After the new tab is open, reset the rendered URL and video ID
            // In the source tab so you can open the same video Again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.renderedURL = nil
                self.renderedVideoID = nil
            }
        }
        
    }
        
    // TabViewController cancels all Youtube navigation by default, so this replaces webView.load
    // to add specific DuckPlayer headers.  These headers are used to identify DuckPlayerHandler
    // Navigation in Tabview controller and let it through.
    private func loadWithDuckPlayerParameters(_ request: URLRequest, referrer: DuckPlayerReferrer, webView: WKWebView) {
        
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and quick url changes
        if let lastTimestamp = lastDuckPlayerRedirect {
            let timeSinceLastThrottle = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastThrottle < lastDuckPlayerRedirectThrottleDuration {
                return
            }
        }
        
        lastDuckPlayerRedirect = Date()
        
        guard let url = request.url else {
            return
        }
        
        // Remove any DP Parameters
        guard let strippedURL = removeDuckPlayerParameters(from: url) else {
            return
        }
        
        var newURL = strippedURL
        var urlComponents = URLComponents(url: strippedURL, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? []
        
        queryItems.append(URLQueryItem(name: Constants.refererHeader, value: "1"))
        queryItems.append(URLQueryItem(name: Constants.duckPlayerReferrerParameter, value: referrer.stringValue))
        urlComponents?.queryItems = queryItems
        
        // Create a new request with the modified URL
        newURL = urlComponents?.url ?? newURL
        var newRequest = request
        newRequest.url = newURL
        
        Logger.duckPlayer.debug("DP: loadWithDuckPlayerParameters: \(newURL.absoluteString)")
        
        // Perform the load
        webView.load(newRequest)
    }
    
    private func getDuckPlayerReferrer(from url: URL) -> String? {
        
        // Use URLComponents to parse the query items
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return nil
        }
        
        // Find the query item with the DuckPlayer referrer parameter
        let referrerParameter = queryItems.first(where: { $0.name == Constants.duckPlayerReferrerParameter })
        
        // Return the value if the parameter is found
        return referrerParameter?.value
        
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
                                  Constants.duckPlayerReferrerParameter]
        
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
            //openInNewTab(url: url)
            return
        }
                
        duckPlayer.settings.allowFirstVideo = false

        guard let url = navigationAction.request.url else { return }

        // Redirect to YouTube if DuckPlayer is disabled
        guard duckPlayerMode != .disabled else {
            if let (videoID, _) = url.youtubeVideoParams {
                loadWithDuckPlayerParameters(URLRequest(url: URL.youtube(videoID)), referrer: referrer, webView: webView)
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
                Logger.duckPlayer.debug("DP: handleNavigation: Loading Simulated Request for \(url.absoluteString)")
                
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
        
        // Check if DuckPlayer feature is enabled
        guard isDuckPlayerFeatureEnabled else {
            //Logger.duckPlayer.debug("DP: handleURLChange: Feature flag is off, skipping")
            return .notHandled(.featureOff)
        }
        
        // Handle non-YouTube URLs first
        guard webView.url?.isYoutubeWatch ?? false else {
            //Logger.duckPlayer.debug("DP: handleURLChange: Not a YouTube video page, skipping")
            return .notHandled(.isNotYoutubeWatch)
        }

        // Avoid duplicate handling of the same video URL
        guard let url = webView.url, removeDuckPlayerParameters(from: url) != renderedURL else {
            //Logger.duckPlayer.debug("DP: handleURLChange: URL has not changed, skipping")
            return .notHandled(.urlHasNotChanged)
        }
        
        // Disable the Youtube Overlay for Player links
        // Youtube player links should open the video in Youtube
        // without overlay
        if let url = webView.url, url.hasWatchInYoutubeQueryParameter {
            duckPlayer.settings.allowFirstVideo = true
            return .notHandled(.disabledForNextVideo)
        }

        // Handle YouTube watch URLs based on DuckPlayer settings
        if url.isYoutubeWatch, duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk {
            cancelJavascriptNavigation(webView: webView, completion: {
                self.redirectToDuckPlayerVideo(url: url, webView: webView)
            })
            return .handled
        }

        return .notHandled(.duckPlayerDisabled)
    }
    
    // Controls BackNavigation logic for Youtube.  DuckPlayer is rendered as a new item in the
    // History stack, so we need special logic on back/forward nav.
    @MainActor
    func handleGoBack(webView: WKWebView) {
                
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

        for item in backList.reversed() where !item.url.isYoutubeVideo && !item.url.isDuckPlayer {
            nonYoutubeItem = item
            break
        }

        if let nonYoutubeItem = nonYoutubeItem, duckPlayerMode == .enabled {
            //Logger.duckPlayer.debug("DP: handleGoBack: Navigating back to \(nonYoutubeItem.url.absoluteString)")
            // Delay stopping the loading to avoid interference with go(to:)
            webView.stopLoading()
            webView.go(to: nonYoutubeItem)
        } else {
            //Logger.duckPlayer.debug("DP: handleGoBack: Navigating back to previous page")
            webView.stopLoading()
            webView.goBack()
        }
    }

    
    // Handles reload operations for Youtube videos
    @MainActor
    func handleReload(webView: WKWebView) {
               
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
            //Logger.duckPlayer.debug("DP: handleReload: Handling DuckPlayer Reload for \(url.absoluteString)")
            redirectToDuckPlayerVideo(url: url, webView: webView)
        } else {
            webView.reload()
        }
    }
    
    // Tasks performed as part of the initialization of TabViewController, when the handler
    // Is attached to it
    @MainActor
    func handleAttach(webView: WKWebView) {
        
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
            let referrerParam = urlComponents?.queryItems?.first(where: { $0.name == Constants.duckPlayerReferrerParameter })?.value
            
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
           let navigationSource = headers[Constants.duckPlayerReferrerParameter] {
            
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
        
        // Fire the logic immediately
        guard let url = navigationAction.request.url else {
            //Logger.duckPlayer.debug("DP: shouldCancelNavigation: false: invalid URL")
            return false
        }
        
        // Check if it's a valid Watch Page, and DuckPlayer is enabled
        guard url.isYoutubeWatch, isDuckPlayerFeatureEnabled, duckPlayerMode != .disabled else {
            //Logger.duckPlayer.debug("DP: shouldCancelNavigation: false: is not a valid Watch Page or DuckPlayer is disabled")
            return false
        }
        
        // Only account for MainFrame navigation
        guard navigationAction.isTargetingMainFrame() else {
            //Logger.duckPlayer.debug("DP: shouldCancelNavigation: false: Not targeting MainFrame")
            return false
        }
        
        // Do not intercept any back/forward navigation
        if navigationAction.navigationType == .backForward {
            //Logger.duckPlayer.debug("DP: shouldCancelNavigation: false: backForward")
            return false
        }
        
        // Ignore DuckPlayer videos
        guard !url.isDuckURLScheme else {
            //Logger.duckPlayer.debug("DP: shouldCancelNavigation: false: Skipped: already a DuckPlayer video")
            return false
        }
        
        //Logger.duckPlayer.debug("DP: shouldCancelNavigation: true: Valid URL")
        
        // Return true to indicate the navigation should be canceled
        redirectToDuckPlayerVideo(url: url, webView: webView)
        return true
    }

    
    
}

extension WKWebView {
    @objc func backListItemsCount() -> Int {
        return backForwardList.backList.count
    }
    
}
