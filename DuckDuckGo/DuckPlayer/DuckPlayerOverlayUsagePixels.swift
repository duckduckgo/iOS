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
}

final class DuckPlayerOverlayUsagePixels: NSObject, DuckPlayerOverlayPixelFiring {

    var pixelFiring: PixelFiring.Type
    var duckPlayerMode: DuckPlayerMode = .disabled
    private var isObserving = false

    weak var webView: WKWebView?

    private var lastVisitedURL: URL? // Tracks the last known URL

    init(pixelFiring: PixelFiring.Type = Pixel.self) {
        self.pixelFiring = pixelFiring
    }

    private func firePixelIfNeeded(_ pixel: Pixel.Event, url: URL?) {
        if let url, url.isYoutubeWatch, duckPlayerMode == .alwaysAsk {
            pixelFiring.fire(pixel, withAdditionalParameters: [:])
        }
    }
}
