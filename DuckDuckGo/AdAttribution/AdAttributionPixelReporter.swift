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

final actor AdAttributionPixelReporter {

    static let isAdAttributionReportingEnabled = false

    static var shared = AdAttributionPixelReporter()

    private var fetcherStorage: AdAttributionReporterStorage
    private let attributionFetcher: AdAttributionFetcher
    private let pixelFiring: PixelFiringAsync.Type
    private var isSendingAttribution: Bool = false

    init(fetcherStorage: AdAttributionReporterStorage = UserDefaultsAdAttributionReporterStorage(),
         attributionFetcher: AdAttributionFetcher = DefaultAdAttributionFetcher(),
         pixelFiring: PixelFiringAsync.Type = Pixel.self) {
        self.fetcherStorage = fetcherStorage
        self.attributionFetcher = attributionFetcher
        self.pixelFiring = pixelFiring
    }

    @discardableResult
    func reportAttributionIfNeeded() async -> Bool {
        guard await fetcherStorage.wasAttributionReportSuccessful == false else {
            return false
        }

        guard !isSendingAttribution else {
            return false
        }

        isSendingAttribution = true

        defer {
            isSendingAttribution = false
        }

        if let (token, attributionData) = await self.attributionFetcher.fetch() {
            if attributionData.attribution {
                let parameters = self.pixelParametersForAttribution(attributionData, attributionToken: token)
                do {
                    try await pixelFiring.fire(
                        pixel: .appleAdAttribution,
                        withAdditionalParameters: parameters,
                        includedParameters: [.appVersion, .atb]
                    )
                } catch {
                    return false
                }
            }

            await fetcherStorage.markAttributionReportSuccessful()

            return true
        }

        return false
    }

    private func pixelParametersForAttribution(_ attribution: AdServicesAttributionResponse, attributionToken: String) -> [String: String] {
        var params: [String: String] = [:]

        params[PixelParameters.adAttributionAdGroupID] = attribution.adGroupId.map(String.init)
        params[PixelParameters.adAttributionOrgID] = attribution.orgId.map(String.init)
        params[PixelParameters.adAttributionCampaignID] = attribution.campaignId.map(String.init)
        params[PixelParameters.adAttributionConversionType] = attribution.conversionType
        params[PixelParameters.adAttributionAdGroupID] = attribution.adGroupId.map(String.init)
        params[PixelParameters.adAttributionCountryOrRegion] = attribution.countryOrRegion
        params[PixelParameters.adAttributionKeywordID] = attribution.keywordId.map(String.init)
        params[PixelParameters.adAttributionAdID] = attribution.adId.map(String.init)
        params[PixelParameters.adAttributionToken] = attributionToken

        return params
    }
}
