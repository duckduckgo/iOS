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
    var featureFlagger: FeatureFlagger
    var appSettings: AppSettings
    var pixelFiring: PixelFiring.Type
    var lastWatchInYoutubeVideo: String?
       
    // Redirection Throttle
    private var lastDuckPlayerRedirect: Date? {
        didSet {
            print("DP: lastDuckPlayerRedirect: \(lastDuckPlayerRedirect.debugDescription)")
        }
    }
    private let lastDuckPlayerRedirectThrottleDuration: TimeInterval = 1
    
    // Navigation URL Changing Throttle
    private var lastURLChangeHandling: Date?
    private let lastURLChangeHandlingThrottleDuration: TimeInterval = 1
    
    // Navigation Cancelling Throttle
    private var lastNavigationHandling: Date?
    private let lastNavigationHandlingThrottleDuration: TimeInterval = 1
            
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
        static let youtubeEmbedURI = "embeds_referring_euri"
        static let youtubeScheme = "youtube://"
        static let duckPlayerScheme = URL.NavigationalScheme.duck.rawValue
        static let duckPlayerReferrerParameter = "dp_referrer"
        static let newTabParameter = "dp_isNewTab"
        static let allowFirstVideoParameter = "dp_allowFirstVideo"
    }
    
    private struct DuckPlayerParameters {
        let referrer: DuckPlayerReferrer
        let isNewTap: Bool
        let allowFirstVideo: Bool
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
    
    @MainActor
    private func performNavigation(_ request: URLRequest, responseHTML: String, webView: WKWebView) {
        
        // If DuckPlayer is enabled, and we're watching a video in Youtube (temporarily)
        // Any direct navigation to a duck:// URL should open in a new tab
        if let url = webView.url, url.isYoutubeWatch && isOpenInNewTabEnabled && duckPlayerMode == .enabled {
            self.redirectToDuckPlayerVideo(url: request.url, webView: webView)
            return
        }
        // Otherwise, just load the simulated request
        webView.loadSimulatedRequest(request, responseHTML: responseHTML)
    }
    
    @MainActor
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
              let id = videoParameterItem.value else {
            return nil
        }
        return URL.youtube(id, timestamp: nil)
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
    private func redirectToDuckPlayerVideo(url: URL?, webView: WKWebView, forceNewTab: Bool = false) {
        
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
        
        let duckPlayerURL = URL.duckPlayer(videoID)
        self.loadWithDuckPlayerParameters(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView, forceNewTab: forceNewTab)
    }
    
    // Loads a Youtube Video Page
    @MainActor
    private func redirectToYouTubeVideo(url: URL?, webView: WKWebView, forceNewTab: Bool = false) {
        
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
        
        var redirectURL = url
        
        // Parse OpenInYouTubeURLs if present
        if let parsedURL = getYoutubeURLFromOpenInYoutubeLink(url: url) {
            redirectURL = parsedURL
        }
        
        // When redirecting to Youtube, we always allow the first video
        loadWithDuckPlayerParameters(URLRequest(url: redirectURL), referrer: referrer, webView: webView, forceNewTab: forceNewTab, allowFirstVideo: true)
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
        
        if duckPlayerMode == .enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                webView.stopLoading()
                if webView.canGoBack {
                    webView.goBack()
                }
                completion?()
            }
        } else {
            completion?()
        }
        
    }
        
    // TabViewController cancels all Youtube navigation by default, so this replaces webView.load
    // to add specific DuckPlayer headers.  These headers are used to identify DuckPlayerHandler
    // Navigation in Tabview controller and let it through.
    private func loadWithDuckPlayerParameters(_ request: URLRequest,
                                              referrer: DuckPlayerReferrer,
                                              webView: WKWebView,
                                              forceNewTab: Bool = false,
                                              allowFirstVideo: Bool = false) {
        
        guard let url = request.url else {
            return
        }
        
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and youtube's own redirects
        if let lastTimestamp = lastDuckPlayerRedirect {
            let timeSinceLastThrottle = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastThrottle < lastDuckPlayerRedirectThrottleDuration {
                return
            }
        }
        lastDuckPlayerRedirect = Date()
        
        // Remove any DP Parameters
        guard let strippedURL = removeDuckPlayerParameters(from: url) else {
            return
        }
        
        // Set allowFirstVideo
        duckPlayer.settings.allowFirstVideo = allowFirstVideo
        
        // Get parameter values
        let isNewTab = (isOpenInNewTabEnabled && duckPlayerMode == .enabled) || forceNewTab ? "1" : "0"
        let allowFirstVideo = allowFirstVideo ? "1" : "0"
        let referrer = referrer.stringValue
                
        var newURL = strippedURL
        var urlComponents = URLComponents(url: strippedURL, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? []
            
        // Append DuckPlayer parameters
        queryItems.append(URLQueryItem(name: Constants.newTabParameter, value: isNewTab))
        queryItems.append(URLQueryItem(name: Constants.duckPlayerReferrerParameter, value: referrer))
        queryItems.append(URLQueryItem(name: Constants.allowFirstVideoParameter, value: allowFirstVideo))
        urlComponents?.queryItems = queryItems
        
        // Create a new request with the modified URL
        newURL = urlComponents?.url ?? newURL
                
        // Only Open in new tab if enabled
        if isOpenInNewTabEnabled || forceNewTab {
            tabNavigationHandler?.openTab(for: newURL)
        } else {
            webView.load(URLRequest(url: newURL))
        }
        
        Logger.duckPlayer.debug("DP: loadWithDuckPlayerParameters: \(newURL.absoluteString)")
        
    }
    
    private func getDuckPlayerParameters(url: URL) -> DuckPlayerParameters {
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return DuckPlayerParameters(referrer: .other, isNewTap: false, allowFirstVideo: false)
        }
        
        let referrerValue = queryItems.first(where: { $0.name == Constants.duckPlayerReferrerParameter })?.value
        let allowFirstVideoValue = queryItems.first(where: { $0.name == Constants.allowFirstVideoParameter })?.value
        let isNewTabValue = queryItems.first(where: { $0.name == Constants.newTabParameter })?.value
        let youtubeEmbedURI = queryItems.first(where: { $0.name == Constants.youtubeEmbedURI })?.value
        
        // Use the from(string:) method to parse referrer
        let referrer = DuckPlayerReferrer.from(string: referrerValue ?? "")
        let allowFirstVideo = allowFirstVideoValue == "1" || youtubeEmbedURI.map(\.isEmpty) ?? false
        let isNewTab = isNewTabValue == "1"
        
        return DuckPlayerParameters(referrer: referrer, isNewTap: isNewTab, allowFirstVideo: allowFirstVideo)
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
        
        Logger.duckPlayer.debug("Handling Navigation for \(webView.url?.absoluteString ?? "")")
        
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and quick url changes
        if let lastTimestamp = lastNavigationHandling {
            let timeSinceLastThrottle = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastThrottle < lastNavigationHandlingThrottleDuration {
                return
            }
        }
        
        lastNavigationHandling = Date()
        
        let shouldOpenInNewTab = isOpenInNewTabEnabled && !(tabNavigationHandler?.isNewTab ?? false)

        guard let url = navigationAction.request.url else { return }

        // Redirect to YouTube if DuckPlayer is disabled
        guard duckPlayerMode != .disabled else {
            if let (videoID, _) = url.youtubeVideoParams {
                redirectToYouTubeVideo(url: URL.youtube(videoID), webView: webView)
            }
            return
        }
        
        // Handle "open in YouTube" links (duck://player/openInYoutube)
        if let newURL = getYoutubeURLFromOpenInYoutubeLink(url: url),
           let (videoID, _) = newURL.youtubeVideoParams {
            
            // Fire a Pixel for Open in Youtube
            self.fireOpenInYoutubePixel()
            
            // Attempt to open in YouTube app or load in webView
            if appSettings.allowUniversalLinks, isYouTubeAppInstalled,
               let youtubeAppURL = URL(string: "\(Constants.youtubeScheme)\(videoID)") {
                UIApplication.shared.open(youtubeAppURL)
            } else {
                // Watch in YT videos always open in new tab
                redirectToYouTubeVideo(url: newURL, webView: webView, forceNewTab: true)
            }
            return
        }

        // Handle duck:// scheme URLs
        if url.isDuckURLScheme {

            // Simulate DuckPlayer request if in enabled/ask mode and not redirected to YouTube
            if duckPlayerMode != .disabled,
               !url.hasWatchInYoutubeQueryParameter {
                let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
                
                // The webView needs some time for state to propagate
                // Before performing the simulated request
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.performRequest(request: newRequest, webView: webView)
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
                redirectToDuckPlayerVideo(url: url, webView: webView, forceNewTab: shouldOpenInNewTab)
            }
        }
    }
    
    // TabViewController's observe delegates URL changes to this method, which basically reacts
    // to different URLs and present/redirect DuckPlayer when necessary.
    // This also takes care of managing duplicate URL changes
    @MainActor
    func handleURLChange(webView: WKWebView) -> DuckPlayerNavigationHandlerURLChangeResult {
        
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and quick url changes
        if let lastTimestamp = lastURLChangeHandling {
            let timeSinceLastThrottle = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastThrottle < lastURLChangeHandlingThrottleDuration {
                return .notHandled(.duplicateNavigation)
            }
        }
        
        // We don't want Youtube redirects happening while default navigation is happening
        // This can be caused by Duplicate Nav events, and quick url changes
        if let lastTimestamp = lastNavigationHandling {
            let timeSinceLastThrottle = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastThrottle < lastNavigationHandlingThrottleDuration {
                return .notHandled(.duplicateNavigation)
            }
        }
        
        // Check if DuckPlayer feature is enabled
        guard isDuckPlayerFeatureEnabled else {
            return .notHandled(.featureOff)
        }
        
        guard let url = webView.url, let (videoID, _) = url.youtubeVideoParams else {
            return .notHandled(.invalidURL)
        }
        
        guard url.isYoutubeWatch else {
            return .notHandled(.isNotYoutubeWatch)
        }
        
        guard videoID != lastWatchInYoutubeVideo else {
            lastURLChangeHandling = Date()
            return .handled
        }
        
        let parameters = getDuckPlayerParameters(url: url)
        
        // If the URL has the allow first video, we just don't handle it
        if parameters.allowFirstVideo {
            lastWatchInYoutubeVideo = videoID
            lastURLChangeHandling = Date()
            return .handled
        }

        // Handle YouTube watch URLs based on DuckPlayer settings
        if duckPlayerMode == .enabled && !parameters.allowFirstVideo {
            cancelJavascriptNavigation(webView: webView, completion: {
                self.redirectToDuckPlayerVideo(url: url, webView: webView)
            })
            lastURLChangeHandling = Date()
            Logger.duckPlayer.debug("Handling URL change for \(webView.url?.absoluteString ?? "")")
            return .handled
        }
        
        return .notHandled(.isNotYoutubeWatch)
    }
    
    // Controls BackNavigation logic for Youtube.  DuckPlayer is rendered as a new item in the
    // History stack, so we need special logic on back/forward nav.
    @MainActor
    func handleGoBack(webView: WKWebView) {
                
        guard isDuckPlayerFeatureEnabled else {
            webView.goBack()
            return
        }
        
        // Check if the back list has items, and it not try to close the tab
        guard !webView.backForwardList.backList.isEmpty else {
            tabNavigationHandler?.closeTab()
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
            // Delay stopping the loading to avoid interference with go(to:)
            webView.stopLoading()
            webView.go(to: nonYoutubeItem)
        } else {
            webView.stopLoading()
            webView.goBack()
        }
    }

    
    // Handles reload operations for Youtube videos
    @MainActor
    func handleReload(webView: WKWebView) {
               
        // Reset DuckPlayer status
        duckPlayer.settings.allowFirstVideo = false
        
        guard isDuckPlayerFeatureEnabled else {
            webView.reload()
            return
        }
                
        if let url = webView.url, url.isDuckPlayer,
            !url.isDuckURLScheme,
            duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk {
            redirectToDuckPlayerVideo(url: url, webView: webView)
        } else {
            webView.reload()
        }
    }
    
    // Tasks performed as part of the initialization of TabViewController, when the handler
    // Is attached to it
    @MainActor
    func handleAttach(webView: WKWebView) {
        
        // Reset referrer and initial settings
        duckPlayer.settings.allowFirstVideo = false
        referrer = .other
        
        // Ensure feature and mode are enabled
        guard isDuckPlayerFeatureEnabled,
              let url = webView.url,
              duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk else {
            return
        }
        
        // Get parameters and determine redirection
        let parameters = getDuckPlayerParameters(url: url)
        if parameters.allowFirstVideo {
            redirectToYouTubeVideo(url: url, webView: webView)
        } else {
            referrer = parameters.referrer
            redirectToDuckPlayerVideo(url: removeDuckPlayerParameters(from: url), webView: webView)
        }
    }
    
    // Tasks performed as part of the initialization of TabViewController, when the handler
    // Is attached to it
    @MainActor
    func handleDidFinishLoading(webView: WKWebView) {}
    
    // Tasks performed as part of the initialization of TabViewController, when the handler
    // Is attached to it
    @MainActor
    func handleDidStartLoading(webView: WKWebView) {

        duckPlayer.settings.allowFirstVideo = false

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
        
        let isNewTab = tabNavigationHandler?.isNewTab ?? false
        
        guard let url = navigationAction.request.url else {
            return
        }
        
        // If this is a new tab and theres a URL Referrer parameter, use it
        if isNewTab {
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
        }
                
        // If this is not a YoutubeWatch page, just use Other
        if isNewTab
            && webView.url?.isYoutubeWatch ?? false || webView.url == nil
            && duckPlayerMode == .enabled {
            referrer = .other
            return
        }
        
        // Set the referrer to be Youtube Overlay
        // when disable and visiting a video page
        if url.isYoutubeWatch
            && duckPlayerMode == .alwaysAsk {
            referrer = .youtubeOverlay
            return
        }
        
        // SERP as a referrer
        if url.isDuckDuckGoSearch {
            referrer = .serp
            return
        }
                        
        referrer = .other
    }

    // Determine if navigation should be cancelled
    // This is to be used in DecidePolicy For to prevent the webView
    // from opening the Youtube app on user-triggered links
    @MainActor
    func shouldCancelNavigation(navigationAction: WKNavigationAction, webView: WKWebView) -> Bool {
        
        guard let url = navigationAction.request.url else {
            return false
        }
        
        // Only account for MainFrame navigation
        guard navigationAction.isTargetingMainFrame() else {
            return false
        }
        
        // Only if DuckPlayer is enabled
        guard isDuckPlayerFeatureEnabled else {
            return false
        }
        
        // Only account for in 'Always' mode
        if duckPlayerMode != .enabled {
            return false
        }
        
        // Only account for in 'Always' mode
        if url.isDuckPlayer {
            return false
        }
        
        // Do not intercept any back/forward navigation
        if navigationAction.navigationType == .backForward {
            return false
        }
        
        // Only account for non Duck Player URLs
        guard !url.isDuckURLScheme else {
            return false
        }
        
        // Ignore Youtube Watch URL's if allowFirst video is set
        if url.isYoutubeWatch && duckPlayer.settings.allowFirstVideo {
            return false
        }
                
        // Redirect any other Watch Navigation to Duck Player
        if url.isYoutubeWatch {
            redirectToDuckPlayerVideo(url: url, webView: webView)
            return true
        }
        
        // Allow everything else
        return false
        
    }
    
}

extension WKWebView {
    @objc func backListItemsCount() -> Int {
        return backForwardList.backList.count
    }
    
}
