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
    let pixelName: String?
    let error: Error?
    let params: [String: String]?
    let includedParams: [Pixel.QueryParameters]?

    init(pixelName: String?,
         error: Error? = nil,
         params: [String: String]?,
         includedParams: [Pixel.QueryParameters]?) {
        self.pixelName = pixelName
        self.error = error
        self.params = params
        self.includedParams = includedParams
    }
}

final actor PixelFiringMock: PixelFiring, PixelFiringAsync, DailyPixelFiring {
    
    static var expectedFireError: Error?

    static var allPixelsFired = [PixelInfo]()

    static var lastPixelInfo: PixelInfo?
    static var lastDailyPixelInfo: PixelInfo?

    static var lastParams: [String: String]? { lastPixelInfo?.params }
    static var lastPixelName: String? { lastPixelInfo?.pixelName }
    static var lastIncludedParams: [Pixel.QueryParameters]? { lastPixelInfo?.includedParams }

    static func fire(pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters]) async throws {
        let info = PixelInfo(pixelName: pixel.name, params: params, includedParams: includedParameters)
        lastPixelInfo = info
        allPixelsFired.append(info)

        if let expectedFireError {
            throw expectedFireError
        }
    }

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters],
                     onComplete: @escaping (Error?) -> Void) {
        let info = PixelInfo(pixelName: pixel.name, params: params, includedParams: includedParameters)
        lastPixelInfo = info
        allPixelsFired.append(info)

        onComplete(expectedFireError)
    }

    static func fire(_ pixel: Pixel.Event,
                     withAdditionalParameters params: [String: String]) {
        let info = PixelInfo(pixelName: pixel.name, params: params, includedParams: nil)
        lastPixelInfo = info
        allPixelsFired.append(info)
    }

    static func fire(pixel: Pixel.Event,
                     error: (any Error)?,
                     includedParameters: [Pixel.QueryParameters],
                     withAdditionalParameters params: [String: String],
                     onComplete: @escaping ((any Error)?) -> Void) {

        let info = PixelInfo(pixelName: pixel.name, error: error, params: params, includedParams: includedParameters)
        lastPixelInfo = info
        allPixelsFired.append(info)

        onComplete(expectedFireError)
    }

    static func fire(pixelNamed pixelName: String,
                     withAdditionalParameters params: [String: String],
                     includedParameters: [Pixel.QueryParameters],
                     onComplete: @escaping ((any Error)?) -> Void) {

        let info = PixelInfo(pixelName: pixelName, params: params, includedParams: includedParameters)
        lastPixelInfo = info
        allPixelsFired.append(info)

        onComplete(expectedFireError)
    }

    // DailyPixelFiring

    static func fireDaily(_ pixel: Pixel.Event) {
        let info = PixelInfo(pixelName: pixel.name, params: nil, includedParams: nil)
        lastDailyPixelInfo = info
        allPixelsFired.append(info)
    }

    static func fireDaily(_ pixel: Pixel.Event, withAdditionalParameters params: [String: String]) {
        let info = PixelInfo(pixelName: pixel.name, params: params, includedParams: nil)
        lastDailyPixelInfo = info
        allPixelsFired.append(info)
    }

    // -

    static func tearDown() {
        allPixelsFired = []
        lastPixelInfo = nil
        lastDailyPixelInfo = nil
        expectedFireError = nil
    }

    private init() {}
}
