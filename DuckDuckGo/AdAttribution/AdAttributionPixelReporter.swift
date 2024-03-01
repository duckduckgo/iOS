//
//  AdAttributionPixelReporter.swift
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

protocol PixelFiring {
    static func fire(pixel: Pixel.Event, withAdditionalParameters params: [String: String]) async throws
}

final class AdAttributionPixelReporter {

    static var shared = AdAttributionPixelReporter()

    private var fetcherStorage: AdAttributionReporterStorage
    private let attributionFetcher: AdAttributionFetcher
    private let pixelFiring: PixelFiring.Type

    init(fetcherStorage: AdAttributionReporterStorage = UserDefaultsAdAttributionReporterStorage(),
         attributionFetcher: AdAttributionFetcher = DefaultAdAttributionFetcher(),
         pixelFiring: PixelFiring.Type = Pixel.self) {
        self.fetcherStorage = fetcherStorage
        self.attributionFetcher = attributionFetcher
        self.pixelFiring = pixelFiring
    }

    @discardableResult
    func reportAttributionIfNeeded() async -> Bool {
        guard await fetcherStorage.wasAttributionReportSuccessful == false else {
            return false
        }

        if let attributionData = await self.attributionFetcher.fetch() {
            if attributionData.attribution {
                let parameters = self.pixelParametersForAttribution(attributionData)
                do {
                    try await pixelFiring.fire(pixel: .appleAdAttribution, withAdditionalParameters: parameters)
                } catch {
                    return false
                }
            }

            await fetcherStorage.markAttributionReportSuccessful()

            return true
        }

        return false
    }

    private func pixelParametersForAttribution(_ attribution: AdServicesAttributionResponse) -> [String: String] {
        var params: [String: String] = [:]

        params[PixelParameters.adAttributionAdGroupID] = attribution.adGroupId.map(String.init)
        params[PixelParameters.adAttributionOrgID] = attribution.orgId.map(String.init)
        params[PixelParameters.adAttributionCampaignID] = attribution.campaignId.map(String.init)
        params[PixelParameters.adAttributionConversionType] = attribution.conversionType
        params[PixelParameters.adAttributionAdGroupID] = attribution.adGroupId.map(String.init)
        params[PixelParameters.adAttributionCountryOrRegion] = attribution.countryOrRegion
        params[PixelParameters.adAttributionKeywordID] = attribution.keywordId.map(String.init)
        params[PixelParameters.adAttributionAdID] = attribution.adId.map(String.init)

        return params
    }
}

extension Pixel: PixelFiring {
    static func fire(pixel: Event, withAdditionalParameters params: [String: String]) async throws {

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Pixel.fire(pixel: pixel, withAdditionalParameters: params) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
