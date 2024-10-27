//
//  PixelFiring.swift
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
import Networking

public protocol PixelFiring {

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters],
                     onComplete: @escaping (Error?) -> Void)

    static func fire(pixel: Pixel.Event,
                     error: Error?,
                     includedParameters: [Pixel.QueryParameters],
                     withAdditionalParameters params: [String: String],
                     onComplete: @escaping (Error?) -> Void)

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String])

    static func fire(pixelNamed pixelName: String,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters],
                     onComplete: @escaping (Error?) -> Void)
}

extension Pixel: PixelFiring {
    public static func fire(_ pixel: Pixel.Event,
                            withAdditionalParameters params: [String: String],
                            includedParameters: [Pixel.QueryParameters],
                            onComplete: @escaping (Error?) -> Void) {

        Self.fire(pixel: pixel,
                   withAdditionalParameters: params,
                   includedParameters: includedParameters,
                   onComplete: onComplete)
    }

    public static func fire(_ pixel: Pixel.Event,
                            withAdditionalParameters params: [String: String]) {
        Self.fire(pixel: pixel, withAdditionalParameters: params)
    }
    
    public static func fire(pixelNamed pixelName: String,
                            withAdditionalParameters params: [String: String],
                            includedParameters: [Pixel.QueryParameters],
                            onComplete: @escaping (Error?) -> Void) {
        Self.fire(pixelNamed: pixelName,
                  withAdditionalParameters: params,
                  allowedQueryReservedCharacters: nil,
                  includedParameters: includedParameters,
                  onComplete: onComplete)
    }
}
