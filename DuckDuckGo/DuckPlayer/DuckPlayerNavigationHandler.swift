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
import Combine

/// Handles navigation and interactions related to Duck Player within the app.
final class DuckPlayerNavigationHandler: NSObject {

    /// The DuckPlayer instance used for handling video playback.
    var duckPlayer: DuckPlayerControlling
    
    /// The DuckPlayerOverlayPixelFiring instance used for handling overlay pixel firing.
    var duckPlayerOverlayUsagePixels: DuckPlayerOverlayPixelFiring?
    
    /// Indicates where the DuckPlayer was referred from (e.g., YouTube, SERP).
    var referrer: DuckPlayerReferrer = .other
    
    /// Feature flag manager for enabling/disabling features.
    var featureFlagger: FeatureFlagger
    
    /// Application settings.
    var appSettings: AppSettings
    
    /// Pixel firing utility for analytics.
    var pixelFiring: PixelFiring.Type
    let dailyPixelFiring: DailyPixelFiring.Type
    
    /// Keeps track of the last YouTube video watched.
    var lastWatchInYoutubeVideo: String?
       
    // Redirection Throttle
    /// Timestamp of the last Duck Player redirection.
    private var lastDuckPlayerRedirect: Date?
    
    /// Duration to throttle Duck Player redirects.
    private let lastDuckPlayerRedirectThrottleDuration: TimeInterval = 1
    
    // Navigation URL Changing Throttle
    /// Timestamp of the last URL change handling.
    private var lastURLChangeHandling: Date?
    
    /// Duration to throttle URL change handling.
    private let lastURLChangeHandlingThrottleDuration: TimeInterval = 1
    
    // Navigation Cancelling Throttle
    /// Timestamp of the last navigation handling.
    private var lastNavigationHandling: Date?
    
    /// Duration to throttle navigation handling.
    private let lastNavigationHandlingThrottleDuration: TimeInterval = 1
            
    /// Delegate for handling tab navigation events.
    weak var tabNavigationHandler: DuckPlayerTabNavigationHandling?
    
    /// Cancellable for observing DuckPlayer Mode changes
    private var duckPlayerModeCancellable: AnyCancellable?
    
    /// Cancellable for observing DuckPlayer Navigation Request
    private var duckPlayerNavigationRequestCancellable: AnyCancellable?
    
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
    
