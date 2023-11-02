//
//  AppURLs.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

    private static let base: String = ProcessInfo.processInfo.environment["BASE_URL", default: "https://duckduckgo.com"]
    private static let staticBase: String = "https://staticcdn.duckduckgo.com"

    static let ddg = URL(string: URL.base)!

    static let autocomplete = URL(string: "\(base)/ac/")!
    static let emailProtection = URL(string: "\(base)/email")!
    static let emailProtectionSignUp = URL(string: "\(base)/email/start-incontext")!
    static let emailProtectionQuickLink = URL(string: AppDeepLinkSchemes.quickLink.appending("\(ddg.host!)/email"))!
    static let aboutLink = URL(string: AppDeepLinkSchemes.quickLink.appending("\(ddg.host!)/about"))!

    static let surrogates = URL(string: "\(staticBase)/surrogates.txt")!

    // The following URLs shall match the ones in update_embedded.sh. 
    // Danger checks that the URLs match on every PR. If the code changes, the regex that Danger uses may need an update.
    static let privacyConfig = URL(string: "\(staticBase)/trackerblocking/config/v4/ios-config.json")!
    static let trackerDataSet = URL(string: "\(staticBase)/trackerblocking/v5/current/ios-tds.json")!
    static let bloomFilter = URL(string: "\(staticBase)/https/https-mobile-v2-bloom.bin")!
    static let bloomFilterSpec = URL(string: "\(staticBase)/https/https-mobile-v2-bloom-spec.json")!
    static let bloomFilterExcludedDomains = URL(string: "\(staticBase)/https/https-mobile-v2-false-positives.json")!

    private static var devMode: String { isDebugBuild ? "?test=1" : "" }
    static let atb = URL(string: "\(base)/atb.js\(devMode)")!
    static let exti = URL(string: "\(base)/exti/\(devMode)")!
    static let feedback = URL(string: "\(base)/feedback.js?type=app-feedback")!

    static let appStore = URL(string: "https://apps.apple.com/app/duckduckgo-privacy-browser/id663592361")!

    static let mac = URL(string: "\(base)/mac")!
    static let windows = URL(string: "\(base)/windows")!

    static func makeExtiURL(atb: String) -> URL { URL.exti.appendingParameter(name: Param.atb, value: atb) }

    static func makeAutocompleteURL(for text: String) throws -> URL {
        URL.autocomplete.appendingParameters([
            Param.search: text,
            Param.enableNavSuggestions: ParamValue.enableNavSuggestions
        ])
    }

    static func isDuckDuckGo(domain: String?) -> Bool {
        guard let domain = domain, let url = URL(string: "https://\(domain)") else { return false }
        return url.isDuckDuckGo
    }

    var isDuckDuckGo: Bool { isPart(ofDomain: URL.ddg.host!) }

    var isDuckDuckGoStatic: Bool {
        let staticPaths = ["/settings", "/params"]
        guard isDuckDuckGo, staticPaths.contains(path) else { return false }
        return true
    }

    var isDuckDuckGoSearch: Bool {
        guard isDuckDuckGo, getParameter(named: Param.search) != nil else { return false }
        return true
    }

    var isDuckDuckGoEmailProtection: Bool { absoluteString.starts(with: URL.emailProtection.absoluteString) }

    var searchQuery: String? {
        guard isDuckDuckGo else { return nil }
        return getParameter(named: Param.search)
    }

    func applyingSearchHeaderParams() -> URL {
        removingParameters(named: [Param.searchHeader]).appendingParameter(name: Param.searchHeader, value: ParamValue.searchHeader)
    }

    var hasCorrectSearchHeaderParams: Bool {
        guard let header = getParameter(named: Param.searchHeader) else { return false }
        return header == ParamValue.searchHeader
    }

    func removingInternalSearchParameters() -> URL {
        guard isDuckDuckGoSearch else { return self }
        return removingParameters(named: [Param.atb, Param.source, Param.searchHeader])
    }

    fileprivate enum Param {

        static let search = "q"
        static let source = "t"
        static let atb = "atb"
        static let setAtb = "set_atb"
        static let activityType = "at"
        static let partialHost = "pv1"
        static let searchHeader = "ko"
        static let vertical = "ia"
        static let verticalRewrite = "iar"
        static let verticalMaps = "iaxm"
        static let enableNavSuggestions = "is_nav"
        static let email = "email"

    }

    fileprivate enum ParamValue {

        static let source = "ddg_ios"
        static let appUsage = "app_use"
        static let searchHeader = "-1"
        static let enableNavSuggestions = "1"
        static let emailEnabled = "1"
        static let emailDisabled = "0"
        static let majorVerticals: Set<String> = ["images", "videos", "news"]

    }

    // MARK: - StatisticsDependentURLs

    private static let defaultStatisticsDependentURLFactory = StatisticsDependentURLFactory()

    static func makeSearchURL(text: String) -> URL? { defaultStatisticsDependentURLFactory.makeSearchURL(text: text) }

    static func makeSearchURL(query: String, queryContext: URL? = nil) -> URL? {
        defaultStatisticsDependentURLFactory.makeSearchURL(query: query, queryContext: queryContext)
    }

    func applyingStatsParams() -> URL { URL.defaultStatisticsDependentURLFactory.applyingStatsParams(to: self) }

    static var searchAtb: URL? { defaultStatisticsDependentURLFactory.makeSearchAtbURL() }

    static var appAtb: URL? { defaultStatisticsDependentURLFactory.makeAppAtbURL() }

    var hasCorrectMobileStatsParams: Bool { URL.defaultStatisticsDependentURLFactory.hasCorrectMobileStatsParams(url: self) }

    static func makePixelURL(pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        defaultStatisticsDependentURLFactory.makePixelURL(pixelName: pixelName, formFactor: formFactor, includeATB: includeATB)
    }

}

public final class StatisticsDependentURLFactory {

    private let statisticsStore: StatisticsStore

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
    }

    // MARK: Search

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
        return applyingStatsParams(to: searchURL)
    }

    func applyingStatsParams(to url: URL) -> URL {
        var searchURL = url.removingParameters(named: [URL.Param.source, URL.Param.atb])
            .appendingParameter(name: URL.Param.source,
                                value: URL.ParamValue.source)

        if let atbWithVariant = statisticsStore.atbWithVariant {
            searchURL = searchURL.appendingParameter(name: URL.Param.atb, value: atbWithVariant)
        }
        return searchURL
    }

    // MARK: ATB

    func makeSearchAtbURL() -> URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.searchRetentionAtb else {
            return nil
        }
        return URL.atb.appendingParameters([
            URL.Param.atb: atbWithVariant,
            URL.Param.setAtb: setAtb,
            URL.Param.email: EmailManager().isSignedIn ? URL.ParamValue.emailEnabled : URL.ParamValue.emailDisabled
        ])
    }

    func makeAppAtbURL() -> URL? {
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

    // MARK: Pixel

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
