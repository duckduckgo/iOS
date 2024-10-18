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
    var experiment: DuckPlayerLaunchExperimentHandling
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
    }
    
    init(duckPlayer: DuckPlayerProtocol = DuckPlayer(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         appSettings: AppSettings,
         experiment: DuckPlayerLaunchExperimentHandling = DuckPlayerLaunchExperiment()) {
        self.duckPlayer = duckPlayer
        self.featureFlagger = featureFlagger
        self.appSettings = appSettings
        self.experiment = experiment
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
        let isEnabled = experiment.isEnrolled && experiment.isExperimentCohort && featureFlagger.isFeatureOn(.duckPlayer)
        return isEnabled ? duckPlayer.settings.mode : .disabled
    }
    
    private var isYouTubeAppInstalled: Bool {
        if let youtubeURL = URL(string: Constants.youtubeScheme) {
            return UIApplication.shared.canOpenURL(youtubeURL)
        }
        return false
    }
    
    private func isSERPLink(navigationAction: WKNavigationAction) -> Bool {
        guard let referrer = navigationAction.request.allHTTPHeaderFields?[Constants.refererHeader] else {
            return false
        }
        if referrer.contains(Constants.SERPURL) {
            return true
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
    
    // DuckPlayer Experiment Handling
    private func handleYouTubePageVisited(url: URL?, navigationAction: WKNavigationAction?) {
        guard let url else { return }
        
        // Parse openInYoutubeURL if present
        let newURL = getYoutubeURLFromOpenInYoutubeLink(url: url) ?? url
        
        guard let (videoID, _) = newURL.youtubeVideoParams else { return }
        
        // If this is a SERP link, set the referrer accordingly
        if let navigationAction, isSERPLink(navigationAction: navigationAction) {
            referrer = .serp
        }
                
        if featureFlagger.isFeatureOn(.duckPlayer) || internalUserDecider.isInternalUser {
            
            // DuckPlayer Experiment run
            let experiment = DuckPlayerLaunchExperiment(duckPlayerMode: duckPlayerMode,
                                                        referrer: referrer,
                                                        isInternalUser: internalUserDecider.isInternalUser)
            
            // Enroll user if not enrolled
            if !experiment.isEnrolled {
                experiment.assignUserToCohort()
            }
            
            // DuckPlayer is disabled before user enrolls,
            // So trigger a settings change notification
            // to let the FE know about the 'actual' setting
            // and update Experiment value
            if experiment.isExperimentCohort {
                duckPlayer.settings.triggerNotification()
                experiment.duckPlayerMode = duckPlayer.settings.mode
            }
            
            experiment.fireYoutubePixel(videoID: videoID)
        }

    }
    
    // Validates a duck:// url and loads it
    private func redirectToDuckPlayerVideo(url: URL?, webView: WKWebView) {
        guard let url,
              let (videoID, _) = url.youtubeVideoParams else { return }
                
        renderedURL = url
        let duckPlayerURL = URL.duckPlayer(videoID)
        Logger.duckPlayer.debug("DP: Redirecting to DuckPlayer Video: \(duckPlayerURL.absoluteString)")
        webView.load(URLRequest(url: duckPlayerURL))
        
    }
    
    // Validates a youtube watch URL and loads it
    private func redirectToYouTubeVideo(url: URL?, webView: WKWebView) {
        guard let url,
               let parsedURL = getYoutubeURLFromOpenInYoutubeLink(url: url)?.addingWatchInYoutubeQueryParameter(),
                parsedURL.isYoutubeWatch,
                let (videoID, _) = url.youtubeVideoParams else { return }
                
        duckPlayer.settings.allowFirstVideo = true
        renderedVideoID = videoID
        webView.load(URLRequest(url: parsedURL))
    }
    
    // Determines if the link should be opened in a new tab
    // And sets the correct navigationType
    // This is uses for JS based navigation links
    private func setOpenInNewTab(url: URL?) {
        guard let url else {
            return
        }
        
        // let openInNewTab = appSettings.duckPlayerOpenInNewTab
        let openInNewTab = appSettings.duckPlayerOpenInNewTab
        let isFeatureEnabled = featureFlagger.isFeatureOn(.duckPlayer)
        let isSubFeatureEnabled = featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab) || internalUserDecider.isInternalUser
        let isDuckPlayerEnabled = duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk
        
        if openInNewTab &&
            isFeatureEnabled &&
            isSubFeatureEnabled &&
            isDuckPlayerEnabled {
            navigationType = .linkActivated
        } else {
            navigationType = .other
        }
    }
    
}

extension DuckPlayerNavigationHandler: DuckPlayerNavigationHandling {
    
    // Handle rendering the simulated request if the URL is duck://
    // and DuckPlayer is either enabled or alwaysAsk
    @MainActor
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView) {
                
        Logger.duckPlayer.debug("Handling Navigation for \(navigationAction.request.url?.absoluteString ?? "")")

        // This is passed to the FE overlay at init to disable the overlay for one video
        duckPlayer.settings.allowFirstVideo = false
        
        guard let url = navigationAction.request.url else { return }
        
        guard featureFlagger.isFeatureOn(.duckPlayer) else { return }
        
        // Handle Open in Youtube Links
        // duck://player/openInYoutube?v=12345
        if let newURL = getYoutubeURLFromOpenInYoutubeLink(url: url) {
                        
            Pixel.fire(pixel: Pixel.Event.duckPlayerWatchOnYoutube)

            // These links should always skip the overlay
            duckPlayer.settings.allowFirstVideo = true

            // Attempt to open in YouTube app (if installed) or load in webView
            if let (videoID, _) = newURL.youtubeVideoParams {
                if appSettings.allowUniversalLinks,
                   isYouTubeAppInstalled,
                   let url = URL(string: "\(Constants.youtubeScheme)\(videoID)") {
                    UIApplication.shared.open(url)
                } else {
                    redirectToYouTubeVideo(url: url, webView: webView)
                }
                return
            }
        }
        
        // Daily Unique View Pixel
        if url.isDuckPlayer,
           duckPlayerMode != .disabled {
            let setting = duckPlayerMode == .enabled ? Constants.duckPlayerAlwaysString : Constants.duckPlayerDefaultString
            DailyPixel.fire(pixel: Pixel.Event.duckPlayerDailyUniqueView, withAdditionalParameters: [Constants.settingsKey: setting])
        }
        
        // Pixel for Views From Youtube
        if referrer == .youtube,
           duckPlayerMode == .enabled {
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromYoutubeAutomatic)
        }
        
        // If this is a new duck:// URL, load DuckPlayer Request
        if url.isDuckURLScheme {
           
            guard let (videoID, _) = url.youtubeVideoParams, videoID != renderedVideoID else { return }
            
            // If DuckPlayer is Enabled or in ask mode, render the video
            if duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk,
               !url.hasWatchInYoutubeQueryParameter {
                let newRequest = Self.makeDuckPlayerRequest(from: URLRequest(url: url))
                
                Logger.duckPlayer.debug("DP: Loading Simulated Request for \(navigationAction.request.url?.absoluteString ?? "")")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.performRequest(request: newRequest, webView: webView)
                    self.renderedVideoID = videoID
                }
                            
            // Otherwise, just redirect to YouTube
            } else {
                redirectToYouTubeVideo(url: url, webView: webView)
            }
            
            return
        }
        
        if url.isYoutubeWatch,
            duckPlayerMode == .enabled || duckPlayerMode == .alwaysAsk {
            
            if url.hasWatchInYoutubeQueryParameter {
                redirectToYouTubeVideo(url: url, webView: webView)
            } else {
                redirectToDuckPlayerVideo(url: url, webView: webView)
            }
            
            
        }
        
    }
    
    @MainActor
    func handleURLChange(webView: WKWebView) -> Bool {
        
        Logger.duckPlayer.debug("DP: Initalizing Navigation handler for URL: (\(webView.url?.absoluteString ?? "No URL")) ")
        
        // If DuckPlayer feature is ON
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            Logger.duckPlayer.debug("DP: Feature flag is off, skipping")
            return false
        }
        
        // If the URL has actually changed
        guard webView.url != renderedURL else {
            Logger.duckPlayer.debug("DP: URL has not changed, skipping")
            return false
        }
        
        // If DuckPlayer is active
        guard duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk else {
            Logger.duckPlayer.debug("DP: DuckPlayer is Disabled, skipping")
            return false
        }
        
        // Log updates, and handle pixels and other events
        if let url = webView.url {
            renderedURL = url
            referrer = url.isYoutube ? .youtube : .other
            
            if url.isYoutubeVideo {
                handleYouTubePageVisited(url: url, navigationAction: nil)
            }
            
        }
        
        // Exit if there are no video details in the URL, exit
        guard let url = webView.url,
              let (videoID, _) = url.youtubeVideoParams else {
            Logger.duckPlayer.debug("DP: No video parameters present in the URL, skipping")
            if let (videoID, _) = webView.url?.youtubeVideoParams {
                renderedVideoID = nil
            }
            return false
        }
        
        guard renderedVideoID != videoID else {
            Logger.duckPlayer.debug("DP: Video should not be handled, as its already rendered")
            return false
        }
        
        // Exit if DuckPlayer should be disabled for the next video
        if duckPlayer.settings.allowFirstVideo,
            let (videoID, _) = url.youtubeVideoParams {
            duckPlayer.settings.allowFirstVideo = false
            Logger.duckPlayer.debug("DP: Video should not be handled, as DuckPlayer is disabled for the next video")
            renderedVideoID = videoID
            return false
        }
        
        // Finally, redirect to Duck Player
        Logger.duckPlayer.debug("DP: Handling Navigation for (\(webView.url?.absoluteString ?? "No URL"))")
        
        redirectToDuckPlayerVideo(url: url, webView: webView)
        return true
         
    }
    
    @MainActor
    func handleGoBack(webView: WKWebView) {
        
        Logger.duckPlayer.debug("DP: Handling Back Navigation")
        
        let experiment = DuckPlayerLaunchExperiment()
        let duckPlayerMode = experiment.isExperimentCohort ? duckPlayerMode : .disabled
        
        guard featureFlagger.isFeatureOn(.duckPlayer) else {
            webView.goBack()
            return
        }
        
        // Check if the back list has items
        guard !webView.backForwardList.backList.isEmpty else {
            webView.goBack()
            return
        }

        // Get the History List
        let backList = webView.backForwardList.backList

        // If we are not at Duck Player, just go back
        if !(webView.url?.isDuckPlayer ?? false) {
            webView.goBack()
            
        } else {
            // We may need to skip the previous URL
            // Which is the YouTube video we already rendered in DuckPlayer
            guard let (videoID, _) = backList.reversed().first?.url.youtubeVideoParams else {
                webView.goBack()
                return
            }
            
            if videoID == renderedVideoID {
                webView.go(to: backList.reversed()[1])
            }
            
        }
        
    }
    
    // Handle Reload for DuckPlayer Videos
    @MainActor
    func handleReload(webView: WKWebView) {
        
        Logger.duckPlayer.debug("DP: Handling Reload")
        
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
    
    // Handle custom events
    // This method is used to delegate tasks to DuckPlayerHandler, such as firing pixels and etc.
    func handleEvent(event: DuckPlayerNavigationEvent, url: URL?, navigationAction: WKNavigationAction?) {
        switch event {
        case .JSTriggeredNavigation:
            setOpenInNewTab(url: url)
        }
    }
    
    // Determine if the links should be open in a new tab, based on the navigationAction and User setting
    // This is used for manually activated links
    func shouldOpenInNewTab(_ navigationAction: WKNavigationAction, webView: WKWebView) -> Bool {
        
        // let openInNewTab = appSettings.duckPlayerOpenInNewTab
        let openInNewTab = appSettings.duckPlayerOpenInNewTab
        let isFeatureEnabled = featureFlagger.isFeatureOn(.duckPlayer)
        let isSubFeatureEnabled = featureFlagger.isFeatureOn(.duckPlayerOpenInNewTab) || internalUserDecider.isInternalUser
        let isDuckPlayer = navigationAction.request.url?.isDuckPlayer ?? false
        let isDuckPlayerEnabled = duckPlayer.settings.mode == .enabled || duckPlayer.settings.mode == .alwaysAsk
        
        if openInNewTab &&
            isFeatureEnabled &&
            isSubFeatureEnabled &&
            isDuckPlayer &&
            self.navigationType == .linkActivated &&
            isDuckPlayerEnabled {
            return true
        }
        return false
    }
    
}

extension WKWebView {
    var isEmptyTab: Bool {
        return self.url == nil || self.url?.absoluteString == "about:blank"
    }
}
