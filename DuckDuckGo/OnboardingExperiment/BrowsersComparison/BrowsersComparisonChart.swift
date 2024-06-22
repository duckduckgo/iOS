//
//  BrowsersComparisonChart.swift
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

// MARK: - Chart View

struct BrowsersComparisonChart: View {
    let browsers: [BrowsersComparisonModel.Browser]

    var body: some View {
        VStack(spacing: Metrics.stackSpacing) {
            Header(browsers: browsers)
                .frame(height: 60)
            HStack(spacing: Metrics.stackSpacing) {
                let features = browsers.first.map(\.privacyFeatures) ?? []
                FeaturesList(features: features)
                AvailabilityColumns(browsers: browsers)

            }
        }
    }
}

// MARK: - Header

extension BrowsersComparisonChart {

    struct Header: View {
        let browsers: [BrowsersComparisonModel.Browser]

        var body: some View {
            HStack(alignment: .top, spacing: Metrics.stackSpacing) {
                Spacer()

                ForEach(Array(browsers.map(\.type).enumerated()), id: \.offset) { index, browser in
                    Image(browser.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Metrics.viewSize.width, height: Metrics.viewSize.height)

                    if index < browsers.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

}

// MARK: - Vertical Features List

extension BrowsersComparisonChart {

    struct FeaturesList: View {
        let features: [BrowsersComparisonModel.PrivacyFeature]

        var body: some View {
            VStack(spacing: Metrics.stackSpacing) {
                ForEach(features, id: \.type) { feature in
                    FeaturesListItem(title: feature.type.title)
                        .frame(height: Metrics.viewSize.height)
                }
            }
        }
    }

    struct FeaturesListItem: View {
        let title: String

        var body: some View {
            VStack(alignment: .leading) {

                Spacer()

                Text(verbatim: title)
                    .font(Metrics.font)
                    .foregroundColor(.primary)

                Spacer()

                Divider()
            }
        }
    }

}

// MARK: - Browser Comparison Columns

extension BrowsersComparisonChart {

    struct AvailabilityColumns: View {
        let browsers: [BrowsersComparisonModel.Browser]

        var body: some View {
            HStack(spacing: Metrics.stackSpacing) {
                ForEach(Array(browsers.enumerated()), id: \.offset) { index, browser in
                    AvailabilityColumnsItem(browser: browser)
                        .frame(width: Metrics.viewSize.width)

                    if index < browsers.count - 1 {
                        Divider()
                    }
                }
            }
            .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) // Stops the Divider to expand vertically
        }
    }

    struct AvailabilityColumnsItem: View {
        let browser: BrowsersComparisonModel.Browser

        var body: some View {
            VStack(alignment: .center, spacing: Metrics.stackSpacing) {
                ForEach(browser.privacyFeatures, id: \.type) { feature in
                    Image(feature.availability.image)
                        .frame(width: Metrics.viewSize.width, height: Metrics.viewSize.height)

                    Divider()
                }
            }
        }
    }

}

// MARK: - Metrics

private enum Metrics {
    static let stackSpacing: CGFloat = 0.0
    static let viewSize = CGSize(width: 50.0, height: 50.0)
    static let font = Font.system(size: 15.0)
}

#Preview {
    BrowsersComparisonChart(browsers: BrowsersComparisonModel().browsers)
    .padding()
}
