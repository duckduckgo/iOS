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
    let privacyFeatures: [BrowsersComparisonModel.PrivacyFeature]

    var body: some View {
        VStack(spacing: Metrics.stackSpacing) {
            Header(browsers: BrowsersComparisonModel.Browser.allCases)
                .frame(height: Metrics.headerHeight)

            ForEach(privacyFeatures, id: \.type) { feature in
                Row(feature: feature)
            }

        }
    }
}

// MARK: - Header

extension BrowsersComparisonChart {

    struct Header: View {
        let browsers: [BrowsersComparisonModel.Browser]

        var body: some View {
            HStack(alignment: .bottom) {
                Spacer()

                ForEach(Array(browsers.enumerated()), id: \.offset) { index, browser in
                    Image(browser.image)
                        .frame(width: Metrics.headerImageContainerSize.width, height: Metrics.headerImageContainerSize.height)

                    if index < browsers.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

}

// MARK: - Row

extension BrowsersComparisonChart {

    struct Row: View {
        let feature: BrowsersComparisonModel.PrivacyFeature

        var body: some View {
            HStack {
                Text(verbatim: feature.type.title)
                    .font(Metrics.font)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .lineSpacing(1)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                BrowsersSupport(browsersSupport: feature.browsersSupport)
            }
            .frame(maxHeight: Metrics.imageContainerSize.height)

            Divider()
        }
    }

}

// MARK: - Row + BrowsersSupport

extension BrowsersComparisonChart.Row {

    struct BrowsersSupport: View {
        let browsersSupport: [BrowsersComparisonModel.PrivacyFeature.BrowserSupport]

        var body: some View {
            ForEach(Array(browsersSupport.enumerated()), id: \.offset) { index, browserSupport in
                Image(browserSupport.availability.image)
                    .frame(width: Metrics.imageContainerSize.width)

                if index < browsersSupport.count - 1 {
                    Divider()
                }
            }
        }
    }

}

// MARK: - Metrics

private enum Metrics {
    static let stackSpacing: CGFloat = 0.0
    static let headerHeight: CGFloat = 60
    static let headerImageContainerSize = CGSize(width: 40, height: 80)
    static let imageContainerSize = CGSize(width: 40.0, height: 50.0)
    static let font = Font.system(size: 15.0)
}

#Preview {
    BrowsersComparisonChart(privacyFeatures: BrowsersComparisonModel.privacyFeatures)
    .padding()
}