    /// Initializes a new instance of `DuckPlayerNavigationHandler` with the provided dependencies.
    ///
    /// - Parameters:
    ///   - duckPlayer: The DuckPlayer instance.
    ///   - featureFlagger: The feature flag manager.
    ///   - appSettings: The application settings.
    ///   - pixelFiring: The pixel firing utility for analytics.
    ///   - dailyPixelFiring: The daily pixel firing utility for analytics.
    ///   - tabNavigationHandler: The tab navigation handler delegate.
    init(duckPlayer: DuckPlayerControlling = DuckPlayer(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         appSettings: AppSettings,
         pixelFiring: PixelFiring.Type = Pixel.self,
         dailyPixelFiring: DailyPixelFiring.Type = DailyPixel.self,
         tabNavigationHandler: DuckPlayerTabNavigationHandling? = nil,
         duckPlayerOverlayUsagePixels: DuckPlayerOverlayPixelFiring? = DuckPlayerOverlayUsagePixels()) {
        self.duckPlayer = duckPlayer
        self.featureFlagger = featureFlagger
        self.appSettings = appSettings
        self.pixelFiring = pixelFiring
        self.dailyPixelFiring = dailyPixelFiring
        self.tabNavigationHandler = tabNavigationHandler
        self.duckPlayerOverlayUsagePixels = duckPlayerOverlayUsagePixels
        
        super.init()
    }
    
    deinit {
        // Clean up Combine subscriptions
        duckPlayerModeCancellable?.cancel()
        duckPlayerNavigationRequestCancellable?.cancel()
    }
    
    /// Returns the file path for the Duck Player HTML template.
    static var htmlTemplatePath: String {
        guard let file = ContentScopeScripts.Bundle.path(forResource: Constants.templateName,
                                                         ofType: Constants.templateExtension,
                                                         inDirectory: Constants.templateDirectory) else {
            assertionFailure("YouTube Private Player HTML template not found")
            return ""
        }
        return file
    }

    /// Creates a `URLRequest` for Duck Player using the original request's YouTube video ID and timestamp.
    ///
    /// - Parameter originalRequest: The original YouTube `URLRequest`.
    /// - Returns: A new `URLRequest` pointing to the Duck Player.
    static func makeDuckPlayerRequest(from originalRequest: URLRequest) -> URLRequest {
        guard let (youtubeVideoID, timestamp) = originalRequest.url?.youtubeVideoParams else {
            assertionFailure("Request should have ID")
            return originalRequest
        }
        return makeDuckPlayerRequest(for: youtubeVideoID, timestamp: timestamp)
    }

    /// Generates a `URLRequest` for Duck Player with a specific YouTube video ID and optional timestamp.
    ///
    /// - Parameters:
    ///   - videoID: The YouTube video ID.
    ///   - timestamp: Optional timestamp for the video.
    /// - Returns: A `URLRequest` configured for Duck Player.
    static func makeDuckPlayerRequest(for videoID: String, timestamp: String?) -> URLRequest {
        var request = URLRequest(url: .youtubeNoCookie(videoID, timestamp: timestamp))
        request.addValue(Constants.localhost, forHTTPHeaderField: Constants.refererHeader)
        request.httpMethod = Constants.httpMethod
        return request
    }

    /// Loads and returns the HTML content from the Duck Player template file.
    ///
    /// - Returns: The HTML content as a `String`.
    static func makeHTMLFromTemplate() -> String {
        guard let html = try? String(contentsOfFile: htmlTemplatePath) else {
            assertionFailure("Should be able to load template")
            return ""
        }
        return html
    }
    
    /// Navigates to the Duck Player URL in the web view. Opens in a new tab if settings dictate.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to navigate to.
    ///   - responseHTML: The HTML content to load.
    ///   - webView: The `WKWebView` to load the content into.
    @MainActor
    private func performNavigation(_ request: URLRequest, responseHTML: String, webView: WKWebView) {
        
        // If DuckPlayer is enabled, and we're watching a video in YouTube (temporarily)
        // Any direct navigation to a duck:// URL should open in a new tab
        if let url = webView.url, url.isYoutubeWatch && isOpenInNewTabEnabled && duckPlayerMode == .enabled {
            self.redirectToDuckPlayerVideo(url: request.url, webView: webView)
            return
        }
        // Otherwise, just load the simulated request
        // New tabs require a short interval so the Omnibars dismissal propagates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            webView.loadSimulatedRequest(request, responseHTML: responseHTML)
        }
    }
    
    /// Handles the Duck Player request by generating HTML from the template and performing navigation.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to handle.
    ///   - webView: The `WKWebView` to load the content into.
    @MainActor
    private func performRequest(request: URLRequest, webView: WKWebView) {
        let html = Self.makeHTMLFromTemplate()
        let duckPlayerRequest = Self.makeDuckPlayerRequest(from: request)
        performNavigation(duckPlayerRequest, responseHTML: html, webView: webView)
    }
    
    /// Checks if the Duck Player feature is enabled via feature flags.
    private var isDuckPlayerFeatureEnabled: Bool {
        featureFlagger.isFeatureOn(.duckPlayer)
    }
    
