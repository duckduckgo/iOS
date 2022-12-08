//
//  AppUrls.swift
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
import os.log

public struct AppUrls {

    private struct Url {
        
        static var devMode: String {
            return isDebugBuild ? "?test=1" : ""
        }
        
        static let base = ProcessInfo.processInfo.environment["BASE_URL", default: "https://duckduckgo.com"]
        static let externalContentBase = "https://external-content.duckduckgo.com"
        static let staticBase = "https://staticcdn.duckduckgo.com"
        
        static let autocomplete = "\(base)/ac/"
        
        static let surrogates = "\(staticBase)/surrogates.txt"
        static let privacyConfig = "\(staticBase)/trackerblocking/config/v2/ios-config.json"
        static let trackerDataSet = "\(staticBase)/trackerblocking/v3/apple-tds.json"
        static let lastCompiledRules = "\(staticBase)/trackerblocking/last-compiled-rules"

        static let atb = "\(base)/atb.js\(devMode)"
        static let exti = "\(base)/exti/\(devMode)"
        static let feedback = "\(base)/feedback.js?type=app-feedback"
 
        static let httpsBloomFilter = "https://staticcdn.duckduckgo.com/https/https-mobile-v2-bloom.bin"
        static let httpsBloomFilterSpec = "https://staticcdn.duckduckgo.com/https/https-mobile-v2-bloom-spec.json"
        static let httpsExcludedDomains = "https://staticcdn.duckduckgo.com/https/https-mobile-v2-false-positives.json"
        
        static let pixelBase = ProcessInfo.processInfo.environment["PIXEL_BASE_URL", default: "https://improving.duckduckgo.com"]
        static let pixel = "\(pixelBase)/t/%@"

        static var emailProtectionLink = "https://duckduckgo.com/email"
        static var emailProtectionQuickLink = "ddgQuickLink://https://duckduckgo.com/email"

        static let appStore = "https://apps.apple.com/app/duckduckgo-privacy-browser/id663592361"
    }
    
    private enum DDGStaticURL: String {
        case settings = "/settings"
        case params = "/params"
    }

    private struct Param {
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
    }

    private struct ParamValue {
        static let source = "ddg_ios"
        static let appUsage = "app_use"
        static let searchHeader = "-1"
        static let enableNavSuggestions = "1"

        static let majorVerticals: Set<String> = ["images", "videos", "news"]
    }

    let statisticsStore: StatisticsStore
    public let variantManager: VariantManager

