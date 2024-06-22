//
//  BrowsersComparisonChartView.swift
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

import SwiftUI

struct BrowsersComparisonModel {

    static let browsers: [BrowserModel] = [
        .init(
            browser: Browser(type: .safari),
            privacyFeatures: [
                .init(
                    feature: .privateSearch,
                    availability: .unavailable
                ),
                .init(
                    feature: .blockThirdPartyTrackers,
                    availability: .partiallyAvailable
                ),
                .init(
                    feature: .blockCookiePopups,
                    availability: .unavailable
                ),
                .init(
                    feature: .blockCreepyAds,
                    availability: .unavailable
                ),
                .init(
                    feature: .eraseBrowsingData,
                    availability: .unavailable
                ),
            ]
        ),
        .init(
            browser: Browser(type: .ddg),
            privacyFeatures: [
                .init(
                    feature: .privateSearch,
                    availability: .available
                ),
                .init(
                    feature: .blockThirdPartyTrackers,
                    availability: .available
                ),
                .init(
                    feature: .blockCookiePopups,
                    availability: .available
                ),
                .init(
                    feature: .blockCreepyAds,
                    availability: .available
                ),
                .init(
                    feature: .eraseBrowsingData,
                    availability: .available
                ),
            ]
        )
    ]

}

extension BrowsersComparisonModel {

    struct Browser {
        enum `Type`: CaseIterable, Identifiable {
            case safari
            case ddg

            var id: Self {
                self
            }

            var image: ImageResource {
                switch self {
                case .safari: .safariBrowserIcon
                case .ddg: .ddgBrowserIcon
                }
            }
        }
        let type: `Type`
    }

    enum PrivacyFeature: CaseIterable, Identifiable {
        case privateSearch
        case blockThirdPartyTrackers
        case blockCookiePopups
        case blockCreepyAds
        case eraseBrowsingData

        var id: Self {
            self
        }

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

    struct BrowserModel {
        struct Feature {
            let feature: BrowsersComparisonModel.PrivacyFeature
            let availability: PrivacyFeature.Availability
        }

        let browser: Browser
        let privacyFeatures: [Feature]
    }

}

struct BrowsersComparisonAvailabilityColumn: View {
    let browser: BrowsersComparisonModel.BrowserModel

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(browser.privacyFeatures, id: \.feature.id) { feature in
                Image(feature.availability.image)
                    .frame(width: 50, height: 50)

                Divider()
            }
        }
    }
}

struct BrowsersComparisonColumns: View {
    let browsers: [BrowsersComparisonModel.BrowserModel]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(browsers.enumerated()), id: \.offset) { index, browser in
                BrowsersComparisonAvailabilityColumn(browser: browser)
                    .frame(width: 50)

                if index < browsers.count - 1 {
                    Divider()
                }
            }
        }
        .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) // Stops the Divider to expand vertically
    }
}

struct BrowsersComparisonTitleView: View {
    let features: [BrowsersComparisonModel.PrivacyFeature]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(features, id: \.id) { feature in
                BrowserFeatureTitleView(title: feature.title)
                    .frame(height: 50.0)
            }
        }
    }
}

struct BrowsersComparisonView: View {
    let features: [BrowsersComparisonModel.PrivacyFeature]
    let browsers: [BrowsersComparisonModel.BrowserModel]

    var body: some View {
        VStack(spacing: 0) {
            BrowserComparisonChartHeader(browsers: browsers.map(\.browser))
                .frame(height: 60)
            HStack(spacing: 0) {
                BrowsersComparisonTitleView(features: features)
                BrowsersComparisonColumns(browsers: browsers)

            }
        }
    }
}


struct BrowserComparisonChartHeader: View {
    let browsers: [BrowsersComparisonModel.Browser]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()

            ForEach(Array(browsers.map(\.type).enumerated()), id: \.offset) { index, browser in
                Image(browser.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 40)

                if index < browsers.count - 1 {
                    Divider()
                }
            }
        }
    }
}

struct BrowserFeatureTitleView: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading) {

            Spacer()

            Text(verbatim: title)
                .font(.system(size: 15.0))
                .foregroundColor(.primary)

            Spacer()

            Divider()
        }
    }
}

struct BrowserFeatureAvailabilityView: View {
    let availability: BrowsersComparisonModel.PrivacyFeature.Availability

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            Image(availability.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)

            Spacer()

            Divider()
        }
    }
}

#Preview {
    BrowsersComparisonView(
        features: BrowsersComparisonModel.PrivacyFeature.allCases,
        browsers: BrowsersComparisonModel.browsers
    )
    .padding()
}
