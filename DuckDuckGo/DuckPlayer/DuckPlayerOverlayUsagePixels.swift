//
//  DuckPlayerOverlayUsagePixels.swift
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
import Core

protocol DuckPlayerOverlayPixelFiring {

    var pixelFiring: PixelFiring.Type { get set }
    var webView: WKWebView? { get set }
    var duckPlayerMode: DuckPlayerMode { get set }
    func fireNavigationPixelsIfNeeded(webView: WKWebView)
    func fireReloadPixelIfNeeded(url: URL)
}

final class DuckPlayerOverlayUsagePixels: NSObject, DuckPlayerOverlayPixelFiring {

    var pixelFiring: PixelFiring.Type
    var duckPlayerMode: DuckPlayerMode = .disabled
    private var isObserving = false

    weak var webView: WKWebView? {
        didSet {
            if let webView {
                addObservers(to: webView)
            }
        }
    }

    private var lastVisitedURL: URL? // Tracks the last known URL

    init(pixelFiring: PixelFiring.Type = Pixel.self) {
        self.pixelFiring = pixelFiring
    }

    deinit {
        if let webView {
            removeObservers(from: webView)
        }
    }
    
    func fireNavigationPixelsIfNeeded(webView: WKWebView) {

        guard let currentURL = webView.url else {
            return
        }
        
        let backItemURL = webView.backForwardList.backItem?.url

        
        if let (currentVideoID, _) = currentURL.youtubeVideoParams,
           let (oldVideoID, _) = lastVisitedURL?.youtubeVideoParams,
            oldVideoID == currentVideoID {
            return
        }
        
        if lastVisitedURL != nil {
            // Back navigation
            if currentURL == backItemURL {
                firePixelIfNeeded(Pixel.Event.duckPlayerYouTubeOverlayNavigationBack, url: lastVisitedURL)
            }
            // Regular navigation
            else {
                if currentURL.isYoutube {
                    firePixelIfNeeded(Pixel.Event.duckPlayerYouTubeNavigationWithinYouTube, url: lastVisitedURL)
                } else {
                    firePixelIfNeeded(Pixel.Event.duckPlayerYouTubeOverlayNavigationOutsideYoutube, url: lastVisitedURL)
                }
            }
        }

        // Update the last visited URL
        lastVisitedURL = currentURL
    }

    func fireReloadPixelIfNeeded(url: URL) {
        firePixelIfNeeded(Pixel.Event.duckPlayerYouTubeOverlayNavigationRefresh, url: lastVisitedURL)
    }

    // MARK: - Observer Management

    private func addObservers(to webView: WKWebView) {
        removeObservers(from: webView)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: [.new, .old], context: nil)
        isObserving = true
    }

    private func removeObservers(from webView: WKWebView) {
        if isObserving {
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
            isObserving = false
        }
    }

    // swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let webView = object as? WKWebView else { return }
                        
        if keyPath == #keyPath(WKWebView.url) {
            fireNavigationPixelsIfNeeded(webView: webView)
        }
    }
    // swiftlint:enable block_based_kvo

    private func firePixelIfNeeded(_ pixel: Pixel.Event, url: URL?) {
        if let url, url.isYoutubeWatch, duckPlayerMode == .alwaysAsk {
            pixelFiring.fire(pixel, withAdditionalParameters: [:])
        }
    }
}
