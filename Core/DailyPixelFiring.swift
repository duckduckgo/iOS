//
//  DailyPixelFiring.swift
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
import Persistence

public protocol DailyPixelFiring {
    static func fireDaily(_ pixel: Pixel.Event,
                          withAdditionalParameters params: [String: String])

    static func fireDailyAndCount(pixel: Pixel.Event,
                                  pixelNameSuffixes: (dailySuffix: String, countSuffix: String),
                                  error: Swift.Error?,
                                  withAdditionalParameters params: [String: String],
                                  includedParameters: [Pixel.QueryParameters],
                                  pixelFiring: PixelFiring.Type,
                                  dailyPixelStore: KeyValueStoring,
                                  onDailyComplete: @escaping (Swift.Error?) -> Void,
                                  onCountComplete: @escaping (Swift.Error?) -> Void)

    static func fireDaily(_ pixel: Pixel.Event)
}

extension DailyPixel: DailyPixelFiring {
    public static func fireDaily(_ pixel: Pixel.Event, withAdditionalParameters params: [String: String]) {
        fire(pixel: pixel, withAdditionalParameters: params)
    }

    public static func fireDaily(_ pixel: Pixel.Event) {
        fire(pixel: pixel)
    }
}
