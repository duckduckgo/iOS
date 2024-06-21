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

enum BrowserFeature: CaseIterable, Identifiable {
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
}

enum BrowserFeatureAvailability: Identifiable {
    case available
    case partiallyAvailable
    case unavailable

    var id: Self {
        self
    }

    var image: String {
        switch self {
        case .available:
            "CheckGreen"
        case .partiallyAvailable:
            "Stop"
        case .unavailable:
            "Cross"
        }
    }
}

enum Browser: CaseIterable, Identifiable {
    case safari
    case ddg

    var id: Self {
        self
    }

    var image: String {
        switch self {
        case .safari:
            "SafariLogo"
        case .ddg:
            "SafariLogo"
        }
    }
}

struct BrowserComparisonChartModel {

    static let privacyFeatures: [PrivacyFeature] = [
        .init(
            type: .privateSearch,
            browsersAvailability: [
                .init(browser: .safari, availability: .unavailable),
                .init(browser: .ddg, availability: .available),
            ]
        ),
        .init(
            type: .blockThirdPartyTrackers,
            browsersAvailability: [
                .init(browser: .safari, availability: .partiallyAvailable),
                .init(browser: .ddg, availability: .available),
            ]
        ),
        .init(
            type: .blockCookiePopups,
            browsersAvailability: [
                .init(browser: .safari, availability: .unavailable),
                .init(browser: .ddg, availability: .available),
            ]
        ),
        .init(
            type: .blockCreepyAds,
            browsersAvailability: [
                .init(browser: .safari, availability: .unavailable),
                .init(browser: .ddg, availability: .available),
            ]
        ),
        .init(
            type: .eraseBrowsingData,
            browsersAvailability: [
                .init(browser: .safari, availability: .unavailable),
                .init(browser: .ddg, availability: .available),
            ]
        ),
    ]

}

struct BrowserModel {
    struct Feature {
        let feature: BrowserFeature
        let availability: BrowserFeatureAvailability
    }
    let browser: Browser
    let features: [Feature]
}

extension BrowserComparisonChartModel {
    
    struct PrivacyFeature {
        struct Availability {
            let browser: Browser
            let availability: BrowserFeatureAvailability
        }

        let type: BrowserFeature
        let browsersAvailability: [Availability]
    }

}

struct BrowsersComparisonChartView: View {

    let features: [BrowserComparisonChartModel.PrivacyFeature]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BrowserComparisonChartHeader(browsers: Browser.allCases)
                .frame(height: 50.0)

//            ForEach(features, id: \.type) { feature in
//                HStack {
//                    BrowserComparisonChartItemView(feature: feature).frame(height: 50.0)
//                }
//            }

            HStack {
                VStack(alignment: .leading) {
                    ForEach(features, id: \.type) { feature in
                        BrowserFeatureTitleView(title: feature.type.title)
                            .frame(height: 50)
                    }
                }

                Spacer(minLength: 170)

                VStack {
                    ForEach(features, id: \.type) { feature in
                        HStack(spacing: 0) {
                            ForEach(feature.browsersAvailability, id: \.browser) { browser in
                                BrowserFeatureAvailabilityView(availability: browser.availability)
                                    .frame(height: 50)
                            }
                        }

                    }
                }
            }
        }
        .padding()
    }
}

struct BrowsersComparisonAvailabilityColumn: View {
    let browser: BrowserModel

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(browser.features, id: \.feature.id) { feature in
                Image(feature.availability.image)
                    .frame(width: 50, height: 50)

                Divider()
            }
        }
    }
}

struct BrowsersComparisonColumns: View {
    let browsers: [BrowserModel]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(browsers, id: \.browser.id) { browser in
                BrowsersComparisonAvailabilityColumn(browser: browser)
            }
        }
    }
}

struct BrowsersComparisonTitleView: View {
    let features: [BrowserFeature]

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
    let features: [BrowserFeature]
    let browsers: [BrowserModel]

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                BrowsersComparisonTitleView(features: features)
                BrowsersComparisonColumns(browsers: browsers)

            }
        }
    }
}


struct BrowserComparisonChartHeader: View {
    
    let browsers: [Browser]

    var body: some View {
        HStack {
            Spacer()

            ForEach(Array(browsers.enumerated()), id: \.offset) { index, browser in
                BrowserLogo(browser: .safari)
                //if index < browser.count - 1 {
                    Divider()
                //}
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

    let availability: BrowserFeatureAvailability

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

struct BrowserComparisonChartItemView: View {
    let feature: BrowserComparisonChartModel.PrivacyFeature

    var body: some View {
        VStack(alignment: .leading) {

            Spacer()

            HStack {
                Text(verbatim: feature.type.title)
                    .font(.system(size: 15.0))
                    .foregroundColor(.primary)

                ForEach(feature.browsersAvailability, id: \.browser) { availability in
                    Image(availability.availability.image)

                    Divider()
                }
            }

            Spacer()

            Divider()
        }
    }
}

struct BrowserLogo: View {
    enum Browser {
        case safari
        case ddg

        fileprivate var image: String {
            switch self {
            case .safari:
                "SafariLogo"
            case .ddg:
                "SafariLogo"
            }
        }
    }

    private let browser: Browser

    init(browser: Browser) {
        self.browser = browser
    }

    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 40, height: 40)
            .background(
                Image(browser.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipped()
            )
    }

}

#Preview {

    let browsers: [BrowserModel] = [
        .init(
            browser: .safari,
            features: [
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
            browser: .ddg,
            features: [
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


    return BrowsersComparisonView(
        features: BrowserFeature.allCases,
        browsers: browsers
    )
    .padding()
}

#Preview {
    BrowsersComparisonChartView(features: BrowserComparisonChartModel.privacyFeatures)
}
