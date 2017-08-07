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
    }

    private struct Param {
        static let search = "q"
    }

    private struct ParamValue {
        static let safeSearchOff = "-1"
    }

    public static var base: URL {
        return URL(string: Url.base)!
    }

    public static var favicon: URL {
        return URL(string: Url.favicon)!
    }

    public static var home: URL {
        return URL(string: Url.home)!
    }

    public static var contentBlocking: URL {
        return URL(string: Url.contentBlocking)!
    }
    
    public static func isDuckDuckGo(url: URL) -> Bool {
        return url.absoluteString.contains(Url.base)
    }

    public static func searchQuery(fromUrl url: URL) -> String? {
        if !isDuckDuckGo(url: url) {
            return nil
        }
        return url.getParam(name: Param.search)
    }

    public static func url(forQuery query: String) -> URL? {
        if let url = URL.webUrl(fromText: query) {
            return url
        }
        if let searchUrl = searchUrl(text: query) {
            return searchUrl
        }
        return nil
    }

    public static func searchUrl(text: String) -> URL? {
        return home.addParam(name: Param.search, value: text)
    }

    public static func autocompleteUrl(forText text: String) -> URL? {
        return URL(string: Url.autocomplete)?.addParam(name: Param.search, value: text)
    }
}
