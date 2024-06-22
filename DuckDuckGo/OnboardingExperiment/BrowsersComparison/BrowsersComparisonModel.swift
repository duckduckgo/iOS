//
//  BrowsersComparisonModel.swift
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

struct BrowsersComparisonModel {

    let browsers: [Browser] = [
        .init(
            type: .safari,
            privacyFeatures: [
                .init(
                    type: .privateSearch,
                    availability: .unavailable
                ),
                .init(
                    type: .blockThirdPartyTrackers,
                    availability: .partiallyAvailable
                ),
                .init(
                    type: .blockCookiePopups,
                    availability: .unavailable
                ),
                .init(
                    type: .blockCreepyAds,
                    availability: .unavailable
                ),
                .init(
                    type: .eraseBrowsingData,
                    availability: .unavailable
                ),
            ]
        ),
        .init(
            type: .ddg,
            privacyFeatures: [
                .init(
                    type: .privateSearch,
                    availability: .available
                ),
                .init(
                    type: .blockThirdPartyTrackers,
                    availability: .available
                ),
                .init(
                    type: .blockCookiePopups,
                    availability: .available
                ),
                .init(
                    type: .blockCreepyAds,
                    availability: .available
                ),
                .init(
                    type: .eraseBrowsingData,
                    availability: .available
                ),
            ]
        )
    ]

}

// MARK: - Browser

extension BrowsersComparisonModel {

    struct Browser {
        let type: BrowserType
        let privacyFeatures: [PrivacyFeature]
    }

}

extension BrowsersComparisonModel.Browser {

    enum BrowserType {
        case safari
        case ddg

        var image: ImageResource {
            switch self {
            case .safari: .safariBrowserIcon
            case .ddg: .ddgBrowserIcon
            }
        }
    }

}

// MARK: - Privacy Feature

extension BrowsersComparisonModel {

    struct PrivacyFeature {
        let type: FeatureType
        let availability: Availability
    }

}

extension BrowsersComparisonModel.PrivacyFeature {

    enum FeatureType {
        case privateSearch
        case blockThirdPartyTrackers
        case blockCookiePopups
        case blockCreepyAds
        case eraseBrowsingData

        var title: String {
            switch self {
            case .privateSearch:
                UserText.DaxOnboardingExperiment.BrowsersComparison.Features.privateSearch
            case .blockThirdPartyTrackers:
                UserText.DaxOnboardingExperiment.BrowsersComparison.Features.trackerBlockers
            case .blockCookiePopups:
                UserText.DaxOnboardingExperiment.BrowsersComparison.Features.cookiePopups
            case .blockCreepyAds:
                UserText.DaxOnboardingExperiment.BrowsersComparison.Features.creepyAds
            case .eraseBrowsingData:
                UserText.DaxOnboardingExperiment.BrowsersComparison.Features.eraseBrowsingData
            }
        }
    }

    enum Availability: Identifiable {
        case available
        case partiallyAvailable
        case unavailable

        var id: Self {
            self
        }

        var image: ImageResource {
            switch self {
            case .available: .checkGreen
            case .partiallyAvailable: .stop
            case .unavailable: .cross
            }
        }
    }

}