    /// Determines if "Open in New Tab" for Duck Player is enabled in the settings.
    private var isOpenInNewTabEnabled: Bool {
        featureFlagger.isFeatureOn(.duckPlayer) && featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab) && duckPlayer.settings.openInNewTab && duckPlayerMode != .disabled
    }
    
    /// Retrieves the current mode of Duck Player based on feature flags and user settings.
    private var duckPlayerMode: DuckPlayerMode {
        let isEnabled = isDuckPlayerFeatureEnabled
        return isEnabled ? duckPlayer.settings.mode : .disabled
    }
    
    /// Checks if the YouTube app is installed on the device.
    private var isYouTubeAppInstalled: Bool {
        if let youtubeURL = URL(string: Constants.youtubeScheme) {
            return UIApplication.shared.canOpenURL(youtubeURL)
        }
        return false
    }
    
    /// Extracts a YouTube URL from a Duck Player "Open in YouTube" link.
    ///
    /// - Parameter url: The URL to parse.
    /// - Returns: A YouTube `URL` if available.
    private func getYoutubeURLFromOpenInYoutubeLink(url: URL) -> URL? {
        guard isWatchInYouTubeURL(url: url),
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let videoParameterItem = urlComponents.queryItems?.first(where: { $0.name == Constants.watchInYoutubeVideoParameter }),
              let id = videoParameterItem.value else {
            return nil
        }
        return URL.youtube(id, timestamp: nil)
    }

    /// Determines if the URL is an "Open in YouTube" Duck Player link.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if it's an "Open in YouTube" link, `false` otherwise.
    private func isWatchInYouTubeURL(url: URL) -> Bool {
        guard url.scheme == Constants.duckPlayerScheme,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              urlComponents.path == "/\(Constants.watchInYoutubePath)" else {
            return false
        }
        return true
    }
    
    /// Redirects the web view to play the video in Duck Player, optionally forcing a new tab.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - webView: The `WKWebView` to load the content into.
    ///   - forceNewTab: Whether to force opening in a new tab.
    ///   - disableNewTab: Ignore openInNewTab settings
    @MainActor
    private func redirectToDuckPlayerVideo(url: URL?, webView: WKWebView, forceNewTab: Bool = false, disableNewTab: Bool = false) {
        
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
        
        // Mute audio for the opening tab if required
        // This prevents opening tab from hijacking Audio Session
        // and playing audio in the background
        toggleAudioForTab(webView, mute: true)
        
        if duckPlayer.settings.nativeUI {
            loadNativeDuckPlayerVideo(videoID: videoID)
            return
        }
        
        let duckPlayerURL = URL.duckPlayer(videoID)
        self.loadWithDuckPlayerParameters(URLRequest(url: duckPlayerURL), referrer: self.referrer, webView: webView, forceNewTab: forceNewTab, disableNewTab: disableNewTab)
    }
    
    /// Redirects to the YouTube video page, allowing the first video if necessary.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - webView: The `WKWebView` to load the content into.
    ///   - forceNewTab: Whether to force opening in a new tab.
    ///   - allowFirstVideo: Hide DuckPlayer Overlay in the first loaded video
    ///   - disableNewTab: Ignore openInNewTab settings
    @MainActor
    private func redirectToYouTubeVideo(url: URL?, webView: WKWebView, forceNewTab: Bool = false, allowFirstVideo: Bool = true, disableNewTab: Bool = false) {
        
        guard let url else { return }
        
        var redirectURL = url
        
        // Parse OpenInYouTubeURLs if present
        if let parsedURL = getYoutubeURLFromOpenInYoutubeLink(url: url) {
            redirectURL = parsedURL
        }
        
        // When redirecting to YouTube, we always allow the first video
        loadWithDuckPlayerParameters(URLRequest(url: redirectURL), referrer: referrer, webView: webView, forceNewTab: forceNewTab, allowFirstVideo: allowFirstVideo, disableNewTab: disableNewTab)
    }
    
    @MainActor
    private func loadNativeDuckPlayerVideo(videoID: String) {
        duckPlayer.loadNativeDuckPlayerVideo(videoID: videoID)
    }
    
    
    /// Fires analytics pixels when Duck Player is viewed, based on referrer and settings.
    private func fireDuckPlayerPixels(webView: WKWebView) {
                
        // First daily unique user Duck Player view
        dailyPixelFiring.fireDaily(.duckPlayerDailyUniqueView, withAdditionalParameters: ["settings": duckPlayerMode.stringValue])
        
        // Duck Player viewed with Always setting, referred from YouTube (automatic)
        if (referrer == .youtube) && duckPlayerMode == .enabled {
            pixelFiring.fire(.duckPlayerViewFromYoutubeAutomatic, withAdditionalParameters: [:])
        }
        
        // Duck Player viewed from SERP
        if referrer == .serp {
            pixelFiring.fire(.duckPlayerViewFromSERP, withAdditionalParameters: [:])
        }
        
        // Other referrers
        if referrer == .other || referrer == .undefined {
            pixelFiring.fire(.duckPlayerViewFromOther, withAdditionalParameters: [:])
        }
        
    }
    
    /// Fires an analytics pixel when the user opts to watch a video on YouTube instead.
    private func fireOpenInYoutubePixel() {
        pixelFiring.fire(.duckPlayerWatchOnYoutube, withAdditionalParameters: [:])
    }
    
    /// Cancels JavaScript-triggered navigation by stopping the load and going back if possible.
    ///
    /// - Parameters:
    ///   - webView: The `WKWebView` to manipulate.
    ///   - completion: Optional completion handler.
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
    
    /// Toggles audio playback for a specific webView.
    ///
    /// - Parameters:
    ///  - webView: The `WKWebView` to manipulate.
    ///  - mute: Whether to mute the audio.
    @MainActor
    private func toggleAudioForTab(_ webView: WKWebView, mute: Bool) {
        if duckPlayer.settings.openInNewTab || duckPlayer.settings.nativeUI {
            webView.evaluateJavaScript("""
                document.querySelectorAll('video, audio').forEach(function(media) {
                    media.muted = \(mute);
                });
            """)
        }
    }
        
    /// Loads a request with Duck Player parameters, handling new tab logic and first video allowance.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to load.
    ///   - referrer: The referrer information.
    ///   - webView: The `WKWebView` to load the content into.
    ///   - forceNewTab: Whether to force opening in hana new tab.
    ///   - allowFirstVideo: Whether to allow the first video to play.
    ///   - disableNewTab: Ignores Open in New tab settings
    private func loadWithDuckPlayerParameters(_ request: URLRequest,
                                              referrer: DuckPlayerReferrer,
                                              webView: WKWebView,
                                              forceNewTab: Bool = false,
                                              allowFirstVideo: Bool = false,
                                              disableNewTab: Bool = false) {
        
        guard let url = request.url else {
            return
        }
        
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and YouTube's own redirects
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
        let referrer = referrer.rawValue
                
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
        if (isOpenInNewTabEnabled || forceNewTab) && !disableNewTab {
            tabNavigationHandler?.openTab(for: newURL)
        } else {
            webView.load(URLRequest(url: newURL))
        }
        
        Logger.duckPlayer.debug("DP: loadWithDuckPlayerParameters: \(newURL.absoluteString)")
        
    }
    
    /// Extracts Duck Player-specific parameters from the URL for internal use.
    ///
    /// - Parameter url: The URL to parse.
    /// - Returns: A `DuckPlayerParameters` struct containing the extracted values.
    private func getDuckPlayerParameters(url: URL) -> DuckPlayerParameters {
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return DuckPlayerParameters(referrer: .other, isNewTap: false, allowFirstVideo: false)
        }
        
        let referrerValue = queryItems.first(where: { $0.name == Constants.duckPlayerReferrerParameter })?.value
        let allowFirstVideoValue = queryItems.first(where: { $0.name == Constants.allowFirstVideoParameter })?.value
        let isNewTabValue = queryItems.first(where: { $0.name == Constants.newTabParameter })?.value
        let youtubeEmbedURI = queryItems.first(where: { $0.name == Constants.youtubeEmbedURI })?.value ?? ""
        
        // Use the from(string:) method to parse referrer
        let referrer = DuckPlayerReferrer(string: referrerValue ?? "")
        let allowFirstVideo = allowFirstVideoValue == "1" || !youtubeEmbedURI.isEmpty
        let isNewTab = isNewTabValue == "1"
        
        return DuckPlayerParameters(referrer: referrer, isNewTap: isNewTab, allowFirstVideo: allowFirstVideo)
    }
    
    /// Removes Duck Player-specific query parameters from a URL.
    ///
    /// - Parameter url: The URL to clean.
    /// - Returns: A new URL without Duck Player parameters.
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
    
    /// Determines if a URL is a DuckPlayer redirect based on its parameters
    ///
    /// - Parameter url: To check
    /// - Returns: True | False
    private func isDuckPlayerRedirect(url: URL) -> Bool {
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return false
        }
        
        let referrerValue = queryItems.first(where: { $0.name == Constants.duckPlayerReferrerParameter })?.value
        let allowFirstVideoValue = queryItems.first(where: { $0.name == Constants.allowFirstVideoParameter })?.value
        let isNewTabValue = queryItems.first(where: { $0.name == Constants.newTabParameter })?.value
        let youtubeEmbedURI = queryItems.first(where: { $0.name == Constants.youtubeEmbedURI })?.value
        
        return referrerValue != nil || allowFirstVideoValue != nil || isNewTabValue != nil || youtubeEmbedURI != nil
    }
    
    /// Sets the referrer based on the current web view URL to aid in analytics.
    ///
    /// - Parameter webView: The `WKWebView` whose URL is used to determine the referrer.
    private func setReferrer(webView: WKWebView) {
        
        // Make sure we are NOT DuckPlayer
        guard let url = webView.url, !url.isDuckPlayer else { return }
                
        // First, try to use the back Item
        var backItems = webView.backForwardList.backList.reversed()
        
        // Ignore any previous URL that's duckPlayer or youtube-no-cookie
        if backItems.first?.url != nil, url.isDuckPlayer {
            backItems = webView.backForwardList.backList.dropLast().reversed()
        }
        
        // If the current URL is DuckPlayer, use the previous history item
        guard let referrerURL = url.isDuckPlayer ? backItems.first?.url : url else {
            return
        }
        
        // SERP as a referrer
        if referrerURL.isDuckDuckGoSearch {
            referrer = .serp
            return
        }
        
        // Set to Youtube for "Watch in Youtube videos"
        if referrerURL.isYoutubeWatch && duckPlayerMode == .enabled && duckPlayer.settings.allowFirstVideo {
            referrer = .youtube
            return
        }
        
        // Set to Overlay for Always ask
        if referrerURL.isYoutubeWatch && duckPlayerMode == .alwaysAsk {
            referrer = .youtubeOverlay
            return
        }
        
        // Any Other Youtube URL or other referrer
        if referrerURL.isYoutube {
            referrer = .youtube
            return
        } else {
            referrer = .other
        }
        
    }
    
    /// Determines if the current tab is a new tab based on the targetFrame request and other params
    ///
    /// - Parameter navigationAction: The `WKNavigationAction` used to determine the tab type.
    private func isNewTab(_ navigationAction: WKNavigationAction) -> Bool {
        
        guard let request = navigationAction.targetFrame?.safeRequest,
              let url = request.url else {
            return false
        }
        
        // Always return false if open in new tab is disabled
        guard isOpenInNewTabEnabled else { return false }
        
        // If the target frame is duckPlayer itself or there's no URL
        // we're at a new tab
        if url.isDuckPlayer || url.isEmpty {
            return true
        }
        
        return false
    }
    
    /// Register a DuckPlayer mode Observe to handle events when the mode changes
    private func setupPlayerModeObserver() {
        duckPlayerModeCancellable =  duckPlayer.settings.duckPlayerSettingsPublisher
            .sink { [weak self] in
                self?.duckPlayerOverlayUsagePixels?.duckPlayerMode = self?.duckPlayer.settings.mode ?? .disabled
            }
    }
    
    /// Register a DuckPlayer Youtube Navigation Request observer
    /// Used when DuckPlayer requires direct Youtube Navigation
    @MainActor
    private func setupYoutubeNavigationRequestObserver(webView: WKWebView) {
        duckPlayerNavigationRequestCancellable = duckPlayer.youtubeNavigationRequest
            .sink { [weak self] url in
                self?.redirectToYouTubeVideo(url: url, webView: webView)
            }
    }
    
    /// // Handle "open in YouTube" links (duck://player/openInYoutube)
    ///
    /// - Parameter url: The `URL` used to determine the tab type.
    /// - Parameter webView: The `WebView` used for navigation/redirection
    @MainActor
    private func handleOpenInYoutubeLink(url: URL, webView: WKWebView) {
        
        // Handle "open in YouTube" links (duck://player/openInYoutube)
        guard let (videoID, _) = url.youtubeVideoParams else {
            return
        }
        
        // Fire a Pixel for Open in YouTube
        self.fireOpenInYoutubePixel()
        
        // Attempt to open in YouTube app or load in webView
        if appSettings.allowUniversalLinks, isYouTubeAppInstalled,
           let youtubeAppURL = URL(string: "\(Constants.youtubeScheme)\(videoID)") {
            UIApplication.shared.open(youtubeAppURL)
        } else {
            // Watch in YT videos always open in new tab
            redirectToYouTubeVideo(url: url, webView: webView, forceNewTab: true)
        }
    }

    
    /// Checks if a URL contains a hash
    ///
    /// - Parameter url: The `URL` used to determine the tab type.
    private func urlContainsHash(_ url: URL) -> Bool {
        return url.fragment != nil && !url.fragment!.isEmpty
    }
    
    /// Checks a URL and updates the referer if present
    ///
    /// - Parameter url: The 'URL' with referrer parameters (current URL)
    private func updateReferrerIfNeeded(url: URL) {
        // Get the referrer from the URL if present
        let urlReferrer = getDuckPlayerParameters(url: url).referrer
        if urlReferrer != .other && urlReferrer != .undefined {
            referrer = urlReferrer
        }
    }
    
}

