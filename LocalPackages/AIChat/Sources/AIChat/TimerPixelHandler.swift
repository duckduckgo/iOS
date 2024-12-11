//
//  TimerPixelHandler.swift
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


final class TimerPixelHandler {
    private let pixelHandler: AIChatPixelHandling
    private var hasCleanedUp = false
    private var isFirstPixelSent = true

    init(pixelHandler: any AIChatPixelHandling) {
        self.pixelHandler = pixelHandler
    }

    /// Marks that cleanup has been performed.
    func markCleanup() {
        hasCleanedUp = true
    }

    /// Sends an "open" pixel based on the cleanup status.
    /// - If this is the first time sending a pixel, it will not send any pixel.
    /// - If cleanup has been called, it sends an `openAfter10min` pixel.
    /// - Otherwise, it sends an `openBefore10min` pixel.
    func sendOpenPixel() {
        defer {
            hasCleanedUp = false
        }

        // Skip sending a pixel on the first call.
        guard !isFirstPixelSent else {
            isFirstPixelSent = false
            return
        }

        if hasCleanedUp {
            pixelHandler.fire(pixel: .openAfter10min)
        } else {
            pixelHandler.fire(pixel: .openBefore10min)
        }
    }
}
