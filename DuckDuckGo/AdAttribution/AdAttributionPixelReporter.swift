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
import BrowserServicesKit

final actor AdAttributionPixelReporter {
    
    static var shared = AdAttributionPixelReporter()

    private var fetcherStorage: AdAttributionReporterStorage
    private let attributionFetcher: AdAttributionFetcher
    private let featureFlagger: FeatureFlagger
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let variantManager: VariantManager
    private let pixelFiring: PixelFiringAsync.Type
    private var isSendingAttribution: Bool = false

    private var shouldReport: Bool {
        get async {
            return await !fetcherStorage.wasAttributionReportSuccessful
        }
    }

    init(fetcherStorage: AdAttributionReporterStorage = UserDefaultsAdAttributionReporterStorage(),
         attributionFetcher: AdAttributionFetcher = DefaultAdAttributionFetcher(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         variantManager: VariantManager = AppDependencyProvider.shared.variantManager,
         pixelFiring: PixelFiringAsync.Type = Pixel.self) {
        self.fetcherStorage = fetcherStorage
        self.attributionFetcher = attributionFetcher
        self.featureFlagger = featureFlagger
        self.privacyConfigurationManager = privacyConfigurationManager
        self.variantManager = variantManager
        self.pixelFiring = pixelFiring
    }

    @discardableResult
    func reportAttributionIfNeeded() async -> Bool {
        guard featureFlagger.isFeatureOn(.adAttributionReporting) else {
            return false
        }

        guard await shouldReport else {
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
                let settings = AdAttributionReporterSettings(privacyConfigurationManager.privacyConfig)
                let token = settings.includeToken ? token : nil
                let isReinstall = variantManager.isIndicatingReturningUser
                let parameters = self.pixelParametersForAttribution(attributionData, isReinstall: isReinstall, attributionToken: token)
                do {
                    try await pixelFiring.fire(
                        pixel: .appleAdAttribution,
                        withAdditionalParameters: parameters,
                        includedParameters: [.appVersion]
                    )
                } catch {
                    return false
                }
            }

            await markAttributionReportSuccessful()

            return true
        }

        return false
    }

    private func markAttributionReportSuccessful() async {
        await fetcherStorage.markAttributionReportSuccessful()
    }

    private func pixelParametersForAttribution(_ attribution: AdServicesAttributionResponse, isReinstall: Bool, attributionToken: String?) -> [String: String] {
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
        params[PixelParameters.adAttributionIsReinstall] = isReinstall ? "1" : "0"

        return params
    }
}

private extension BoolFileMarker.Name {
    static let isAttrbutionReportSuccessful = BoolFileMarker.Name(rawValue: "ad-attribution-successful")
}

private struct AdAttributionReporterSettings {
    var includeToken: Bool

    init(_ configuration: PrivacyConfiguration) {
        let featureSettings = configuration.settings(for: .adAttributionReporting)

        self.includeToken = featureSettings[Key.includeToken] as? Bool ?? false
    }

    private enum Key {
        static let includeToken = "includeToken"
    }
}

private extension VariantManager {
    var isIndicatingReturningUser: Bool {
        currentVariant?.name == VariantIOS.returningUser.name
    }
}
