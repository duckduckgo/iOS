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

    static let privacyFeatures: [PrivacyFeature] = {
        PrivacyFeature.FeatureType.allCases.map { featureType in
            PrivacyFeature(type: featureType, browsersSupport: browsersSupport(for: featureType))
        }
    }()

    private static func browsersSupport(for feature: PrivacyFeature.FeatureType) -> [PrivacyFeature.BrowserSupport] {
        Browser.allCases.map { browser in
            let availability: PrivacyFeature.Availability
            switch feature {
            case .privateSearch:
                switch browser {
                case .ddg:
                    availability = .available
                case .safari:
                    availability = .unavailable
                }
            case .blockThirdPartyTrackers:
                switch browser {
                case .ddg:
                    availability = .available
                case .safari:
                    availability = .partiallyAvailable
                }
            case .blockCookiePopups:
                switch browser {
                case .ddg:
                    availability = .available
                case .safari:
                    availability = .unavailable
                }
            case .blockCreepyAds:
                switch browser {
                case .ddg:
                    availability = .available
                case .safari:
                    availability = .unavailable
                }
            case .eraseBrowsingData:
                switch browser {
                case .ddg:
                    availability = .available
                case .safari:
                    availability = .unavailable
                }
            }

            return PrivacyFeature.BrowserSupport(browser: browser, availability: availability)
        }
    }

}

// MARK: - Browser

extension BrowsersComparisonModel {

    enum Browser: CaseIterable {
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
        let browsersSupport: [BrowserSupport]
    }

}

extension BrowsersComparisonModel.PrivacyFeature {

    struct BrowserSupport {
        let browser: BrowsersComparisonModel.Browser
        let availability: Availability
    }

    enum FeatureType: CaseIterable {
        case privateSearch
        case blockThirdPartyTrackers
        case blockCookiePopups
        case blockCreepyAds
        case eraseBrowsingData

        var title: String {
            switch self {
            case .privateSearch:
                UserText.Onboarding.BrowsersComparison.Features.privateSearch
            case .blockThirdPartyTrackers:
                UserText.Onboarding.BrowsersComparison.Features.trackerBlockers
            case .blockCookiePopups:
                UserText.Onboarding.BrowsersComparison.Features.cookiePopups
            case .blockCreepyAds:
                UserText.Onboarding.BrowsersComparison.Features.creepyAds
            case .eraseBrowsingData:
                UserText.Onboarding.BrowsersComparison.Features.eraseBrowsingData
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
