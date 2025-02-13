//
//  DuckPlayerNavigationHandling.swift
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

import WebKit

/// Represents the referrer source for the Duck Player.
public enum DuckPlayerReferrer: String {
    
    case youtube
    case youtubeOverlay
    case serp
    case other
    case undefined
}

extension DuckPlayerReferrer {
    /// Initializes a `DuckPlayerReferrer` from a string value.
    ///
    /// - Parameter string: The string representation of the referrer.
    init(string: String) {
        self = DuckPlayerReferrer(rawValue: string) ?? .undefined
    }
}

/// Represents the result of handling a URL change in the Duck Player navigation handler.
enum DuckPlayerNavigationHandlerURLChangeResult {
    
    /// Possible reasons for not handling a URL change.
    enum NotHandledResult {
        case featureOff
        case invalidURL
        case duckPlayerDisabled
        case isNotYoutubeWatch
        case disabledForVideo
        case duplicateNavigation
    }
    
    /// Possible reasons for handling a URL change.
    enum HandledResult {
        case newVideo
        case allowFirstVideo
        case duckPlayerEnabled
    }

    case handled(HandledResult)
    case notHandled(NotHandledResult)
}

/// Represents the direction of navigation in the Duck Player.
enum DuckPlayerNavigationDirection {
    case back
    case forward
}

@MainActor
/// Protocol defining the navigation handling for Duck Player.
protocol DuckPlayerNavigationHandling: AnyObject {

    /// The referrer of the Duck Player.
    var referrer: DuckPlayerReferrer { get set }
    
    /// Delegate for handling tab navigation events.
    var tabNavigationHandler: DuckPlayerTabNavigationHandling? { get set }
    
    /// The DuckPlayer instance used for handling video playback.
    var duckPlayer: DuckPlayerControlling { get }
    
    /// DuckPlayerOverlayUsagePixels instance used for handling pixel firing.
    var duckPlayerOverlayUsagePixels: DuckPlayerOverlayPixelFiring? { get }
    
    /// Handles URL changes in the web view.
    ///
    /// - Parameter webView: The web view where the URL change occurred.
    /// - Returns: The result of handling the URL change.
    func handleURLChange(webView: WKWebView) -> DuckPlayerNavigationHandlerURLChangeResult
    
    /// Handles the back navigation action in the web view.
    ///
    /// - Parameter webView: The web view to navigate back in.
    func handleGoBack(webView: WKWebView)
    
    /// Handles the reload action in the web view.
    ///
    /// - Parameter webView: The web view to reload.
    func handleReload(webView: WKWebView)
    
    /// Performs actions when the handler is attached to a web view.
    ///
    /// - Parameter webView: The web view being attached.
    func handleAttach(webView: WKWebView)
    
    /// Handles the start of page loading in the web view.
    ///
    /// - Parameter webView: The web view that started loading.
    func handleDidStartLoading(webView: WKWebView)
    
    /// Handles the completion of page loading in the web view.
    ///
    /// - Parameter webView: The web view that finished loading.
    func handleDidFinishLoading(webView: WKWebView)
    
    /// Converts a standard YouTube URL to its Duck Player equivalent if applicable.
    ///
    /// - Parameter url: The YouTube URL to convert.
    /// - Returns: A Duck Player URL if applicable.
    func getDuckURLFor(_ url: URL) -> URL
    
    /// Handles navigation actions to Duck Player URLs.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action to handle.
    ///   - webView: The web view where navigation is occurring.
    func handleDuckNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView)
    
    /// Decides whether to cancel navigation to prevent opening the YouTube app from the web view.
    ///
    /// - Parameters:
    ///   - navigationAction: The navigation action to evaluate.
    ///   - webView: The web view where navigation is occurring.
    /// - Returns: `true` if the navigation should be canceled, `false` otherwise.
    func handleDelegateNavigation(navigationAction: WKNavigationAction, webView: WKWebView) -> Bool
    
    /// Sets the host view controller for the navigation handler.
    func setHostViewController(_ hostViewController: TabViewController)
}

/// Protocol defining the tab navigation handling for Duck Player.
protocol DuckPlayerTabNavigationHandling: AnyObject {
        /// Opens a new tab for the specified URL.
    ///
    /// - Parameter url: The URL to open in a new tab.
    func openTab(for url: URL)
    
    /// Closes the current tab.
    func closeTab()
}

/// Protocol defining a navigation action for Duck Player.
protocol NavigationActionProtocol {
    
    var request: URLRequest { get }
    var isTargetingMainFrame: Bool { get }
    var navigationType: WKNavigationType { get }
}

extension WKNavigationAction: NavigationActionProtocol {
    /// Indicates whether the navigation action targets the main frame.
    var isTargetingMainFrame: Bool {
        return self.targetFrame?.isMainFrame ?? false
    }
}
