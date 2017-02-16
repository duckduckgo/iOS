//
//  AppUrls.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct AppUrls {
    
    public static let launch = "ddgLaunch://"
    
    public static let quickLink = "ddgQuickLink://"
    
    public static let base = "duckduckgo.com"
    
    public static let home = "https://www.duckduckgo.com/?ko=-1&kl=wt-wt"
    
    private static let searchParam = "q"
    
    public static func isLaunch(url: URL) -> Bool {
        if let scheme = url.scheme {
            return AppUrls.launch.contains(scheme)
        }
        return false
    }
    
    public static func isQuickLink(url: URL) -> Bool {
        if let scheme = url.scheme {
            return AppUrls.quickLink.contains(scheme)
        }
        return false
    }
    
    public static func isDuckDuckGo(url: URL) -> Bool {
        return url.absoluteString.contains(base)
    }
    
    public static func searchQuery(fromUrl url: URL) -> String? {
        if !isDuckDuckGo(url: url) {
            return nil
        }
        return url.get(param: searchParam)
    }
    
    public static func url(forQuery query: String) -> URL? {
        if let url = URL.webUrl(fromText: query) {
            return url
        }
        if let searchUrl = AppUrls.searchUrl(text: query) {
            return searchUrl
        }
        return nil
    }
    
    private static func searchUrl(text: String) -> URL? {
        guard let encodedQuery = URL.encode(queryText: text) else {
            return nil
        }
        let url = "\(home)&\(searchParam)=\(encodedQuery)"
        return URL(string: url)
    }
}
