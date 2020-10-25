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

public struct AppUrls {

    private struct Url {
        
        static var devMode: String {
            return isDebugBuild ? "?test=1" : ""
        }
        
        static let base = ProcessInfo.processInfo.environment["BASE_URL", default: "https://duckduckgo.com"]
        static let externalContentBase = "https://external-content.duckduckgo.com"
        static let staticBase = "https://staticcdn.duckduckgo.com"
        
        static let autocomplete = "\(base)/ac/"
        
        static let surrogates = "\(base)/contentblocking.js?l=surrogates"
        static let temporaryUnprotectedSites = "\(base)/contentblocking/trackers-whitelist-temporary.txt"
        static let trackerDataSet = "\(staticBase)/trackerblocking/v2.1/tds.json"

        static let atb = "\(base)/atb.js\(devMode)"
        static let exti = "\(base)/exti/\(devMode)"
        static let feedback = "\(base)/feedback.js?type=app-feedback"
 
        static let httpsBloomFilter = "https://staticcdn.duckduckgo.com/https/https-mobile-v2-bloom.bin"
        static let httpsBloomFilterSpec = "https://staticcdn.duckduckgo.com/https/https-mobile-v2-bloom-spec.json"
        static let httpsExcludedDomains = "https://staticcdn.duckduckgo.com/https/https-mobile-v2-false-positives.json"
        
        static let pixelBase = ProcessInfo.processInfo.environment["PIXEL_BASE_URL", default: "https://improving.duckduckgo.com"]
        static let pixel = "\(pixelBase)/t/%@_ios_%@"
    }

    private struct Param {
        static let search = "q"
        static let source = "t"
        static let atb = "atb"
        static let setAtb = "set_atb"
        static let activityType = "at"
        static let partialHost = "pv1"
    }

    private struct ParamValue {
        static let source = "ddg_ios"
        static let appUsage = "app_use"
    }

    let statisticsStore: StatisticsStore

    public init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
    }

    public var base: URL {
        return URL(string: Url.base)!
    }
    
    public func autocompleteUrl(forText text: String) -> URL {
        return URL(string: Url.autocomplete)!.addParam(name: Param.search, value: text)
    }

    public var surrogates: URL {
        return URL(string: Url.surrogates)!
    }
    
    public var trackerDataSet: URL {
        return URL(string: Url.trackerDataSet)!
    }
    
    public var temporaryUnprotectedSites: URL {
        return URL(string: Url.temporaryUnprotectedSites)!
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
        return URL(string: Url.atb)!
            .addParam(name: Param.atb, value: atbWithVariant)
            .addParam(name: Param.setAtb, value: setAtb)
    }
    
    public var appAtb: URL? {
        guard let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.appRetentionAtb else {
            return nil
        }
        return URL(string: Url.atb)!
            .addParam(name: Param.activityType, value: ParamValue.appUsage)
            .addParam(name: Param.atb, value: atbWithVariant)
            .addParam(name: Param.setAtb, value: setAtb)
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
        return url.getParam(name: Param.search)
    }

    public func url(forQuery query: String) -> URL {
        if let url = URL.webUrl(fromText: query) {
            return url
        }
        return searchUrl(text: query)
    }

    public func exti(forAtb atb: String) -> URL {
        let extiUrl = URL(string: Url.exti)!
        return extiUrl.addParam(name: Param.atb, value: atb)
    }

    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t
     and cohort (atb) https://duck.co/help/privacy/atb
     */
    public func searchUrl(text: String) -> URL {
        let searchUrl = base.addParam(name: Param.search, value: text)
        return applyStatsParams(for: searchUrl)
    }
    
    public func isDuckDuckGoSearch(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard url.getParam(name: Param.search) != nil else { return false }
        return true
    }

    public func applyStatsParams(for url: URL) -> URL {
        var searchUrl = url.addParam(name: Param.source, value: ParamValue.source)
        if let atbWithVariant = statisticsStore.atbWithVariant {
            searchUrl = searchUrl.addParam(name: Param.atb, value: atbWithVariant)
        }

        return searchUrl
    }

    public func hasCorrectMobileStatsParams(url: URL) -> Bool {
        guard let source = url.getParam(name: Param.source), source == ParamValue.source  else { return false }
        if let atbWithVariant = statisticsStore.atbWithVariant {
            return atbWithVariant == url.getParam(name: Param.atb)
        }
        return true
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
    
    public func pixelUrl(forPixelNamed pixelName: String, formFactor: String) -> URL {
        var url = URL(string: Url.pixel.format(arguments: pixelName, formFactor))!
        url = url.addParam(name: Param.atb, value: statisticsStore.atbWithVariant ?? "")
        return url
    }
    
    public func removeATBAndSource(fromUrl url: URL) -> URL {
        guard isDuckDuckGoSearch(url: url) else { return url }
        return url.removeParam(name: Param.atb).removeParam(name: Param.source)
    }

}
