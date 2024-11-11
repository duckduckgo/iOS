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
    
    func handleNavigationAndFirePixels(url: URL?, duckPlayerMode: DuckPlayerMode)
}

final class DuckPlayerOverlayUsagePixels: DuckPlayerOverlayPixelFiring {

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

    func handleNavigationAndFirePixels(url: URL?, duckPlayerMode: DuckPlayerMode) {
        guard let url = url else { return }
        let comparisonURL = url.forComparison()

        // Only append the URL if it's different from the last entry in normalized form
        navigationHistory.append(comparisonURL)

        // DuckPlayer is in Ask Mode, there's navigation history, and last URL is a YouTube Watch Video
        guard duckPlayerMode == .alwaysAsk,
              navigationHistory.count > 1,
              let currentURL = navigationHistory.last,
              let previousURL = navigationHistory.dropLast().last,
              previousURL.isYoutubeWatch else { return }

        var isReload = false
        // Check for a reload condition: when current videoID is the same as Previous
        if let currentVideoID = currentURL.youtubeVideoParams?.videoID,
           let previousVideoID = previousURL.youtubeVideoParams?.videoID {
            isReload = currentVideoID == previousVideoID
        }

        // Fire the reload pixel if this is a reload navigation
        if isReload {
            pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationRefresh, withAdditionalParameters: [:])
        } else {
            // Determine if it’s a back navigation by looking further back in history
            let isBackNavigation = navigationHistory.count > 2 &&
                                   navigationHistory[navigationHistory.count - 3].forComparison() == currentURL.forComparison()

            // Fire the appropriate pixel based on navigation type
            if isBackNavigation {
                pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationBack, withAdditionalParameters: [:])
            } else if previousURL.isYoutubeWatch && currentURL.isYoutube {
                // Forward navigation within YouTube (including non-video URLs)
                pixelFiring.fire(.duckPlayerYouTubeNavigationWithinYouTube, withAdditionalParameters: [:])
            } else if previousURL.isYoutubeWatch && !currentURL.isYoutube {
                // Navigation outside YouTube
                pixelFiring.fire(.duckPlayerYouTubeOverlayNavigationOutsideYoutube, withAdditionalParameters: [:])
            }
        }

        // Refined truncation logic:
        if let lastOccurrenceIndex = (0..<navigationHistory.count - 1).last(where: { navigationHistory[$0].forComparison() == comparisonURL }) {
            // Truncate history to keep only up to the last occurrence of the current URL in normalized form
            navigationHistory = Array(navigationHistory.prefix(upTo: lastOccurrenceIndex + 1))
        }

        // Cancel and reset the idle timer whenever a new navigation occurs
        resetIdleTimer()
    }


}
