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

    private static let defaultStatisticsDependentURL = StatisticsDependentURL()

    static func makeSearchURL(text: String) -> URL? { defaultStatisticsDependentURL.makeSearchURL(text: text) }
    static func makeSearchURL(query: String, queryContext: URL? = nil) -> URL? {
        defaultStatisticsDependentURL.makeSearchURL(query: query, queryContext: queryContext)
    }
    static func applyingStatsParams(for url: URL) -> URL { defaultStatisticsDependentURL.applyingStatsParams(for: url) }
    static var searchAtb: URL? { defaultStatisticsDependentURL.searchAtb }
    static var appAtb: URL? { defaultStatisticsDependentURL.appAtb }
    static func hasCorrectMobileStatsParams(url: URL) -> Bool { defaultStatisticsDependentURL.hasCorrectMobileStatsParams(url: url) }
    static func makePixelURL(pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        defaultStatisticsDependentURL.makePixelURL(pixelName: pixelName, formFactor: formFactor, includeATB: includeATB)
    }

}

public final class StatisticsDependentURL {

    private let statisticsStore: StatisticsStore

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
    }

    // MARK: - Search

    func makeSearchURL(text: String) -> URL? {
        makeSearchURL(text: text, additionalParameters: [])
    }

    func makeSearchURL(query: String, queryContext: URL? = nil) -> URL? {
        if let url = URL.webUrl(from: query) {
            return url
        }

        var parameters = [String: String]()
        if let queryContext = queryContext,
           queryContext.isDuckDuckGoSearch,
           queryContext.getParameter(named: URL.Param.verticalMaps) == nil,
           let vertical = queryContext.getParameter(named: URL.Param.vertical),
           URL.ParamValue.majorVerticals.contains(vertical) {

            parameters[URL.Param.verticalRewrite] = vertical
        }

        return makeSearchURL(text: query, additionalParameters: parameters)
    }

    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t
     and cohort (atb) https://duck.co/help/privacy/atb
     */
    private func makeSearchURL<C: Collection>(text: String, additionalParameters: C) -> URL
    where C.Element == (key: String, value: String) {
        let searchURL = URL.ddg
            .appendingParameter(name: URL.Param.search, value: text)
            .appendingParameters(additionalParameters)
        return applyingStatsParams(for: searchURL)
    }

    func applyingStatsParams(for url: URL) -> URL {
        var searchURL = url.removingParameters(named: [URL.Param.source, URL.Param.atb])
            .appendingParameter(name: URL.Param.source,
                                value: URL.ParamValue.source)

        if let atbWithVariant = statisticsStore.atbWithVariant {
            searchURL = searchURL.appendingParameter(name: URL.Param.atb, value: atbWithVariant)
        }
        return searchURL
    }

    // MARK: - ATB

    var searchAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.searchRetentionAtb else {
            return nil
        }
        return URL.atb.appendingParameters([
            URL.Param.atb: atbWithVariant,
            URL.Param.setAtb: setAtb,
            URL.Param.email: EmailManager().isSignedIn ? URL.ParamValue.emailEnabled : URL.ParamValue.emailDisabled
        ])
    }

    var appAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.appRetentionAtb else {
            return nil
        }
        return URL.atb.appendingParameters([
            URL.Param.activityType: URL.ParamValue.appUsage,
            URL.Param.atb: atbWithVariant,
            URL.Param.setAtb: setAtb,
            URL.Param.email: EmailManager().isSignedIn ? URL.ParamValue.emailEnabled : URL.ParamValue.emailDisabled
        ])
    }

    func hasCorrectMobileStatsParams(url: URL) -> Bool {
        guard let source = url.getParameter(named: URL.Param.source),
              source == URL.ParamValue.source
        else { return false }
        if let atbWithVariant = statisticsStore.atbWithVariant {
            return atbWithVariant == url.getParameter(named: URL.Param.atb)
        }
        return true
    }

    // MARK: - Pixel

    private static let pixelBase: String = ProcessInfo.processInfo.environment["PIXEL_BASE_URL", default: "https://improving.duckduckgo.com"]
    func makePixelURL(pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        var urlString = "\(Self.pixelBase)/t/\(pixelName)"
        if let formFactor = formFactor {
            urlString.append("_ios_\(formFactor)")
        }
        var url = URL(string: urlString)!

        if includeATB {
            url = url.appendingParameter(name: URL.Param.atb, value: statisticsStore.atbWithVariant ?? "")
        }

        return url
    }

}
