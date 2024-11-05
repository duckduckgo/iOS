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

import Core

protocol DuckPlayerOverlayPixelFiring {
    
    var pixelFiring: PixelFiring.Type { get set }
    var navigationHistory: [URL] { get set }
    
    func registerNavigation(url: URL?)
    func navigationBack(duckPlayerMode: DuckPlayerMode)
    func navigationReload(duckPlayerMode: DuckPlayerMode)
    func navigationWithinYoutube(duckPlayerMode: DuckPlayerMode)
    func navigationOutsideYoutube(duckPlayerMode: DuckPlayerMode)
    func navigationClosed(duckPlayerMode: DuckPlayerMode)
    func overlayIdle(duckPlayerMode: DuckPlayerMode)
    
}

class DuckPlayerOverlayUsagePixels: DuckPlayerOverlayPixelFiring {

    var pixelFiring: PixelFiring.Type
    var navigationHistory: [URL] = []

    private var idleTimer: Timer?
    private var idleTimeInterval: TimeInterval

    init(pixelFiring: PixelFiring.Type = Pixel.self,
         navigationHistory: [URL] = [],
         timeoutInterval: TimeInterval = 30.0) {
        self.pixelFiring = pixelFiring
        self.idleTimeInterval = timeoutInterval
    }

    // Method to reset the idle timer
    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
    }

    func registerNavigation(url: URL?) {
        guard let url = url else { return }
        navigationHistory.append(url)
        
        // Cancel and reset the idle timer whenever a new navigation occurs
        resetIdleTimer()
    }

    func navigationBack(duckPlayerMode: DuckPlayerMode) {
        guard duckPlayerMode == .alwaysAsk,
              let lastURL = navigationHistory.last,
              lastURL.isYoutubeWatch else { return }

        pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationBack, withAdditionalParameters: [:])
    }

    func navigationReload(duckPlayerMode: DuckPlayerMode) {
        guard duckPlayerMode == .alwaysAsk,
              let lastURL = navigationHistory.last,
              lastURL.isYoutubeWatch else { return }

        pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationRefresh, withAdditionalParameters: [:])
    }

    func navigationWithinYoutube(duckPlayerMode: DuckPlayerMode) {
        guard duckPlayerMode == .alwaysAsk,
              navigationHistory.count > 1,
              let currentURL = navigationHistory.last,
              let previousURL = navigationHistory.dropLast().last,
              previousURL.isYoutubeWatch,
              currentURL.isYoutube else { return }

        pixelFiring.fire(.duckPlayerYouTubeNavigationWithinYouTube, withAdditionalParameters: [:])
    }

    func navigationOutsideYoutube(duckPlayerMode: DuckPlayerMode) {
        guard duckPlayerMode == .alwaysAsk,
              navigationHistory.count > 1,
              let currentURL = navigationHistory.last,
              let previousURL = navigationHistory.dropLast().last,
              previousURL.isYoutubeWatch,
              !currentURL.isYoutube else { return }

        pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationOutsideYoutube, withAdditionalParameters: [:])
    }

    func navigationClosed(duckPlayerMode: DuckPlayerMode) {
        
        guard duckPlayerMode == .alwaysAsk,
              let lastURL = navigationHistory.last,
              lastURL.isYoutubeWatch else { return }
        
        pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationClosed, withAdditionalParameters: [:])
        
    }

    func overlayIdle(duckPlayerMode: DuckPlayerMode) {
        guard duckPlayerMode == .alwaysAsk,
              let lastURL = navigationHistory.last,
              lastURL.isYoutubeWatch else { return }

        idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeInterval, repeats: false) { [weak self] _ in
            self?.pixelFiring.fire(.duckPlayerYouTubeNavigationIdle30, withAdditionalParameters: [:])
        }
    }
}
