//
//  AppURLs+StatisticsDependent.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

public extension URL {

    private static let defaultStatisticsDependent = StatisticsDependent()

    static func makeSearch(for text: String) -> URL? { defaultStatisticsDependent.makeSearch(for: text) }
    static func makeSearch(forQuery query: String, queryContext: URL? = nil) -> URL? {
        defaultStatisticsDependent.makeSearch(forQuery: query, queryContext: queryContext)
    }
    static func applyingStatsParams(for url: URL) -> URL { defaultStatisticsDependent.applyingStatsParams(for: url) }
    static var searchAtb: URL? { defaultStatisticsDependent.searchAtb }
    static var appAtb: URL? { defaultStatisticsDependent.appAtb }
    static func hasCorrectMobileStatsParams(url: URL) -> Bool { defaultStatisticsDependent.hasCorrectMobileStatsParams(url: url) }
    static func makePixel(withName pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        defaultStatisticsDependent.makePixel(withName: pixelName, formFactor: formFactor, includeATB: includeATB)
    }

    struct StatisticsDependent {

        private let statisticsStore: StatisticsStore

        init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
            self.statisticsStore = statisticsStore
        }

        // MARK: - Search

        func makeSearch(for text: String) -> URL? {
            makeSearch(for: text, additionalParameters: [])
        }

        func makeSearch(forQuery query: String, queryContext: URL? = nil) -> URL? {
            if let url = URL.webUrl(from: query) {
                return url
            }

            var parameters = [String: String]()
            if let queryContext = queryContext,
               queryContext.isDuckDuckGoSearch,
               queryContext.getParameter(named: Param.verticalMaps) == nil,
               let vertical = queryContext.getParameter(named: Param.vertical),
               ParamValue.majorVerticals.contains(vertical) {

                parameters[Param.verticalRewrite] = vertical
            }

            return makeSearch(for: query, additionalParameters: parameters)
        }

        /**
         Generates a search url with the source (t) https://duck.co/help/privacy/t
         and cohort (atb) https://duck.co/help/privacy/atb
         */
        private func makeSearch<C: Collection>(for text: String, additionalParameters: C) -> URL
        where C.Element == (key: String, value: String) {
            let searchURL = ddg
                .appendingParameter(name: Param.search, value: text)
                .appendingParameters(additionalParameters)
            return applyingStatsParams(for: searchURL)
        }

        func applyingStatsParams(for url: URL) -> URL {
            var searchURL = url.removingParameters(named: [Param.source, Param.atb])
                .appendingParameter(name: Param.source,
                                    value: ParamValue.source)

            if let atbWithVariant = statisticsStore.atbWithVariant {
                searchURL = searchURL.appendingParameter(name: Param.atb, value: atbWithVariant)
            }
            return searchURL
        }

        // MARK: - ATB

        var searchAtb: URL? {
            guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.searchRetentionAtb else {
                return nil
            }
            return URL.atb.appendingParameters([
                Param.atb: atbWithVariant,
                Param.setAtb: setAtb,
                Param.email: EmailManager().isSignedIn ? ParamValue.emailEnabled : ParamValue.emailDisabled
            ])
        }

        var appAtb: URL? {
            guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.appRetentionAtb else {
                return nil
            }
            return URL.atb.appendingParameters([
                Param.activityType: ParamValue.appUsage,
                Param.atb: atbWithVariant,
                Param.setAtb: setAtb,
                Param.email: EmailManager().isSignedIn ? ParamValue.emailEnabled : ParamValue.emailDisabled
            ])
        }

        func hasCorrectMobileStatsParams(url: URL) -> Bool {
            guard let source = url.getParameter(named: Param.source),
                  source == ParamValue.source
            else { return false }
            if let atbWithVariant = statisticsStore.atbWithVariant {
                return atbWithVariant == url.getParameter(named: Param.atb)
            }
            return true
        }

        // MARK: - Pixel

        private static let pixelBase: String = ProcessInfo.processInfo.environment["PIXEL_BASE_URL", default: "https://improving.duckduckgo.com"]
        func makePixel(withName pixelName: String,
                              formFactor: String? = nil,
                              includeATB: Bool = true) -> URL {
            var urlString = "\(Self.pixelBase)/t/\(pixelName)"
            if let formFactor = formFactor {
                urlString.append("_ios_\(formFactor)")
            }
            var url = URL(string: urlString)!

            if includeATB {
                url = url.appendingParameter(name: Param.atb, value: statisticsStore.atbWithVariant ?? "")
            }

            return url
        }

    }

}