    public init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
                variantManager: VariantManager = DefaultVariantManager()) {
        self.statisticsStore = statisticsStore
        self.variantManager = variantManager
    }

    public var base: URL {
        return URL(string: Url.base)!
    }
    
    public func autocompleteUrl(forText text: String) throws -> URL {
        return URL(string: Url.autocomplete)!
            .appendingParameters([
                Param.search: text,
                Param.enableNavSuggestions: ParamValue.enableNavSuggestions
            ])
    }

    public var surrogates: URL {
        return URL(string: Url.surrogates)!
    }
    
    public var trackerDataSet: URL {
        return URL(string: Url.trackerDataSet)!
    }
    
    public var privacyConfig: URL {
        return URL(string: Url.privacyConfig)!
    }
    
    public var lastCompiledRules: URL {
        return URL(string: Url.lastCompiledRules)!
    }

    public var feedback: URL {
        return URL(string: Url.feedback)!
    }
    
    public var initialAtb: URL {
        return URL(string: Url.atb)!
    }
    
    public var searchAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.searchRetentionAtb else {
            return nil
        }
        return URL(string: Url.atb)?
            .appendingParameters([
                Param.atb: atbWithVariant,
                Param.setAtb: setAtb
            ])
    }
    
    public var appAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.appRetentionAtb else {
            return nil
        }
        return URL(string: Url.atb)?
            .appendingParameters([
                Param.activityType: ParamValue.appUsage,
                Param.atb: atbWithVariant,
                Param.setAtb: setAtb
            ])
    }

    public func isBlog(url: URL) -> Bool {
        guard let host = url.host else { return false }
        return ["spreadprivacy.com", "www.spreadprivacy.com"].contains(host)
    }

    public func isDuckDuckGo(domain: String?) -> Bool {
        guard let domain = domain, let url = URL(string: "https://\(domain)") else { return false }
        return isDuckDuckGo(url: url)
    }
    
    public func isDuckDuckGo(url: URL) -> Bool {
        guard let searchHost = base.host else { return false }
        return url.isPart(ofDomain: searchHost)
    }

    public func searchQuery(fromUrl url: URL) -> String? {
        if !isDuckDuckGo(url: url) {
            return nil
        }
        return url.getParameter(named: Param.search)
    }

    public func url(forQuery query: String, queryContext: URL? = nil) -> URL? {
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
        
        return searchUrl(text: query, additionalParameters: parameters)
    }

    public func exti(forAtb atb: String) -> URL {
        let extiUrl = URL(string: Url.exti)!
        return extiUrl.appendingParameter(name: Param.atb, value: atb)
    }

    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t
     and cohort (atb) https://duck.co/help/privacy/atb
     */
    public func searchUrl<C: Collection>(text: String, additionalParameters: C) -> URL where C.Element == (key: String, value: String) {
        let searchUrl = base
            .appendingParameter(name: Param.search, value: text)
            .appendingParameters(additionalParameters)
        return applyStatsParams(for: searchUrl)
    }

    public func searchUrl(text: String) -> URL? {
        return searchUrl(text: text, additionalParameters: Array())
    }

    public func isDuckDuckGoSearch(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard url.getParameter(named: Param.search) != nil else { return false }
        return true
    }
    
    public func isDuckDuckGoStatic(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard DDGStaticURL(rawValue: url.path) != nil else { return false }
        return true
    }

    public func isDuckDuckGoEmailProtection(url: URL) -> Bool {
        return url.absoluteString.starts(with: Url.emailProtectionLink)
    }

    public func applyStatsParams(for url: URL) -> URL {
        var searchURL = url.removingParameters(named: [Param.source, Param.atb])
            .appendingParameter(name: Param.source, value: ParamValue.source)

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

    public func applySearchHeaderParams(for url: URL) -> URL {
        return url.removingParameters(named: [Param.searchHeader])
            .appendingParameter(name: Param.searchHeader, value: ParamValue.searchHeader)
    }

    public func hasCorrectSearchHeaderParams(url: URL) -> Bool {
        guard let header = url.getParameter(named: Param.searchHeader) else { return false }
        return header == ParamValue.searchHeader
    }
    
    public var httpsBloomFilter: URL {
        return URL(string: Url.httpsBloomFilter)!
    }

    public var httpsBloomFilterSpec: URL {
        return URL(string: Url.httpsBloomFilterSpec)!
    }

    public var httpsExcludedDomains: URL {
        return URL(string: Url.httpsExcludedDomains)!
    }

    public var emailProtectionQuickLink: URL {
        return URL(string: Url.emailProtectionQuickLink)!
    }

    public var macBrowserDownloadURL: URL {
        return URL(string: "https://duckduckgo.com/mac")!
    }
    
    public var appStoreURL: URL {
        return URL(string: Url.appStore)!
    }

    public func pixelUrl(forPixelNamed pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        var urlString = Url.pixel.format(arguments: pixelName)
        if let formFactor = formFactor {
            urlString.append("_ios_\(formFactor)")
        }
        var url = URL(string: urlString)!

        if includeATB {
            url = url.appendingParameter(name: Param.atb, value: statisticsStore.atbWithVariant ?? "")
        }

        return url
    }

    public func removingInternalSearchParameters(fromUrl url: URL) -> URL {
        guard isDuckDuckGoSearch(url: url) else { return url }
        return url.removingParameters(named: [Param.atb, Param.source, Param.searchHeader])
    }

}
