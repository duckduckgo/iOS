//
//  MockPixelFiring.swift
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
import Core

struct PixelInfo {
    let pixel: Pixel.Event?
    let params: [String: String]?
    let includedParams: [Pixel.QueryParameters]?
}

final actor PixelFiringMock: PixelFiring, PixelFiringAsync, DailyPixelFiring {
    static var expectedFireError: Error?

    static var lastPixelInfo: PixelInfo?
    static var lastDailyPixelInfo: PixelInfo?

    static var lastParams: [String: String]? { lastPixelInfo?.params }
    static var lastPixel: Pixel.Event? { lastPixelInfo?.pixel }
    static var lastIncludedParams: [Pixel.QueryParameters]? { lastPixelInfo?.includedParams }

    static func fire(pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters]) async throws {
        lastPixelInfo = PixelInfo(pixel: pixel, params: params, includedParams: includedParameters)

        if let expectedFireError {
            throw expectedFireError
        }
    }

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters],
                     onComplete: @escaping (Error?) -> Void) {
        lastPixelInfo = PixelInfo(pixel: pixel, params: params, includedParams: includedParameters)

        if let expectedFireError {
            onComplete(expectedFireError)
        }
    }

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String]) {
        lastPixelInfo = PixelInfo(pixel: pixel, params: params, includedParams: nil)
    }

    static func fireDaily(_ pixel: Pixel.Event) {
        lastDailyPixelInfo = PixelInfo(pixel: pixel, params: nil, includedParams: nil)
    }

    static func fireDaily(_ pixel: Pixel.Event, withAdditionalParameters params: [String: String]) {
        lastDailyPixelInfo = PixelInfo(pixel: pixel, params: params, includedParams: nil)
    }

    static func tearDown() {
        lastPixelInfo = nil
        lastDailyPixelInfo = nil
        expectedFireError = nil
    }

    private init() {}
}
