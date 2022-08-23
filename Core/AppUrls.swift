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

        static var emailProtectionLink = "ddgQuickLink://https://quack.duckduckgo.com/email/"
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
        return try URL(string: Url.autocomplete)!
            .addParameter(name: Param.search, value: text)
            .addParameter(name: Param.enableNavSuggestions, value: ParamValue.enableNavSuggestions)
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
        return try? URL(string: Url.atb)?
            .addParameter(name: Param.atb, value: atbWithVariant)
            .addParameter(name: Param.setAtb, value: setAtb)
    }
    
    public var appAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.appRetentionAtb else {
            return nil
        }
        return try? URL(string: Url.atb)?
            .addParameter(name: Param.activityType, value: ParamValue.appUsage)
            .addParameter(name: Param.atb, value: atbWithVariant)
            .addParameter(name: Param.setAtb, value: setAtb)
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
        return try? url.getParameter(name: Param.search)
    }

    public func url(forQuery query: String, queryContext: URL? = nil) -> URL? {
        if let url = URL.webUrl(fromText: query) {
            return url
        }
        
        var parameters = [String: String]()
        if let queryContext = queryContext,
           isDuckDuckGoSearch(url: queryContext),
           (try? queryContext.getParameter(name: Param.verticalMaps)) == nil,
           let vertical = (try? queryContext.getParameter(name: Param.vertical)) ?? nil,
           ParamValue.majorVerticals.contains(vertical) {

            parameters[Param.verticalRewrite] = vertical
        }
        
        return searchUrl(text: query, additionalParameters: parameters)
    }

    public func exti(forAtb atb: String) -> URL {
        let extiUrl = URL(string: Url.exti)!
        return (try? extiUrl.addParameter(name: Param.atb, value: atb))!
    }

    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t
     and cohort (atb) https://duck.co/help/privacy/atb
     */
    public func searchUrl(text: String, additionalParameters: [String: String] = [:]) -> URL? {
        do {
            let searchUrl = try base.addParameter(name: Param.search, value: text)
                .addParameters(additionalParameters)
            return applyStatsParams(for: searchUrl)
        } catch {
            os_log("URL extension: %s", log: lifecycleLog, type: .error, error.localizedDescription)
            return nil
        }
    }
    
    public func isDuckDuckGoSearch(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard (try? url.getParameter(name: Param.search)) ?? nil != nil else { return false }
        return true
    }
    
    public func isDuckDuckGoStatic(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard DDGStaticURL(rawValue: url.path) != nil else { return false }
        return true
    }
    
    public func isGPCEnabled(url: URL,
                             config: PrivacyConfiguration = ContentBlocking.privacyConfigurationManager.privacyConfig) -> Bool {
        guard let gpcUrls = config.settings(for: .gpc)["gpcHeaderEnabledSites"] as? [String] else {
            return false
        }
        
        for gpcHost in gpcUrls where url.isPart(ofDomain: gpcHost) {
            return true
        }
        
        return false
    }
    
    public func isDuckDuckGoEmailProtection(url: URL) -> Bool {
        return url.absoluteString.starts(with: Url.emailProtectionLink)
    }

    public func applyStatsParams(for url: URL) -> URL {
        let searchUrl = (try? url.addParameter(name: Param.source, value: ParamValue.source))!
        if let atbWithVariant = statisticsStore.atbWithVariant,
           let searchUrl = try? searchUrl.addParameter(name: Param.atb, value: atbWithVariant) {
            return searchUrl
        }

        return searchUrl
    }

    public func hasCorrectMobileStatsParams(url: URL) -> Bool {
        guard let source = try? url.getParameter(name: Param.source),
              source == ParamValue.source
        else { return false }
        if let atbWithVariant = statisticsStore.atbWithVariant {
            return atbWithVariant == (try? url.getParameter(name: Param.atb)) ?? nil
        }
        return true
    }
    
    public func applySearchHeaderParams(for url: URL) -> URL {
        return (try? url.addParameter(name: Param.searchHeader, value: ParamValue.searchHeader)) ?? url
    }
    
    public func hasCorrectSearchHeaderParams(url: URL) -> Bool {
        guard let header = try? url.getParameter(name: Param.searchHeader) else { return false }
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
        return URL(string: Url.emailProtectionLink)!
    }

    public var macBrowserDownloadURL: URL {
        return URL(string: "https://duckduckgo.com/mac")!
    }
    
    public func pixelUrl(forPixelNamed pixelName: String, formFactor: String? = nil, includeATB: Bool = true) -> URL {
        var urlString = Url.pixel.format(arguments: pixelName)
        if let formFactor = formFactor {
            urlString.append("_ios_\(formFactor)")
        }
        var url = URL(string: urlString)!

        if includeATB {
            do {
                url = try url.addParameter(name: Param.atb, value: statisticsStore.atbWithVariant ?? "")
            } catch {
                assertionFailure("couldn‘t add atb parameter")
            }
        }

        return url
    }
    
    public func removeInternalSearchParameters(fromUrl url: URL) -> URL {
        guard isDuckDuckGoSearch(url: url) else { return url }
        return url.removeParameters(named: [Param.atb, Param.source, Param.searchHeader])
    }

}