extension DuckPlayerNavigationHandler: DuckPlayerNavigationHandling {
    
    /// Manages navigation actions to Duck Player URLs, handling redirects and loading as needed.
    ///
    /// - Parameters:
    ///   - navigationAction: The `WKNavigationAction` to handle.
    ///   - webView: The `WKWebView` where navigation is occurring.
    @MainActor
    func handleDuckNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView) {
                
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and quick URL changes
        if let lastTimestamp = lastNavigationHandling,
           Date().timeIntervalSince(lastTimestamp) < lastNavigationHandlingThrottleDuration {
            return
        }
        
        lastNavigationHandling = Date()

        guard let url = navigationAction.request.url else { return }
        
        // Redirect to YouTube if DuckPlayer is disabled
        guard duckPlayerMode != .disabled else {
            if let (videoID, _) = url.youtubeVideoParams {
                redirectToYouTubeVideo(url: URL.youtube(videoID), webView: webView)
            }
            return
        }
        
        // Handle "open in YouTube" links (duck://player/openInYoutube)
        if let openInYouTubeURL = getYoutubeURLFromOpenInYoutubeLink(url: url) {
           handleOpenInYoutubeLink(url: openInYouTubeURL, webView: webView)
            return
        }
        
        // Determine navigation type
        let shouldOpenInNewTab = isOpenInNewTabEnabled && !isNewTab(navigationAction)
        
        // Update referrer if needed
        updateReferrerIfNeeded(url: url)
        
        // Handle duck:// scheme URLs (Or direct navigation to duck player)
        if url.isDuckURLScheme {
            
            // If should be opened in a new tab, and it's not a DuckPlayer URL, it means this
            // is a direct duck:// navigation, so we need to properly redirect to a duckPlayer version
            if shouldOpenInNewTab && !isDuckPlayerRedirect(url: url) {
                redirectToDuckPlayerVideo(url: url, webView: webView, forceNewTab: true)
                return
            }
            
            // Simulate DuckPlayer request if in enabled/ask mode and not redirected to YouTube
            if duckPlayerMode != .disabled,
               !url.hasWatchInYoutubeQueryParameter {
                let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
                
                // The webView needs some time for state to propagate
                // Before performing the simulated request
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.performRequest(request: newRequest, webView: webView)
                    self.fireDuckPlayerPixels(webView: webView)
                    
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
    
    /// Observes URL changes and redirects to Duck Player when appropriate, avoiding duplicate handling.
    ///
    /// - Parameter webView: The `WKWebView` whose URL has changed.
    /// - Returns: A result indicating whether the URL change was handled.
    @MainActor
    func handleURLChange(webView: WKWebView) -> DuckPlayerNavigationHandlerURLChangeResult {
        
        // We want to prevent multiple simultaneous redirects
        // This can be caused by Duplicate Nav events, and quick URL changes
        if let lastTimestamp = lastURLChangeHandling,
           Date().timeIntervalSince(lastTimestamp) < lastURLChangeHandlingThrottleDuration {
            return .notHandled(.duplicateNavigation)
        }
        
        // Update the Referrer based on the first URL change detected
        setReferrer(webView: webView)
        
        // We don't want YouTube redirects happening while default navigation is happening
        // This can be caused by Duplicate Nav events, and quick URL changes
        if let lastTimestamp = lastNavigationHandling,
           Date().timeIntervalSince(lastTimestamp) < lastNavigationHandlingThrottleDuration {
            return .notHandled(.duplicateNavigation)
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
            return .handled(.newVideo)
        }
        
        let parameters = getDuckPlayerParameters(url: url)
        
        // If this is an internal Youtube Link (i.e Clicking in youtube logo in the player)
        // Do not handle it
        
        // If the URL has the allow first video, we just don't handle it
        if parameters.allowFirstVideo {
            lastWatchInYoutubeVideo = videoID
            lastURLChangeHandling = Date()
            return .handled(.allowFirstVideo)
        }
        
        guard duckPlayerMode == .enabled else {
            return .notHandled(.duckPlayerDisabled)
        }

        // Handle YouTube watch URLs based on DuckPlayer settings
        if duckPlayerMode == .enabled && !parameters.allowFirstVideo {
            cancelJavascriptNavigation(webView: webView, completion: {
                self.redirectToDuckPlayerVideo(url: url, webView: webView)
            })
            lastURLChangeHandling = Date()
            Logger.duckPlayer.debug("Handling URL change for \(webView.url?.absoluteString ?? "")")
            return .handled(.duckPlayerEnabled)
        } else {
            
        }
        
        return .notHandled(.isNotYoutubeWatch)
    }
    
    /// Custom back navigation logic to handle Duck Player in the web view's history stack.
    ///
    /// - Parameter webView: The `WKWebView` to navigate back in.
    @MainActor
    func handleGoBack(webView: WKWebView) {
                
        guard let url = webView.url, url.isDuckPlayer, isDuckPlayerFeatureEnabled else {
            webView.goBack()
            return
        }
        
        // Check if the back list has items, and if not try to close the tab
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

    
    /// Handles reload actions, ensuring Duck Player settings are respected during the reload.
    ///
    /// - Parameter webView: The `WKWebView` to reload.
    @MainActor
    func handleReload(webView: WKWebView) {
        
        // Reset DuckPlayer status
        duckPlayer.settings.allowFirstVideo = false
                
        guard let url = webView.url else {
            return
        }
        
        guard isDuckPlayerFeatureEnabled else {
            webView.reload()
            return
        }
                    
        if url.isDuckPlayer, duckPlayerMode != .disabled {
            redirectToDuckPlayerVideo(url: url, webView: webView, disableNewTab: true)
            return
        }
        
        if url.isYoutubeWatch, duckPlayerMode == .alwaysAsk {
            redirectToYouTubeVideo(url: url, webView: webView, allowFirstVideo: false, disableNewTab: true)
            return
        }
        
        webView.reload()
        
    }
    
    /// Initializes settings and potentially redirects when the handler is attached to a web view.
    ///
    /// - Parameter webView: The `WKWebView` being attached.
    @MainActor
    func handleAttach(webView: WKWebView) {
        
        // Reset referrer and initial settings
        referrer = .other

        // Attach WebView to OverlayPixels
        duckPlayerOverlayUsagePixels?.webView = webView
        duckPlayerOverlayUsagePixels?.duckPlayerMode = duckPlayer.settings.mode
        setupPlayerModeObserver()
        setupYoutubeNavigationRequestObserver(webView: webView)
        
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
            redirectToDuckPlayerVideo(url: url, webView: webView, disableNewTab: true)
        }
        
    }
    
    /// Updates the referrer after the web view finishes loading a page.
    ///
    /// - Parameter webView: The `WKWebView` that finished loading.
    @MainActor
    func handleDidFinishLoading(webView: WKWebView) {
        
        // Reset allowFirstVideo
        duckPlayer.settings.allowFirstVideo = false
        
        
    }
    
    /// Resets settings when the web view starts loading a new page.
    ///
    /// - Parameter webView: The `WKWebView` that started loading.
    @MainActor
    func handleDidStartLoading(webView: WKWebView) {
        
        setReferrer(webView: webView)
        
        // Automatically reset allowFirstVideo after loading starts
        // This is a fallback as the WKNavigation Delegate does not
        // Always fires finishLoading (For JS Navigation) which
        // triggers handleDidFinishLoading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.duckPlayer.settings.allowFirstVideo = false
        }
    
    }
    
    /// Converts a standard YouTube URL to its Duck Player equivalent if applicable.
    ///
    /// - Parameter url: The YouTube `URL` to convert.
    /// - Returns: A Duck Player `URL` if applicable.
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

    /// Decides whether to cancel navigation to prevent opening the YouTube app from the web view.
    ///
    /// - Parameters:
    ///   - navigationAction: The `WKNavigationAction` to evaluate.
    ///   - webView: The `WKWebView` where navigation is occurring.
    /// - Returns: `true` if the navigation should be canceled, `false` otherwise.
    @MainActor
    func handleDelegateNavigation(navigationAction: WKNavigationAction, webView: WKWebView) -> Bool {
        
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
        if duckPlayerMode == .disabled {
            return false
        }
        
        // Only account for in 'Duck Player' URL
        if url.isDuckPlayer {
            return false
        }
        
        // Do not intercept any back/forward navigation
        if navigationAction.navigationType == .backForward {
            return false
        }
                
        // Ignore YouTube Watch URLs if allowFirst video is set
        if url.isYoutubeWatch && duckPlayer.settings.allowFirstVideo {
            return false
        }
        
        // Allow Youtube's internal navigation when DuckPlayer is enabled and user is watching on Youtube
        // Youtube uses hashes to navigate within some settings
        // This allows any navigation that includes a hash # (#searching, #bottom-sheet, etc)
        if urlContainsHash(url), url.isYoutubeWatch {
            return false
        }
        
        // Redirect to Duck Player if enabled
        if url.isYoutubeWatch && duckPlayerMode == .enabled && !isDuckPlayerRedirect(url: url) {
            redirectToDuckPlayerVideo(url: url, webView: webView)
            return true
        }
        
        // Redirect to Youtube + DuckPlayer Overlay if Ask Mode
        if url.isYoutubeWatch && duckPlayerMode == .alwaysAsk && !isDuckPlayerRedirect(url: url) {
            redirectToYouTubeVideo(url: url, webView: webView, allowFirstVideo: false, disableNewTab: true)
            return true
        }
        
        // Allow everything else
        return false
        
    }
    
    /// Sets the host view controller for Duck Player.
    ///
    /// - Parameters:
    ///  - hostViewController: The `TabViewController` to set as the host.
    @MainActor
    func setHostViewController(_ hostViewController: TabViewController) {
        duckPlayer.setHostViewController(hostViewController)
        
        // Ensure the tab is not muted
        toggleAudioForTab(hostViewController.webView, mute: false)
    }
    
}

extension WKWebView {
    /// Returns the count of items in the web view's back navigation list.
    @objc func backListItemsCount() -> Int {
        return backForwardList.backList.count
    }
    
}
