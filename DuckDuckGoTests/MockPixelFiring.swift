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

final actor PixelFiringMock: PixelFiring, PixelFiringAsync {
    static var expectedFireError: Error?

    static var lastParams: [String: String]?
    static var lastPixel: Pixel.Event?
    static var lastIncludedParams: [Pixel.QueryParameters]?
    
    static func fire(pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters]) async throws {
        lastParams = params
        lastPixel = pixel
        lastIncludedParams = includedParameters

        if let expectedFireError {
            throw expectedFireError
        }
    }

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters],
                     onComplete: @escaping (Error?) -> Void) {
        lastParams = params
        lastPixel = pixel
        lastIncludedParams = includedParameters

        if let expectedFireError {
            onComplete(expectedFireError)
        }
    }

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String]) {
        lastParams = params
        lastPixel = pixel
    }

    static func tearDown() {
        lastParams = nil
        lastPixel = nil
        lastIncludedParams = nil
        expectedFireError = nil
    }

    private init() {}
}
