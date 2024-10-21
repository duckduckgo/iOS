//
//  MockPersistentPixel.swift
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
@testable import Core

final class MockPersistentPixel: PersistentPixelFiring {

    var expectedFireError: Error?
    var expectedDailyPixelStorageError: Error?
    var expectedCountPixelStorageError: Error?

    var lastPixelInfo: PixelInfo?
    var lastDailyPixelInfo: PixelInfo?

    var lastParams: [String: String]? { lastPixelInfo?.params }
    var lastPixelName: String? { lastPixelInfo?.pixelName }
    var lastIncludedParams: [Pixel.QueryParameters]? { lastPixelInfo?.includedParams }

    func tearDown() {
        lastPixelInfo = nil
        lastDailyPixelInfo = nil
        expectedFireError = nil
        expectedDailyPixelStorageError = nil
        expectedCountPixelStorageError = nil
    }

    func fire(pixel: Core.Pixel.Event,
              error: (any Error)?,
              includedParameters: [Core.Pixel.QueryParameters],
              withAdditionalParameters params: [String: String],
              onComplete: @escaping ((any Error)?) -> Void) {
        self.lastPixelInfo = .init(pixelName: pixel.name, error: error, params: params, includedParams: includedParameters)
        onComplete(expectedFireError)
    }
    
    func fireDailyAndCount(pixel: Core.Pixel.Event,
                           pixelNameSuffixes: (dailySuffix: String, countSuffix: String),
                           error: (any Error)?,
                           withAdditionalParameters params: [String: String],
                           includedParameters: [Core.Pixel.QueryParameters],
                           completion: @escaping ((dailyPixelStorageError: Error?, countPixelStorageError: Error?)) -> Void) {
        self.lastDailyPixelInfo = .init(pixelName: pixel.name, error: error, params: params, includedParams: includedParameters)
        completion((expectedDailyPixelStorageError, expectedCountPixelStorageError))
    }

    func sendQueuedPixels(completion: @escaping (Core.PersistentPixelStorageError?) -> Void) {
        completion(nil)
    }

}
