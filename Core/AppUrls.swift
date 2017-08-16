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
        static let home = "https://www.duckduckgo.com/?ko=-1&kl=wt-wt"
        static let favicon = "https://duckduckgo.com/favicon.ico"
        static let autocomplete = "https://duckduckgo.com/ac/"
        static let contentBlocking = "https://duckduckgo.com/contentblocking.js"
        static let campaign = "https://duckduckgo.com/atb.js"
    }

    private struct Param {
        static let search = "q"
        static let source = "t"
        static let appVersion = "tappv"
        static let campaign = "atb"
    }

    private struct ParamValue {
        static let source = "ddg_ios"
        static let appVersion = "ios"
    }
    
    let version: AppVersion
    let analyticsStore: AnalyticsStore
    
    public init(version: AppVersion = AppVersion(), analyticsStore: AnalyticsStore = AnalyticsUserDefaults()) {
        self.version = version
        self.analyticsStore = analyticsStore
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
    
    public var campaign: URL {
        return URL(string: Url.campaign)!
    }
    
    public func isDuckDuckGo(url: URL) -> Bool {
        return url.absoluteString.contains(Url.base)
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

    public func searchUrl(text: String) -> URL {
        let appVersion = "\(ParamValue.appVersion)_\(version.versionNumber)_\(version.buildNumber)"
        
        let searchUrl = home
            .addParam(name: Param.search, value: text)
            .addParam(name: Param.source, value: ParamValue.source)
            .addParam(name: Param.appVersion, value: appVersion)
        
        guard let campaignVersion = analyticsStore.campaignVersion else { return searchUrl }
        return searchUrl.addParam(name: Param.campaign, value: campaignVersion)
    }
    
    public func autocompleteUrl(forText text: String) -> URL {
        return URL(string: Url.autocomplete)!.addParam(name: Param.search, value: text)
    }
}
