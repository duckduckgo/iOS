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

private extension URL {

    static let base: String = ProcessInfo.processInfo.environment["BASE_URL", default: "https://duckduckgo.com"]
    static let pixelBase: String = ProcessInfo.processInfo.environment["PIXEL_BASE_URL", default: "https://improving.duckduckgo.com"]
    static let staticBase: String = "https://staticcdn.duckduckgo.com"

    static let ddg = URL(string: URL.base)!

    static let autocomplete = URL(string: "\(base)/ac/")!
    static var emailProtection = URL(string: "\(base)/email")!
    static var emailProtectionQuickLink = URL(string: "ddgQuickLink://\(base)/email")!

    static let surrogates = URL(string: "\(staticBase)/surrogates.txt")!
    static let privacyConfig = URL(string: "\(staticBase)/trackerblocking/config/v2/ios-config.json")!
    static let trackerDataSet = URL(string: "\(staticBase)/trackerblocking/v3/apple-tds.json")!
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

}

public struct AppURLs {

    private enum Param {

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

    private enum ParamValue {

        static let source = "ddg_ios"
        static let appUsage = "app_use"
        static let searchHeader = "-1"
        static let enableNavSuggestions = "1"
        static let emailEnabled = "1"
        static let emailDisabled = "0"
        static let majorVerticals: Set<String> = ["images", "videos", "news"]

    }

    let statisticsStore: StatisticsStore
    public let variantManager: VariantManager

    public init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
                variantManager: VariantManager = DefaultVariantManager()) {
        self.statisticsStore = statisticsStore
        self.variantManager = variantManager
    }

    public let ddg = URL.ddg

    public let surrogates = URL.surrogates
    public let trackerDataSet = URL.trackerDataSet
    public let privacyConfig = URL.privacyConfig
    public let bloomFilter = URL.bloomFilter
    public let bloomFilterSpec = URL.bloomFilterSpec
    public let bloomFilterExcludedDomains = URL.bloomFilterExcludedDomains

    public let feedback = URL.feedback

    public func makeAutocomplete(for text: String) throws -> URL {
        URL.autocomplete.appendingParameters([
            Param.search: text,
            Param.enableNavSuggestions: ParamValue.enableNavSuggestions
        ])
    }

    public func isDuckDuckGo(domain: String?) -> Bool {
        guard let domain = domain, let url = URL(string: "https://\(domain)") else { return false }
        return isDuckDuckGo(url: url)
    }
    
    public func isDuckDuckGo(url: URL) -> Bool { url.isPart(ofDomain: ddg.host!) }

    public func searchQuery(from url: URL) -> String? {
        guard isDuckDuckGo(url: url) else { return nil }
        return url.getParameter(named: Param.search)
    }

    public func make(forQuery query: String, queryContext: URL? = nil) -> URL? {
        if let url = URL.webUrl(from: query) {
            return url
        }
        
        var parameters = [String: String]()
        if let queryContext = queryContext,
           isDuckDuckGoSearch(url: queryContext),
           queryContext.getParameter(named: Param.verticalMaps) == nil,
           let vertical = queryContext.getParameter(named: Param.vertical),
           ParamValue.majorVerticals.contains(vertical) {

            parameters[Param.verticalRewrite] = vertical
        }
        
        return makeSearch(for: query, additionalParameters: parameters)
    }
    
    public func isDuckDuckGoStatic(url: URL) -> Bool {
        let staticPaths = ["/settings", "/params"]
        guard isDuckDuckGo(url: url), staticPaths.contains(url.path) else { return false }
        return true
    }

    public let macBrowserDownload = URL.mac
    public let windowsBrowserDownload = URL.windows
    public let appStore = URL.appStore

    public func makePixel(withName pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        var urlString = "\(URL.pixelBase)/t/\(pixelName)"
        if let formFactor = formFactor {
            urlString.append("_ios_\(formFactor)")
        }
        var url = URL(string: urlString)!

        if includeATB {
            url = url.appendingParameter(name: Param.atb, value: statisticsStore.atbWithVariant ?? "")
        }

        return url
    }

    // MARK: - Email protection

    public let emailProtectionQuickLink = URL.emailProtectionQuickLink
    public func isDuckDuckGoEmailProtectionURL(_ url: URL) -> Bool { url.absoluteString.starts(with: URL.emailProtection.absoluteString) }

    // MARK: - atb

    public let initialAtb = URL.atb
    public func exti(forAtb atb: String) -> URL { URL.exti.appendingParameter(name: Param.atb, value: atb) }

    public var searchAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.searchRetentionAtb else {
            return nil
        }
        return URL.atb.appendingParameters([
            Param.atb: atbWithVariant,
            Param.setAtb: setAtb,
            Param.email: EmailManager().isSignedIn ? ParamValue.emailEnabled : ParamValue.emailDisabled
        ])
    }

    public var appAtb: URL? {
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

    public func applyingStatsParams(for url: URL) -> URL {
        var searchURL = url.removingParameters(named: [Param.source, Param.atb])
            .appendingParameter(name: Param.source,
                                value: ParamValue.source)

        if let atbWithVariant = statisticsStore.atbWithVariant {
            searchURL = searchURL.appendingParameter(name: Param.atb, value: atbWithVariant)
        }
        return searchURL
    }

    public func hasCorrectMobileStatsParams(url: URL) -> Bool {
        guard let source = url.getParameter(named: Param.source),
              source == ParamValue.source
        else { return false }
        if let atbWithVariant = statisticsStore.atbWithVariant {
            return atbWithVariant == url.getParameter(named: Param.atb)
        }
        return true
    }

    // MARK: - Search

    public func applyingSearchHeaderParams(for url: URL) -> URL {
        url.removingParameters(named: [Param.searchHeader]).appendingParameter(name: Param.searchHeader, value: ParamValue.searchHeader)
    }

    public func hasCorrectSearchHeaderParams(url: URL) -> Bool {
        guard let header = url.getParameter(named: Param.searchHeader) else { return false }
        return header == ParamValue.searchHeader
    }

    public func removingInternalSearchParameters(from url: URL) -> URL {
        guard isDuckDuckGoSearch(url: url) else { return url }
        return url.removingParameters(named: [Param.atb, Param.source, Param.searchHeader])
    }

    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t
     and cohort (atb) https://duck.co/help/privacy/atb
     */
    private func makeSearch<C: Collection>(for text: String, additionalParameters: C) -> URL where C.Element == (key: String, value: String) {
        let searchURL = ddg
            .appendingParameter(name: Param.search, value: text)
            .appendingParameters(additionalParameters)
        return applyingStatsParams(for: searchURL)
    }

    public func makeSearch(for text: String) -> URL? {
        return makeSearch(for: text, additionalParameters: [])
    }

    public func isDuckDuckGoSearch(url: URL) -> Bool {
        guard isDuckDuckGo(url: url), url.getParameter(named: Param.search) != nil else { return false }
        return true
    }

}
