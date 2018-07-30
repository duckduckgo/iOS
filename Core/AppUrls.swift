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

        // You can change this to use a subdomain for testing (e.g. "test.")
        static let subdomain = ""
        static let domain = ProcessInfo.processInfo.environment["BASE_DOMAIN_AND_PORT", default: "duckduckgo.com"]
        static let base = "\(subdomain)\(domain)"
        static let home = "https://\(base)"
        static let favicon = "\(home)/favicon.ico"
        static let autocomplete = "\(home)/ac/"
        static let disconnectMeBlockList = "\(home)/contentblocking.js?l=disconnect"
        static let easylistBlockList = "\(home)/contentblocking.js?l=easylist"
        static let easylistPrivacyBlockList = "\(home)/contentblocking.js?l=easyprivacy"
        static let httpsUpgradeList = "\(home)/contentblocking.js?l=https2"
        static let trackersWhitelist = "\(home)/contentblocking/trackers-whitelist.txt"
        static let surrogates = "\(home)/contentblocking.js?l=surrogates"
        static let atb = "\(home)/atb.js"
        static let exti = "\(home)/exti/"
        static let feedback = "\(home)/feedback.js?type=app-feedback"
        static let faviconService = "\(home)/ip3/%@.ico"
        
        static let pixel = "https://improving.\(domain)/t/%@_ios_%@"
    }

    private struct Param {
        static let search = "q"
        static let source = "t"
        static let atb = "atb"
        static let setAtb = "set_atb"
    }

    private struct ParamValue {
        static let source = "ddg_ios"
    }

    let statisticsStore: StatisticsStore

    public init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
    }

    public var base: URL {
        return URL(string: Url.base)!
    }

    public var favicon: URL {
        return URL(string: Url.favicon)!
    }

    public var home: URL {
        return URL(string: Url.home)!
    }

    public var disconnectMeBlockList: URL {
        return URL(string: Url.disconnectMeBlockList)!
    }

    public var easylistBlockList: URL {
        return URL(string: Url.easylistBlockList)!
    }

    public var easylistPrivacyBlockList: URL {
        return URL(string: Url.easylistPrivacyBlockList)!
    }

    public var httpsUpgradeList: URL {
        return URL(string: Url.httpsUpgradeList)!
    }

    public var trackersWhitelist: URL {
        return URL(string: Url.trackersWhitelist)!
    }

    public var surrogates: URL {
        return URL(string: Url.surrogates)!
    }

    public var feedback: URL {
        return URL(string: Url.feedback)!
    }

    public var atb: URL {
        var url = URL(string: Url.atb)!
        if let atbWithVariant = statisticsStore.atbWithVariant, let setAtb = statisticsStore.retentionAtb {
            url = url.addParam(name: Param.atb, value: atbWithVariant)
            url = url.addParam(name: Param.setAtb, value: setAtb)
        }
        return url
    }

    public func isDuckDuckGo(url: URL) -> Bool {
        guard let host = url.host else { return false }
        return host == Url.domain || host.hasSuffix(".\(Url.domain)")
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

    public func faviconUrl(forDomain domain: String) -> URL {
        let urlString = String(format: Url.faviconService, domain)
        return URL(string: urlString)!
    }

    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t
     and cohort (atb) https://duck.co/help/privacy/atb
     */
    public func searchUrl(text: String) -> URL {
        let searchUrl = home.addParam(name: Param.search, value: text)
        return applyStatsParams(for: searchUrl)
    }

    public func applyStatsParams(for url: URL) -> URL {
        var searchUrl = url.addParam(name: Param.source, value: ParamValue.source)
        if let atbWithVariant = statisticsStore.atbWithVariant {
            searchUrl = searchUrl.addParam(name: Param.atb, value: atbWithVariant)
        }

        return searchUrl
    }

    public func autocompleteUrl(forText text: String) -> URL {
        return URL(string: Url.autocomplete)!.addParam(name: Param.search, value: text)
    }

    public func isDuckDuckGoSearch(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard url.getParam(name: Param.search) != nil else { return false }
        return true
    }

    public func hasCorrectMobileStatsParams(url: URL) -> Bool {
        guard let source = url.getParam(name: Param.source), source == ParamValue.source  else { return false }
        if let atbWithVariant = statisticsStore.atbWithVariant {
            return atbWithVariant == url.getParam(name: Param.atb)
        }
        return true
    }
    
    public func pixelUrl(forPixelNamed pixelName: String, formFactor: String) -> URL {
        var url = URL(string: Url.pixel.format(arguments: pixelName, formFactor))!
        url = url.addParam(name: Param.atb, value: statisticsStore.atbWithVariant ?? "")
        return url
    }

}
