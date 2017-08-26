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
        static let base = "duckduckgo.com"
        static let home = "https://www.duckduckgo.com"
        static let favicon = "https://duckduckgo.com/favicon.ico"
        static let autocomplete = "https://duckduckgo.com/ac/"
        static let contentBlocking = "https://duckduckgo.com/contentblocking.js"
        static let cohort = "https://duckduckgo.com/atb.js"
    }

    private struct Param {
        static let search = "q"
        static let source = "t"
        static let appVersion = "tappv"
        static let cohort = "atb"
    }

    private struct ParamValue {
        static let source = "ddg_ios"
        static let appVersion = "ios"
    }
    
    let version: AppVersion
    let statisticsStore: StatisticsStore
    
    public init(version: AppVersion = AppVersion(), statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.version = version
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

    public var contentBlocking: URL {
        return URL(string: Url.contentBlocking)!
    }
    
    public var cohort: URL {
        return URL(string: Url.cohort)!
    }
    
    public func isDuckDuckGo(url: URL) -> Bool {
        guard let host = url.host else { return false }
        return host == Url.base || host.hasSuffix(".\(Url.base)")
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
    
    /**
     Generates a search url with the source (t) https://duck.co/help/privacy/t,
     app version and cohort (atb) https://duck.co/help/privacy/atb
     */
    public func searchUrl(text: String) -> URL {
        let searchUrl = home.addParam(name: Param.search, value: text)
        return applyStatsParams(for: searchUrl)
    }

    public func applyStatsParams(for url: URL) -> URL {
        let searchUrl = url.addParam(name: Param.source, value: ParamValue.source)
            .addParam(name: Param.appVersion, value: appVersion)

        guard let cohortVersion = statisticsStore.cohortVersion else { return searchUrl }
        return searchUrl.addParam(name: Param.cohort, value: cohortVersion)
    }

    private var appVersion: String {
        return "\(ParamValue.appVersion)_\(version.versionNumber)_\(version.buildNumber)"
    }
    
    public func autocompleteUrl(forText text: String) -> URL {
        return URL(string: Url.autocomplete)!.addParam(name: Param.search, value: text)
    }

    public func isDuckDuckGoSearch(url: URL) -> Bool {
        if !isDuckDuckGo(url: url) { return false }
        guard let _ = url.getParam(name: Param.search) else { return false }
        return true
    }

    public func hasCorrectMobileStatsParams(url: URL) -> Bool {
        guard let cohort = url.getParam(name: Param.cohort), cohort == statisticsStore.cohortVersion else { return false }
        guard let source = url.getParam(name: Param.source), source == ParamValue.source  else { return false }
        guard let version = url.getParam(name: Param.appVersion), version == appVersion else { return false }
        return true
    }

}
