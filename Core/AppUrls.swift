//
//  AppUrls.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct AppUrls {
    
    private struct Url {
        static let base = "duckduckgo.com"
        static let home = "https://www.duckduckgo.com/?ko=-1&kl=wt-wt"
        static let autocomplete = "https://duckduckgo.com/ac/"
        static let favicon = "https://duckduckgo.com/favicon.ico"
    }
    
    private struct Param {
        static let search = "q"
        static let safeSearch = "kp"
        static let regionFilter = "kl"
        static let dateFilter = "df"
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
    
    public static func isDuckDuckGo(url: URL) -> Bool {
        return url.absoluteString.contains(Url.base)
    }
    
    public static func searchQuery(fromUrl url: URL) -> String? {
        if !isDuckDuckGo(url: url) {
            return nil
        }
        return url.getParam(name: Param.search)
    }
    
    public static func url(forQuery query: String, filters: SearchFilterStore) -> URL? {
        if let url = URL.webUrl(fromText: query) {
            return url
        }
        if let searchUrl = searchUrl(text: query, filters: filters) {
            return searchUrl
        }
        return nil
    }
    
    public static func searchUrl(text: String, filters: SearchFilterStore) -> URL? {
        let url = addfilters(filters, toUrl: home)
        return url.addParam(name: Param.search, value: text)
    }
    
    private static func addfilters(_ filters: SearchFilterStore, toUrl url: URL) -> URL {
        var filteredUrl = url
        if !filters.safeSearchEnabled {
            filteredUrl = filteredUrl.addParam(name: Param.safeSearch, value: ParamValue.safeSearchOff)
        }
        if let regionFilter = filters.regionFilter {
            filteredUrl = filteredUrl.addParam(name: Param.regionFilter, value: regionFilter)
        }
        if let dateFilter = filters.dateFilter {
            filteredUrl = filteredUrl.addParam(name: Param.dateFilter, value: dateFilter)
        }
        return filteredUrl
    }
    
    public static func autocompleteUrl(forText text: String) -> URL? {
        return URL(string: Url.autocomplete)?.addParam(name: Param.search, value: text)
    }
}
